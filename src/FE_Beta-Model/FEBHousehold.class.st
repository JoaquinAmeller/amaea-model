Class {
	#name : 'FEBHousehold',
	#superclass : 'CMAgent',
	#instVars : [
		'inventory',
		'foodPreferenceProportions',
		'substitutionList',
		'satisfactionMemory',
		'hungerMemory',
		'outlets',
		'availableMoneyPerStep',
		'remainingMoney',
		'householdSize',
		'availableTimePerStep',
		'remainingTime',
		'strategy',
		'shoppingStrategy',
		'dailyNeed',
		'consumptionHistory'
	],
	#classInstVars : [
		'minHouseholdSize',
		'maxHouseholdSize'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBHousehold class >> maxHouseholdSize [
	<parameterIntegerDefault: 5>
	^ maxHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold class >> maxHouseholdSize: anObject [

	maxHouseholdSize := anObject
]

{ #category : 'accessing' }
FEBHousehold class >> minHouseholdSize [
	<parameterIntegerDefault: 2>
	^ minHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold class >> minHouseholdSize: anObject [

	minHouseholdSize := anObject
]

{ #category : 'adding' }
FEBHousehold >> addEssentialMealsToTheShoppingList: aShoppingList [

	| missingMeals remainingMeals quantity |
	
	missingMeals := (dailyNeed - self totalUsableFoodQuantity) max: 0.
	remainingMeals := missingMeals.
	
	foodPreferenceProportions keysAndValuesDo: [ :category :proportion | 
		remainingMeals > 0 ifTrue: [ 
			quantity := (missingMeals * proportion) asInteger max: 1.
			aShoppingList addEssentialNeedOf: category quantity: quantity.
			remainingMeals := remainingMeals - quantity ] ]
]

{ #category : 'adding' }
FEBHousehold >> addStorageNeedsToTheShoppingList: aShoppingList [

	| storageHorizon availableMealsInStorage missingMeals remainingMeals quantity |
	storageHorizon := 5.
	
	availableMealsInStorage := (self totalUsableFoodQuantity - dailyNeed) max: 0.
	missingMeals := (dailyNeed * storageHorizon) - availableMealsInStorage.
	remainingMeals := missingMeals.
	
	foodPreferenceProportions keysAndValuesDo: [ :category :proportion | 
		remainingMeals > 0 ifTrue: [ 
			quantity := (missingMeals * proportion) asInteger max: 1.
			aShoppingList addStorageNeedOf: category quantity: quantity.
			remainingMeals := remainingMeals - quantity ] ].
	
	self substitutePerishableFoodThatWontFitInFridge: aShoppingList
]

{ #category : 'as yet unclassified' }
FEBHousehold >> availableMoneyForStorage [
	"Money that can be used to buy food for storage (the non-essential food)"
	^ remainingMoney - (availableMoneyPerStep * self moneyThreshold)
]

{ #category : 'accessing' }
FEBHousehold >> availableTimePerStep [

	^ availableTimePerStep
]

{ #category : 'metrics' }
FEBHousehold >> averageDistanceTo5ClosestOutlets [

	| outletDistances |
		
	outletDistances := outlets collect: [ :each | each -> (self cell distanceTo: each cell) ].
	outletDistances sort: [ :a :b | a value < b value ].
	
	^ ((outletDistances first: 5) collect: [ :assoc | assoc value ]) average asFloat
]

{ #category : 'metrics' }
FEBHousehold >> averageDistanceToAllOutlets [

	^ (outlets collect: [ :each | self cell distanceTo: each cell ]) average asFloat
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beDesperateSaver [
	<action>
	strategy := FEBDesperateSaverStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beMoneySaver [
	<action>
	strategy := FEBMoneySaverStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beRichBastard [
	<action>
	strategy := FEBRichBastardStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beTimeSaver [
	<action>
	strategy := FEBTimeSaverStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> buildShoppingList [

	| shoppingList |
	shoppingList := FEBShoppingList new.
	
	"First get essential meals. As many as we need to have food for 1 day"
	self addEssentialMealsToTheShoppingList: shoppingList.
	
	"Then get another day worth of food for storage"
	self addStorageNeedsToTheShoppingList: shoppingList.
	
	^ shoppingList
	
	
]

{ #category : 'accessing' }
FEBHousehold >> buyFoodBatches: batches for: moneySpent [

	batches do: [ :each |
		inventory addBatch: each ].

	remainingMoney := remainingMoney - moneySpent.
]

{ #category : 'as yet unclassified' }
FEBHousehold >> chooseBatchForNextMeal [

	| candidates sortedCandidates |
	candidates := inventory nonExpiredBatches
		select: [ :each | each isNotEmpty ].
		
	candidates ifEmpty: [ ^ nil ].
	
	sortedCandidates := candidates sorted: [ :a :b |
		a remainingDays < b remainingDays or: [ 
			a remainingDays = b remainingDays and: [ 
				(self preferenceRankingOf: a category) < (self preferenceRankingOf: b category) ] ] ].
	
	^ sortedCandidates first
]

{ #category : 'as yet unclassified' }
FEBHousehold >> consumeFood [
	<action>
	| eatenCategories chosenBatch |
	eatenCategories := OrderedCollection new.
	
	1 to: dailyNeed do: [ :i |
		chosenBatch := self chooseBatchForNextMeal.
		
		chosenBatch ifNotNil: [ 
			inventory extractOneUnitFromBatch: chosenBatch.
			eatenCategories add: chosenBatch category ] ].
	
	consumptionHistory at: self currentTimeStep put: eatenCategories.
	
	self updateHungerMemoryAfterEating: eatenCategories.
	
	^ eatenCategories
]

{ #category : 'adding' }
FEBHousehold >> findNonPerishableSubstitutionFor: aCategory [

	| otherCategory |
	otherCategory := substitutionList at: aCategory.
		
	[ otherCategory shouldBeStoredInFridge ] whileTrue: [ 
		otherCategory := substitutionList at: otherCategory ].
	
	^ otherCategory 
]

{ #category : 'accessing' }
FEBHousehold >> foodPreferenceProportions: aDictionary [

	| orderedDict |
	orderedDict := (aDictionary associations sorted: [ :a :b | a value > b value ]) asOrderedDictionary.

	foodPreferenceProportions := orderedDict.
	
	"Inventory is initialized when foodPreference is set because it needs to have food for one day, and we must specify the category of that food"
	self initializeInventory. 
	
]

{ #category : 'asserting' }
FEBHousehold >> goShopping [
	<action> 
	| shoppingList |
	self resetRemainingTimeAndMoney.
	shoppingList := self buildShoppingList.
	shoppingStrategy shopFor: self using: shoppingList.
	self updateSatisfactionMemory.
	self reconsiderPreference.
]

{ #category : 'asserting' }
FEBHousehold >> hasFoodForOneDay [	

	^ inventory totalQuantity >= (1 * dailyNeed)
]

{ #category : 'as yet unclassified' }
FEBHousehold >> hasUrgentFoodOfCategory: aCategory [

	^ inventory hasBatchExpiringSoonOfCategory: aCategory
]

{ #category : 'accessing' }
FEBHousehold >> householdSize [

	^ householdSize
]

{ #category : 'accessing' }
FEBHousehold >> initialize [

	super initialize.
	
	householdSize := self
		randomIntegerBetween: self class minHouseholdSize
			and: self class maxHouseholdSize.
	
	foodPreferenceProportions := OrderedDictionary new.
		
	satisfactionMemory := 2.
	hungerMemory := 0.
	
	"3 meals times the number of persons in the household"
	dailyNeed := 3 * householdSize. 
	
	"available for getting food"
	availableMoneyPerStep := 100.
	availableTimePerStep := 2 hours.
	
	"We need to do this to make sure that everyone is satisfied at init -> for the probe to work"
	self resetRemainingTimeAndMoney.
	
	"by default households prefers to save money just to avoid it to be nil.
	Init in the model will assign the proportions of preferences"
	self beMoneySaver.
	
	shoppingStrategy := FEBSimpleShoppingStrategy new.
	consumptionHistory := Dictionary new
	
	
]

{ #category : 'initialization' }
FEBHousehold >> initializeInventory [

	inventory := FEBFoodInventory new.
	inventory fridgeCapacity: (self randomIntegerBetween: 0 and: 6).
	
	"Since HH consume food before buying it and then buy food for next day, they must be created with enough food for one day (the first food consumption)."
	inventory addBatch: (FEBFoodBatch
		category: foodPreferenceProportions orderedKeys first
		quantity: dailyNeed
		fridge: false).
]

{ #category : 'accessing' }
FEBHousehold >> inventory [

	^ inventory
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isDesperateSaver [

	^ strategy isDesperateSaver
]

{ #category : 'testing' }
FEBHousehold >> isHavingHealthyDiet [
	"Average consumption of at least one unit each of fruits & vegetables, meat, and staple food per day over the last 7 days"
	
	| numberOfDays foodConsumedInSevenDays foodNames allFoodCategoryNames |
	
	numberOfDays := 7 min: consumptionHistory size.
	
	foodConsumedInSevenDays := (0 to: (numberOfDays - 1)) flatCollect: [ :i |
		consumptionHistory at: (self currentTimeStep - i) ].
	
	foodNames := foodConsumedInSevenDays collect: [ :category | category name ].
	
	"DANGER! This relies on foodPreferenceProportions to contain ALL the categories and not just some of them"
	allFoodCategoryNames := (foodPreferenceProportions keys collect: [ :category | category name ]) asSet.
	
	^ allFoodCategoryNames allSatisfy: [ :name | 
		(foodNames count: [ :each | each = name ]) >= 7 ].
	
]

{ #category : 'testing' }
FEBHousehold >> isHungry [
^ hungerMemory > 0
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isMoneySaver [

	^ strategy isMoneySaver
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isRichBastard [

	^ strategy isRichBastard
]

{ #category : 'testing' }
FEBHousehold >> isSatisfied [

	^ self isHungry not
		and: [ remainingMoney >= (availableMoneyPerStep * self moneyThreshold)
			and: [ remainingTime >= (availableTimePerStep * self timeThreshold) ] ]
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isTimeSaver [

	^ strategy isTimeSaver
]

{ #category : 'accessing' }
FEBHousehold >> maximumDesiredQuantityOf: aFoodCategory [

	^ aFoodCategory shouldBeStoredInFridge
		ifTrue: [ 1 + inventory freeFridgeSpace ]
		ifFalse: [ 10 "magic number" ]
]

{ #category : 'as yet unclassified' }
FEBHousehold >> moneyThreshold [

	^ strategy moneyThreshold
]

{ #category : 'metrics' }
FEBHousehold >> numberOfOutletsWithin30Min [

	^ outlets count: [ :each | (self cell timeToTravelTo: each cell) <= 30 minutes ]
]

{ #category : 'accessing' }
FEBHousehold >> outlets [

	^ outlets
]

{ #category : 'accessing' }
FEBHousehold >> outlets: aCollection [

	outlets := aCollection
]

{ #category : 'accessing' }
FEBHousehold >> pov [
	<pov>
	| color |

	self isSatisfied
		ifTrue: [ color := CMColor green ]
		ifFalse: [ color := CMColor red ].

	^ CMPointOfView
		color: color
		shape: self shapeOfPovBasedOnStrategy
		size: self sizeOfPovBasedOnHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold >> povHealthyDiet [
	<pov>
	| color |

	self isHavingHealthyDiet
		ifTrue: [ color := CMColor green ]
		ifFalse: [ color := CMColor red ].

	^ CMPointOfView
		color: color
		shape: self shapeOfPovBasedOnStrategy
		size: self sizeOfPovBasedOnHouseholdSize
]

{ #category : 'as yet unclassified' }
FEBHousehold >> preferenceRankingOf: aCategory [

	^ foodPreferenceProportions orderedKeys 
		indexOf: aCategory
		ifAbsent: [ self error: 'All categories must appear in the preference list' ]
]

{ #category : 'accessing' }
FEBHousehold >> reconsiderPreference [

	self flag: 'TODO'
]

{ #category : 'as yet unclassified' }
FEBHousehold >> remainingMoney [

	^ remainingMoney 
]

{ #category : 'accessing' }
FEBHousehold >> remainingTime [

	^ remainingTime
]

{ #category : 'accessing' }
FEBHousehold >> remainingTime: aTime [

	remainingTime := aTime
]

{ #category : 'accessing' }
FEBHousehold >> resetRemainingTimeAndMoney [

	remainingTime := availableTimePerStep.
	remainingMoney := availableMoneyPerStep.
]

{ #category : 'accessing' }
FEBHousehold >> shapeOfPovBasedOnStrategy [

	^ strategy shapeOfPov
]

{ #category : 'asserting' }
FEBHousehold >> shouldGoShopping [

	^ self hasFoodForOneDay not
]

{ #category : 'accessing' }
FEBHousehold >> sizeOfPovBasedOnHouseholdSize [

	| min max |
	min := self class minHouseholdSize.
	max := self class maxHouseholdSize.
	^ 0.5 + (householdSize - min / (max - min) asFloat * 0.5)
]

{ #category : 'accessing' }
FEBHousehold >> step [

	inventory emptyTheTrashbin.

	"Households eat in the morning and then they consider buying food for the next day"
	self consumeFood.
	
	self shouldGoShopping ifTrue: [ 
		self goShopping ].
	
	inventory becomeOneDayOlder.

]

{ #category : 'adding' }
FEBHousehold >> substitutePerishableFoodThatWontFitInFridge: aShoppingList [

	| perishableCategories totalQuantityOfPerishable totalQuantityToSubstitute quantityToSubstitute otherCategory |
	
	perishableCategories := aShoppingList storageNeeds keys select: [ :category |
		category shouldBeStoredInFridge ].
	
	totalQuantityOfPerishable := perishableCategories sum: [ :category |
		aShoppingList storageNeedOf: category ].
	
	totalQuantityToSubstitute := (totalQuantityOfPerishable - inventory freeFridgeSpace) max: 0.
	
	"We sort them to make sure that we will be substituting the leass wanted categories first"
	perishableCategories asOrderedCollection sort: [ :a :b |
		(foodPreferenceProportions at: a) < (foodPreferenceProportions at: b) ].
	
	perishableCategories do: [ :category |
		totalQuantityToSubstitute <= 0 ifTrue: [ ^ self ].
		
		quantityToSubstitute := totalQuantityToSubstitute min: (aShoppingList storageNeedOf: category).
		otherCategory := self findNonPerishableSubstitutionFor: category.
		
		aShoppingList decreaseStorageNeedOf: category by: quantityToSubstitute.
		aShoppingList addStorageNeedOf: otherCategory quantity: quantityToSubstitute.
		
		totalQuantityToSubstitute := totalQuantityToSubstitute - quantityToSubstitute ]
]

{ #category : 'accessing' }
FEBHousehold >> substitutionList: aDictionary [

	substitutionList := aDictionary 
]

{ #category : 'as yet unclassified' }
FEBHousehold >> timeThreshold [

	^ strategy timeThreshold
]

{ #category : 'accessing' }
FEBHousehold >> totalUsableFoodQuantity [

	^ inventory nonExpiredBatches
		sum: [ :each | each quantity ]
		ifEmpty: [ 0 ]
]

{ #category : 'as yet unclassified' }
FEBHousehold >> updateHungerMemoryAfterEating: aCollectionOfCategories [

	aCollectionOfCategories size < dailyNeed 
		ifTrue: [ hungerMemory := hungerMemory + 1 ]
		ifFalse: [ hungerMemory := 0 ]
]

{ #category : 'as yet unclassified' }
FEBHousehold >> updateSatisfactionMemory [

	self isSatisfied
		ifTrue: [ satisfactionMemory := satisfactionMemory + 1 ] 
		ifFalse: [ satisfactionMemory := 0 ]
]
