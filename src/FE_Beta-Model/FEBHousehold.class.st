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
		'history',
		'trip'
	],
	#classInstVars : [
		'minHouseholdSize',
		'maxHouseholdSize',
		'availableMoneyPerStep',
		'availableTimePerStep',
		'fridgeCapacity',
		'consumptionStrategySymbol'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBHousehold class >> availableMoneyPerStep [
	<parameterIntegerMin: 1 max: 10000 default: 100>
	^ availableMoneyPerStep
]

{ #category : 'accessing' }
FEBHousehold class >> availableMoneyPerStep: anObject [

	availableMoneyPerStep := anObject
]

{ #category : 'accessing' }
FEBHousehold class >> availableTimePerStep [
	<parameterFloatMin: 0 max: 24 default: 2>
	^ availableTimePerStep
]

{ #category : 'accessing' }
FEBHousehold class >> availableTimePerStep: anObject [

	availableTimePerStep := anObject
]

{ #category : 'accessing' }
FEBHousehold class >> consumptionStrategy [

	| strategyClass |
	
	strategyClass := FEBFoodConsumptionStrategy allSubclasses
		detect: [ :each | each strategyName asSymbol = consumptionStrategySymbol ].
	
	^ strategyClass new.
]

{ #category : 'accessing' }
FEBHousehold class >> consumptionStrategySymbol [
	<parameter: 'Consumption strategy' values: #(#'No spoil weirdo' #'Some fuck about spoil') default: #'No spoil weirdo'>
	
	^ consumptionStrategySymbol
]

{ #category : 'accessing' }
FEBHousehold class >> consumptionStrategySymbol: aSymbol [

	consumptionStrategySymbol := aSymbol
]

{ #category : 'accessing' }
FEBHousehold class >> fridgeCapacity [
	<parameterIntegerMin: 0 max: 10000 default: 6>
	^ fridgeCapacity
]

{ #category : 'accessing' }
FEBHousehold class >> fridgeCapacity: anObject [

	fridgeCapacity := anObject
]

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
	"Add, for each preferred category, the meals missing from its share of tomorrow's need. Food that will be expired tomorrow does not count."

	(self mealsPerCategoryFor: dailyNeed) keysAndValuesDo: [
			:category
			:meals |
			| missingMeals |
			missingMeals := meals
			                -
			                (inventory quantityLeftTomorrowInCategory: category).
			missingMeals > 0 ifTrue: [
				aShoppingList addEssentialNeedOf: category quantity: missingMeals ] ]
]

{ #category : 'adding' }
FEBHousehold >> addStorageNeedsToTheShoppingList: aShoppingList [
	"Add, for each preferred category, the meals missing from its share of the following days' needs, counting only the food left tomorrow beyond its share of tomorrow's need. Then replace the perishable food that will not fit in the fridge."

	| storageHorizon oneDayOfMeals |
	storageHorizon := 5.
	oneDayOfMeals := self mealsPerCategoryFor: dailyNeed.

	(self mealsPerCategoryFor: dailyNeed * storageHorizon)
		keysAndValuesDo: [ :category :meals |
				| storedMeals missingMeals |
				storedMeals := (inventory quantityLeftTomorrowInCategory: category)
				               - (oneDayOfMeals at: category) max: 0.
				missingMeals := meals - storedMeals.
				missingMeals > 0 ifTrue: [
					aShoppingList addStorageNeedOf: category quantity: missingMeals ] ].

	self substitutePerishableFoodThatWontFitInFridge: aShoppingList
]

{ #category : 'aspects' }
FEBHousehold >> aspectCaloricAdequacyIndicator: look [
	<aspect>
	self aspectDefault: look.
	look image: (self householdImageColored: self caloricAdequacyColor)
]

{ #category : 'aspects' }
FEBHousehold >> aspectDefault: look [
	<aspect>
	look
		image: 'household';
		size: self sizeOfPovBasedOnHouseholdSize;
		shape: #square
]

{ #category : 'aspects' }
FEBHousehold >> aspectHealthyDiet: look [
	<aspect>
	self aspectDefault: look.
	look image: (self householdImageColored: self healthyDietColor)
]

{ #category : 'aspects' }
FEBHousehold >> aspectProteinAdequacyIndicator: look [
	<aspect>
	self aspectDefault: look.
	look image: (self householdImageColored: self proteinAdequacyColor)
]

{ #category : 'aspects' }
FEBHousehold >> aspectSatietyIndicator: look [
	<aspect>
	self aspectDefault: look.
	look image: (self householdImageColored: self satietyIndicatorColor)
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

{ #category : 'colors' }
FEBHousehold >> caloricAdequacyColor [

	history isEmpty ifTrue: [ ^ CMColor gray ].
	^ self colorOfLevel:
		  (self caloricAdequacyLevelOf: self caloricAdequacyScore)
]

{ #category : 'indicators' }
FEBHousehold >> caloricAdequacyLevelOf: aScore [

	aScore < 0.8 ifTrue: [ ^ #severelyInadequate ].
	aScore < 1 ifTrue: [ ^ #inadequate ].
	aScore < 1.2 ifTrue: [ ^ #adequate ].
	^ #excess
]

{ #category : 'indicators' }
FEBHousehold >> caloricAdequacyLevelOn: aDay [

	^ self caloricAdequacyLevelOf: (self caloricAdequacyScoreOn: aDay)
]

{ #category : 'testing' }
FEBHousehold >> caloricAdequacyScore [
	"The caloric adequacy of the latest recorded day. A household that has not eaten yet counts as adequate."

	history isEmpty ifTrue: [ ^ 1 ].
	^ self caloricAdequacyScoreOn: history lastDay
]

{ #category : 'testing' }
FEBHousehold >> caloricAdequacyScoreOn: aDay [
	"The kilocalories eaten that day, against 2000 per person"

	^ (aDay meals sum: [ :each | each category kilocaloriesPerPortion ])
	  / (2000 * householdSize)
]

{ #category : 'indicators' }
FEBHousehold >> colorOfLevel: aLevel [
	"Answer the colour showing an indicator's level: red when it is bad, orange when it is short, green when it is right, purple when it is too much"

	(#( #hungry #severelyInadequate ) includes: aLevel) ifTrue: [
		^ CMColor red ].
	(#( #unsatiated #inadequate ) includes: aLevel) ifTrue: [
		^ CMColor gold ].
	(#( #full #adequate ) includes: aLevel) ifTrue: [
		^ CMColor green ].
	^ CMColor purple
]

{ #category : 'consuming' }
FEBHousehold >> consumeFood [
	"Eat today's meals, record them in today's record and answer them"

	<action>
	| meals |
	meals := self class consumptionStrategy mealsEatenFirstBy: self.
	meals addAll: (self eatMealsByPreference: dailyNeed - meals size).

	self today addMeals: meals.

	self updateHungerMemoryAfterEating: meals.

	^ meals
]

{ #category : 'accessing' }
FEBHousehold >> dailyNeed [

	^ dailyNeed
]

{ #category : 'consuming' }
FEBHousehold >> eat: aNumberOfMeals mealsFromBatch: aBatch as: aReason [

	^ (1 to: aNumberOfMeals) asOrderedCollection collect: [ :each |
			  inventory extractOneUnitFromBatch: aBatch.
			  FEBMeal category: aBatch category reason: aReason ]
]

{ #category : 'consuming' }
FEBHousehold >> eat: aNumberOfMeals mealsOf: aCategory as: aReason [
	"Eat up to aNumberOfMeals of aCategory, soonest-expiring batches first. Answer the meals eaten."

	| meals |
	meals := OrderedCollection new.
	((inventory batchesOfCategory: aCategory) sorted: [ :a :b |
		 a remainingDays <= b remainingDays ]) do: [ :batch |
			meals addAll: (self
					 eat: (aNumberOfMeals - meals size min: batch quantity)
					 mealsFromBatch: batch
					 as: aReason) ].
	^ meals
]

{ #category : 'consuming' }
FEBHousehold >> eat: aNumberOfMeals substitutesFor: aCategory [
	"Eat up to aNumberOfMeals in place of aCategory, following substitutionList from one substitute to the next until enough is eaten or the list ends. Answer the meals eaten."

	| meals substitute |
	meals := OrderedCollection new.
	substitute := substitutionList at: aCategory ifAbsent: [ nil ].
	[ substitute isNotNil and: [ meals size < aNumberOfMeals ] ]
		whileTrue: [
				meals addAll: (self
						 eat: aNumberOfMeals - meals size
						 mealsOf: substitute
						 as: #substitute).
				substitute := substitutionList at: substitute ifAbsent: [ nil ] ].
	^ meals
]

{ #category : 'consuming' }
FEBHousehold >> eatAnyFood: aNumberOfMeals [
	"Eat up to aNumberOfMeals of whatever food is left, preferred categories first. Answer the meals eaten."

	| meals categories |
	meals := OrderedCollection new.
	"Categories in the order of the inventory, so that categories with the same rank keep the same order from one run to the next"
	categories := (inventory nonExpiredBatches collect: [ :each |
			               each category ]) asOrderedCollection
		              removeDuplicates;
		              yourself.
	(categories sorted: [ :a :b |
		 (self preferenceRankOf: a) <= (self preferenceRankOf: b) ]) do: [
			:category |
			meals addAll:
				(self
					 eat: aNumberOfMeals - meals size
					 mealsOf: category
					 as: #leftover) ].
	^ meals
]

{ #category : 'consuming' }
FEBHousehold >> eatFoodInItsLastDay [
	"Eat the food that will be expired tomorrow, up to the daily need, preferred categories first. Answer the meals eaten."

	| meals |
	meals := OrderedCollection new.
	(inventory batchesExpiringTomorrow sorted: [ :a :b |
			 (self preferenceRankOf: a category)
			 <= (self preferenceRankOf: b category) ]) do: [ :batch |
			meals addAll: (self
					 eat: (dailyNeed - meals size min: batch quantity)
					 mealsFromBatch: batch
					 as: #lastDay) ].
	^ meals
]

{ #category : 'consuming' }
FEBHousehold >> eatMealsByPreference: aNumberOfMeals [
	"Eat aNumberOfMeals split by foodPreferenceProportions. Every category eats its own share first. Then the meals a category could not eat go along substitutionList, to whatever food is left. Meals still missing come from any food left, so the household only eats less when it runs out of food. Answer the meals eaten."

	| meals missingMeals |
	meals := OrderedCollection new.
	missingMeals := OrderedDictionary new.
	(self mealsPerCategoryFor: aNumberOfMeals) keysAndValuesDo: [
			:category
			:share |
			| ownMeals |
			ownMeals := self eat: share mealsOf: category as: #ownShare.
			meals addAll: ownMeals.
			missingMeals at: category put: share - ownMeals size ].

	missingMeals keysAndValuesDo: [ :category :missing |
		meals addAll: (self eat: missing substitutesFor: category) ].

	meals addAll: (self eatAnyFood: aNumberOfMeals - meals size).
	^ meals
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
FEBHousehold >> foodPreferenceProportions [

	^ foodPreferenceProportions
]

{ #category : 'accessing' }
FEBHousehold >> foodPreferenceProportions: aDictionary [

	| orderedDict |
	"Most preferred first. Equal preferences are ordered by name, so that they keep the same order from one run to the next"
	orderedDict := (aDictionary associations sorted: [ :a :b |
			                a value > b value or: [
				                a value = b value and: [ a key name <= b key name ] ] ])
		               asOrderedDictionary.

	foodPreferenceProportions := orderedDict.

	"Inventory is initialized when foodPreference is set because it needs to have food for one day, and we must specify the category of that food"
	self initializeInventory
]

{ #category : 'asserting' }
FEBHousehold >> goShopping [

	<action>
	| shoppingList |
	self resetRemainingTimeAndMoney.
	shoppingList := self buildShoppingList.
	shoppingStrategy shopFor: self using: shoppingList.
	self today
		recordShoppingWithMoney: availableMoneyPerStep
		time: availableTimePerStep
		timeSpent: availableTimePerStep - remainingTime.
	self reconsiderPreference
]

{ #category : 'asserting' }
FEBHousehold >> hasFoodForOneDay [	

	^ inventory totalQuantity >= (1 * dailyNeed)
]

{ #category : 'asserting' }
FEBHousehold >> hasPreferredFoodForOneDay [
	"Answer whether, tomorrow, the household will still have its share of every preferred category"

	^ (self mealsPerCategoryFor: dailyNeed) associations allSatisfy: [
		  :each |
		  (inventory quantityLeftTomorrowInCategory: each key) >= each value ]
]

{ #category : 'colors' }
FEBHousehold >> healthyDietColor [

	^ self isHavingHealthyDiet
		ifTrue: [ CMColor green ]
		ifFalse: [ CMColor red ]
]

{ #category : 'actions' }
FEBHousehold >> highlightTrip [
	"Highlight my trip, which hides the others"

	<action>
	self unhighlightTrip.
	self trip highlight
]

{ #category : 'history' }
FEBHousehold >> history [

	^ history
]

{ #category : 'aspects' }
FEBHousehold >> householdImageColored: aColor [
	| image |
	image := CMImage named: 'household'.
	image tint: (aColor alpha: 0.6).
	^ image
]

{ #category : 'accessing' }
FEBHousehold >> householdSize [

	^ householdSize
]

{ #category : 'initialization' }
FEBHousehold >> initialize [

	super initialize.

	householdSize := self
		                 randomIntegerBetween: self class minHouseholdSize
		                 and: self class maxHouseholdSize.

	foodPreferenceProportions := OrderedDictionary new.

	satisfactionMemory := 2.
	hungerMemory := 0.

	"10 meals times the number of persons in the household"
	dailyNeed := 10 * householdSize.

	"available for getting food"
	availableMoneyPerStep := self class availableMoneyPerStep.
	availableTimePerStep := self class availableTimePerStep hours.

	"We need to do this to make sure that everyone is satisfied at init -> for the probe to work"
	self resetRemainingTimeAndMoney.

	"by default households prefers to save money just to avoid it to be nil.
	Init in the model will assign the proportions of preferences"
	self beMoneySaver.

	shoppingStrategy := FEBSimpleShoppingStrategy new.
	history := FEBHistory new
]

{ #category : 'initialization' }
FEBHousehold >> initializeInventory [

	inventory := FEBFoodInventory new.
	inventory fridgeCapacity: self class fridgeCapacity.
	
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

{ #category : 'testing' }
FEBHousehold >> isCaloricAdequate [

	^ (self caloricAdequacyLevelOf: self caloricAdequacyScore)
	  = #adequate
]

{ #category : 'testing' }
FEBHousehold >> isCaloricExcess [

	^ (self caloricAdequacyLevelOf: self caloricAdequacyScore) = #excess
]

{ #category : 'testing' }
FEBHousehold >> isCaloricInadequate [

	^ (self caloricAdequacyLevelOf: self caloricAdequacyScore)
	  = #inadequate
]

{ #category : 'testing' }
FEBHousehold >> isCaloricSeverelyInadequate [

	^ (self caloricAdequacyLevelOf: self caloricAdequacyScore)
	  = #severelyInadequate
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isDesperateSaver [

	^ strategy isDesperateSaver
]

{ #category : 'testing' }
FEBHousehold >> isFull [

	^ (self satietyLevelOf: self satietyScore) = #full
]

{ #category : 'testing' }
FEBHousehold >> isHavingHealthyDiet [

	history isEmpty ifTrue: [ ^ false ].
	^ self isHavingHealthyDietOn: history lastDay
]

{ #category : 'testing' }
FEBHousehold >> isHavingHealthyDietOn: aDay [
	"Average consumption of at least one unit each of fruits & vegetables, meat, and staple food per day over the 7 days up to aDay"

	| week foodNames allFoodCategoryNames |
	week := (history daysUpTo: aDay) last:
		        (7 min: (history daysUpTo: aDay) size).

	foodNames := week flatCollect: [ :day |
		             day meals collect: [ :each | each category name ] ].

	"DANGER! This relies on foodPreferenceProportions to contain ALL the categories and not just some of them"
	allFoodCategoryNames := (foodPreferenceProportions keys collect: [
		                         :category | category name ]) asSet.

	^ allFoodCategoryNames allSatisfy: [ :name |
		  (foodNames count: [ :each | each = name ]) >= 7 ]
]

{ #category : 'testing' }
FEBHousehold >> isHungry [

	^ (self satietyLevelOf: self satietyScore) = #hungry
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isMoneySaver [

	^ strategy isMoneySaver
]

{ #category : 'indicators' }
FEBHousehold >> isPreferenceFor: aCategory fulfilledOn: aDay [
	"Answer whether the share of the daily need eaten of aCategory that day, whatever the reason each meal was eaten, is at least the household's preference for it"

	^ (self preferenceDifferenceOf: aCategory on: aDay) >= 0
]

{ #category : 'testing' }
FEBHousehold >> isProteinAdequate [

	^ (self proteinAdequacyLevelOf: self proteinAdequacyScore)
	  = #adequate
]

{ #category : 'testing' }
FEBHousehold >> isProteinInadequate [

	^ (self proteinAdequacyLevelOf: self proteinAdequacyScore)
	  = #inadequate
]

{ #category : 'testing' }
FEBHousehold >> isProteinSeverelyInadequate [

	^ (self proteinAdequacyLevelOf: self proteinAdequacyScore)
	  = #severelyInadequate
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isRichBastard [

	^ strategy isRichBastard
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isTimeSaver [

	^ strategy isTimeSaver
]

{ #category : 'testing' }
FEBHousehold >> isUnsatiated [

	^ (self satietyLevelOf: self satietyScore) = #unsatiated
]

{ #category : 'consuming' }
FEBHousehold >> mealsPerCategoryFor: aNumberOfMeals [
	"Split aNumberOfMeals into whole meals per category, in the proportions of foodPreferenceProportions. The largest remainder method makes the meals add up to aNumberOfMeals, and a tie goes to the preferred category."

	| exactShares meals leftover |
	exactShares := foodPreferenceProportions collect: [ :proportion |
		               proportion asMinimalDecimalFraction * aNumberOfMeals ].
	meals := exactShares collect: [ :share | share floor ].
	leftover := aNumberOfMeals - meals sum.

	((exactShares keys sorted: [ :a :b |
		  (exactShares at: a) fractionPart
		  >= (exactShares at: b) fractionPart ]) first: leftover) do: [
		:category | meals at: category put: (meals at: category) + 1 ].
	^ meals
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

{ #category : 'indicators' }
FEBHousehold >> preferenceDifferenceOf: aCategory on: aDay [
	"Answer the share of the daily need eaten of aCategory that day, less the household's preference for it: negative when it ate less than it prefers"

	^ (aDay numberOfMealsOf: aCategory) / dailyNeed
	  - (self preferenceOf: aCategory)
]

{ #category : 'indicators' }
FEBHousehold >> preferenceOf: aCategory [
	"Answer the share of the daily need the household prefers to eat of aCategory, as an exact fraction, 0 for a category it does not prefer"

	^ (foodPreferenceProportions at: aCategory ifAbsent: [ 0 ])
		  asMinimalDecimalFraction
]

{ #category : 'consuming' }
FEBHousehold >> preferenceRankOf: aCategory [
	"Answer the position of aCategory in the preferences. A category outside them comes after all of them."

	^ foodPreferenceProportions keys
		  indexOf: aCategory
		  ifAbsent: [ foodPreferenceProportions size + 1 ]
]

{ #category : 'colors' }
FEBHousehold >> proteinAdequacyColor [

	history isEmpty ifTrue: [ ^ CMColor gray ].
	^ self colorOfLevel:
		  (self proteinAdequacyLevelOf: self proteinAdequacyScore)
]

{ #category : 'indicators' }
FEBHousehold >> proteinAdequacyLevelOf: aScore [

	aScore < 0.8 ifTrue: [ ^ #severelyInadequate ].
	aScore < 1 ifTrue: [ ^ #inadequate ].
	^ #adequate
]

{ #category : 'indicators' }
FEBHousehold >> proteinAdequacyLevelOn: aDay [

	^ self proteinAdequacyLevelOf: (self proteinAdequacyScoreOn: aDay)
]

{ #category : 'testing' }
FEBHousehold >> proteinAdequacyScore [
	"The protein adequacy of the latest recorded day. A household that has not eaten yet counts as adequate."

	history isEmpty ifTrue: [ ^ 1 ].
	^ self proteinAdequacyScoreOn: history lastDay
]

{ #category : 'testing' }
FEBHousehold >> proteinAdequacyScoreOn: aDay [
	"The grams of protein eaten that day, against 60 per person"

	^ (aDay meals sum: [ :each | each category proteinsPerPortion ])
	  / (60 * householdSize)
]

{ #category : 'buying' }
FEBHousehold >> receive: aCollectionOfBatches for: aPurchase [
	"Store the food of aPurchase, record how much of it went into the fridge, pay for it, and record it in today's record"

	aPurchase quantityInFridge: (aCollectionOfBatches
			 inject: 0
			 into: [ :sum :each | sum + (self store: each) ]).
	remainingMoney := remainingMoney - aPurchase price.
	self today addPurchase: aPurchase
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

{ #category : 'colors' }
FEBHousehold >> satietyIndicatorColor [

	history isEmpty ifTrue: [ ^ CMColor gray ].
	^ self colorOfLevel: (self satietyLevelOf: self satietyScore)
]

{ #category : 'indicators' }
FEBHousehold >> satietyLevelOf: aScore [

	aScore < 0.8 ifTrue: [ ^ #hungry ].
	aScore < 1 ifTrue: [ ^ #unsatiated ].
	^ #full
]

{ #category : 'indicators' }
FEBHousehold >> satietyLevelOn: aDay [

	^ self satietyLevelOf: (self satietyScoreOn: aDay)
]

{ #category : 'testing' }
FEBHousehold >> satietyScore [
	"The satiety of the latest recorded day. A household that has not eaten yet counts as full."

	history isEmpty ifTrue: [ ^ 1 ].
	^ self satietyScoreOn: history lastDay
]

{ #category : 'testing' }
FEBHousehold >> satietyScoreOn: aDay [

	^ aDay meals size / dailyNeed
]

{ #category : 'accessing' }
FEBHousehold >> shapeOfPovBasedOnStrategy [

	^ strategy shapeOfPov
]

{ #category : 'asserting' }
FEBHousehold >> shouldGoShopping [

	^ self hasFoodForOneDay not or: [ self hasPreferredFoodForOneDay not]
]

{ #category : 'accessing' }
FEBHousehold >> sizeOfPovBasedOnHouseholdSize [

	| min max |
	min := self class minHouseholdSize.
	max := self class maxHouseholdSize.
	
	min = max ifTrue: [ ^ 1 ].
	
	^ 0.5 + (householdSize - min / (max - min) asFloat * 0.5)
]

{ #category : 'accessing' }
FEBHousehold >> step [

	inventory emptyTheTrashbin.

	"Households eat in the morning and then they consider buying food for the next day"
	self consumeFood.

	self shouldGoShopping ifTrue: [ self goShopping ].

	inventory becomeOneDayOlder.
	self today recordEndOfDayOf: inventory
]

{ #category : 'buying' }
FEBHousehold >> store: aBatch [
	"Put aBatch in the inventory. Food meant for the fridge goes in only as far as the fridge has room, and the rest is kept outside it. Answer the quantity put in the fridge."

	| freeSpace quantityInFridge |
	freeSpace := inventory freeFridgeSpace.
	quantityInFridge := aBatch isInFridge
		                    ifTrue: [ aBatch quantity min: freeSpace ]
		                    ifFalse: [ 0 ].
	(aBatch isInFridge and: [ aBatch quantity > freeSpace ]) ifTrue: [
			freeSpace > 0 ifTrue: [
				inventory addBatch: (aBatch extractQuantity: freeSpace) ].
			aBatch moveOutsideFridge ].
	inventory addBatch: aBatch.
	^ quantityInFridge
]

{ #category : 'accessing' }
FEBHousehold >> strategy [

	^ strategy
]

{ #category : 'adding' }
FEBHousehold >> substitutePerishableFoodThatWontFitInFridge: aShoppingList [

	| perishableCategories totalQuantityOfPerishable totalQuantityToSubstitute quantityToSubstitute otherCategory |
	perishableCategories := aShoppingList storageNeeds keys select: [
		                        :category | category shouldBeStoredInFridge ].

	totalQuantityOfPerishable := perishableCategories sum: [ :category |
		                             aShoppingList storageNeedOf: category ].

	totalQuantityToSubstitute := totalQuantityOfPerishable
	                             - inventory freeFridgeSpace max: 0.

	"We sort them to make sure that we will be substituting the least wanted categories first"
	perishableCategories := perishableCategories sorted: [ :a :b |
		                        (foodPreferenceProportions at: a)
		                        < (foodPreferenceProportions at: b) ].

	perishableCategories do: [ :category |
			totalQuantityToSubstitute <= 0 ifTrue: [ ^ self ].

			quantityToSubstitute := totalQuantityToSubstitute min:
				                        (aShoppingList storageNeedOf: category).
			otherCategory := self findNonPerishableSubstitutionFor: category.

			aShoppingList
				decreaseStorageNeedOf: category
				by: quantityToSubstitute.
			aShoppingList
				addStorageNeedOf: otherCategory
				quantity: quantityToSubstitute.

			totalQuantityToSubstitute := totalQuantityToSubstitute
			                             - quantityToSubstitute ]
]

{ #category : 'accessing' }
FEBHousehold >> substitutionList: aDictionary [

	substitutionList := aDictionary 
]

{ #category : 'as yet unclassified' }
FEBHousehold >> timeThreshold [

	^ strategy timeThreshold
]

{ #category : 'history' }
FEBHousehold >> today [
	"Answer the record of the current time step, where everything the household does now is recorded"

	^ history
		  dayAt: self currentTimeStep
		  ifAbsentPut: [ FEBHouseholdDay step: self currentTimeStep ]
]

{ #category : 'accessing' }
FEBHousehold >> totalUsableFoodQuantity [

	^ inventory nonExpiredBatches
		sum: [ :each | each quantity ]
		ifEmpty: [ 0 ]
]

{ #category : 'accessing' }
FEBHousehold >> trip [
	"Answer the network of the legs I walked today. It lasts from day to day, so that it stays highlighted, while its legs change"

	^ trip ifNil: [
			  trip := (self cormasModel newEntity: FEBTrip)
				          household: self;
				          yourself ]
]

{ #category : 'actions' }
FEBHousehold >> unhighlightTrip [
	"Leave no trip highlighted, which shows them all"

	<action>
	(self cormasModel entitiesOfClass: FEBTrip) do: [ :each |
		each unhighlight ]
]

{ #category : 'as yet unclassified' }
FEBHousehold >> updateHungerMemoryAfterEating: aCollectionOfCategories [

	aCollectionOfCategories size < dailyNeed 
		ifTrue: [ hungerMemory := hungerMemory + 1 ]
		ifFalse: [ hungerMemory := 0 ]
]
