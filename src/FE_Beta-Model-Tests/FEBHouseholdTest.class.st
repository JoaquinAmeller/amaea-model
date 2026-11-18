Class {
	#name : 'FEBHouseholdTest',
	#superclass : 'TestCase',
	#instVars : [
		'household',
		'animalProteins',
		'fruitsAndVegetables',
		'stapleFood',
		'processedFood',
		'dairy'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBHouseholdTest >> eat: anArrayOfAssociations [
	"On the next time step, give the household exactly this food, category -> quantity, and let it eat"

	household cormasModel simulationContext currentTimeStep:
		household currentTimeStep + 1.
	self emptyTheInventory.
	anArrayOfAssociations do: [ :each |
			each value > 0 ifTrue: [
					household inventory addBatch:
						(FEBFoodBatch
							 category: each key
							 quantity: each value
							 fridge: false) ] ].
	household consumeFood
]

{ #category : 'helpers' }
FEBHouseholdTest >> eat: aQuantity of: aCategory [
	"Give the household exactly this food and let it eat"

	self eat: { (aCategory -> aQuantity) }
]

{ #category : 'helpers' }
FEBHouseholdTest >> emptyTheInventory [

	household inventory batches removeAll
]

{ #category : 'running' }
FEBHouseholdTest >> setUp [
	"A household of one person needing 10 meals a day, with an empty inventory and the model's substitution list"

	| model |
	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	animalProteins := model foodCategoryNamed: 'Animal proteins'.
	fruitsAndVegetables := model foodCategoryNamed:
		                       'Fruits and vegetables'.
	stapleFood := model foodCategoryNamed: 'Staple food'.
	processedFood := model foodCategoryNamed: 'Processed food'.
	dairy := model foodCategoryNamed: 'Dairy'.

	household := model newEntity: FEBHousehold.
	household instVarNamed: #householdSize put: 1.
	household instVarNamed: #dailyNeed put: 10.
	household foodPreferenceProportions: {
			(stapleFood -> 0.5).
			(fruitsAndVegetables -> 0.3).
			(animalProteins -> 0.2) } asDictionary.
	model initializeSubstitutionList.
	self emptyTheInventory
]

{ #category : 'tests' }
FEBHouseholdTest >> testAFullHouseholdIsNotHungryTheNextDayIfItHasFood [

	self eat: 10 of: stapleFood.
	self assert: household isFull.

	self eat: 3 of: stapleFood.
	self assert: household isHungry.

	self eat: 10 of: stapleFood.
	self assert: household isFull
]

{ #category : 'tests' }
FEBHouseholdTest >> testAWeekOfEatingEveryPreferredFoodIsAHealthyDiet [

	7 timesRepeat: [
			self eat: {
					(stapleFood -> 5).
					(fruitsAndVegetables -> 3).
					(animalProteins -> 2) } ].

	self assert: household isHavingHealthyDiet
]

{ #category : 'tests' }
FEBHouseholdTest >> testAWeekWithoutFruitsAndVegetablesIsNotAHealthyDiet [

	7 timesRepeat: [
			self eat: {
					(stapleFood -> 8).
					(animalProteins -> 2) } ].

	self deny: household isHavingHealthyDiet
]

{ #category : 'tests' }
FEBHouseholdTest >> testAboutSixtyGramsOfProteinAPersonIsAdequate [
	"2 meals of animal proteins are 74 grams of protein"

	self eat: 2 of: animalProteins.

	self assert: household isProteinAdequate
]

{ #category : 'tests' }
FEBHouseholdTest >> testAboutTwoThousandKilocaloriesAPersonIsAdequate [
	"8 meals of staple food are 2080 kilocalories"

	self eat: 8 of: stapleFood.

	self assert: household isCaloricAdequate
]

{ #category : 'tests' }
FEBHouseholdTest >> testChangingItsFoodPreferenceKeepsItsFood [
	"The food bought for the old preference stays: only what the household prefers from now on changes"

	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 20 fridge: false).
	household preferBalancedDiet.
	self assert: household inventory totalQuantity equals: 20.
	self
		assert: (household preferenceOf: fruitsAndVegetables)
		equals: 3 / 10
]

{ #category : 'tests' }
FEBHouseholdTest >> testEveryHouseholdHasExactlyOneCaloricAdequacyLevel [

	0 to: 10 do: [ :meals |
			self eat: meals of: processedFood.
			self
				assert: (self trueIn: {
							 household isCaloricSeverelyInadequate.
							 household isCaloricInadequate.
							 household isCaloricAdequate.
							 household isCaloricExcess }) = 1
				description: meals printString
					, ' meals of processed food give no single caloric level' ]
]

{ #category : 'tests' }
FEBHouseholdTest >> testEveryHouseholdHasExactlyOneProteinAdequacyLevel [

	0 to: 10 do: [ :meals |
			self eat: meals of: animalProteins.
			self
				assert: (self trueIn: {
							 household isProteinSeverelyInadequate.
							 household isProteinInadequate.
							 household isProteinAdequate }) = 1
				description: meals printString
					, ' meals of animal proteins give no single protein level' ]
]

{ #category : 'tests' }
FEBHouseholdTest >> testEveryHouseholdIsEitherHungryUnsatiatedOrFull [

	0 to: 10 do: [ :meals |
			self eat: meals of: stapleFood.
			self
				assert: (self trueIn: {
							 household isHungry.
							 household isUnsatiated.
							 household isFull }) = 1
				description:
				meals printString
				, ' meals out of 10 give no single satiety level' ]
]

{ #category : 'tests' }
FEBHouseholdTest >> testFoodSpoilingTonightIsNotCountedForTomorrow [
	"Households shop after eating, for the next day. Fruits and vegetables in their last day will be gone tomorrow."

	| shoppingList |
	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 30 fridge: false).
	household inventory addBatch: (FEBFoodBatch
			 category: fruitsAndVegetables
			 quantity: 18
			 fridge: false
			 remainingDays: 1).
	household inventory addBatch:
		(FEBFoodBatch category: animalProteins quantity: 6 fridge: true).
	household inventory addBatch:
		(FEBFoodBatch category: animalProteins quantity: 6 fridge: false).

	shoppingList := household buildShoppingList.

	self assert: household shouldGoShopping.
	self
		assert: (shoppingList essentialNeedOf: fruitsAndVegetables)
		equals: 3.
	self
		assert: (shoppingList storageNeedOf: fruitsAndVegetables)
		equals: 15
]

{ #category : 'tests' }
FEBHouseholdTest >> testFridgeFoodThatDoesNotFitIsReplacedLeastPreferredFirst [
	"Storage for 5 days is 15 animal proteins and 10 dairy, but the fridge holds 6. The 19 meals that do not fit are taken from dairy, the least preferred, before animal proteins, and replaced by staple food."

	| shoppingList |
	household foodPreferenceProportions: {
			(stapleFood -> 0.5).
			(animalProteins -> 0.3).
			(dairy -> 0.2) } asDictionary.
	self emptyTheInventory.

	shoppingList := household buildShoppingList.

	self assert: (shoppingList storageNeedOf: animalProteins) equals: 6.
	self assert: (shoppingList storageNeedOf: dairy) equals: 0.
	self assert: (shoppingList storageNeedOf: stapleFood) equals: 25 + 19
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenEnoughOfEveryPreferredFood [

	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 30 fridge: false).
	household inventory addBatch:
		(FEBFoodBatch
			 category: fruitsAndVegetables
			 quantity: 18
			 fridge: false).
	household inventory addBatch:
		(FEBFoodBatch category: animalProteins quantity: 6 fridge: true).
	household inventory addBatch:
		(FEBFoodBatch category: animalProteins quantity: 6 fridge: false).

	self deny: household buildShoppingList hasAnyNeeds
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenLotsOfFood [
	"Lots of staple food covers today and storage for staple food only. The other preferred foods are still needed, for today and for storage"

	| shoppingList |
	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 10000 fridge: false).

	shoppingList := household buildShoppingList.

	self assert: (shoppingList essentialNeedOf: stapleFood) equals: 0.
	self
		assert: (shoppingList essentialNeedOf: fruitsAndVegetables)
		equals: 3.
	self assert: (shoppingList essentialNeedOf: animalProteins) equals: 2.

	self
		assert: (shoppingList storageNeedOf: fruitsAndVegetables)
		equals: 15.
	self assert: (shoppingList storageNeedOf: animalProteins) equals: 6
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenNoFood [
	"One day of food is essential, split by the preferences. Five more days go to storage: 25 Staple food, 15 Fruits and vegetables and 10 Animal proteins, but only 6 Animal proteins fit in the fridge, so the other 4 become Staple food."

	| shoppingList |
	shoppingList := household buildShoppingList.

	self assert: (shoppingList essentialNeedOf: stapleFood) equals: 5.
	self
		assert: (shoppingList essentialNeedOf: fruitsAndVegetables)
		equals: 3.
	self assert: (shoppingList essentialNeedOf: animalProteins) equals: 2.

	self assert: (shoppingList storageNeedOf: stapleFood) equals: 29.
	self
		assert: (shoppingList storageNeedOf: fruitsAndVegetables)
		equals: 15.
	self assert: (shoppingList storageNeedOf: animalProteins) equals: 6
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenSomeFood [
	"4 meals of staple food cover 4 of today's 5. The other foods are all still needed for today. None of it is beyond today's share, so storage is the same as with no food."

	| shoppingList |
	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 4 fridge: false).

	shoppingList := household buildShoppingList.

	self assert: (shoppingList essentialNeedOf: stapleFood) equals: 1.
	self
		assert: (shoppingList essentialNeedOf: fruitsAndVegetables)
		equals: 3.
	self assert: (shoppingList essentialNeedOf: animalProteins) equals: 2.

	self assert: (shoppingList storageNeedOf: stapleFood) equals: 29.
	self
		assert: (shoppingList storageNeedOf: fruitsAndVegetables)
		equals: 15.
	self assert: (shoppingList storageNeedOf: animalProteins) equals: 6
]

{ #category : 'helpers' }
FEBHouseholdTest >> trueIn: aCollectionOfBooleans [

	^ aCollectionOfBooleans count: [ :each | each ]
]
