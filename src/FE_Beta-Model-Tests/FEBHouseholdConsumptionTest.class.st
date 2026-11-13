"
I test how a `FEBHousehold` eats its daily meals in `FEBHousehold>>#consumeFood`.

## Responsibility:

- Check that a household eats each food category in the proportion given by its food preferences.
- Check that missing food is replaced along the household's substitution list, and that the household eats less when no substitute is left.
- Check how each consumption strategy (`FEBNoSpoilWeirdoStrategy`, `FEBSomeFuckAboutSpoilStrategy`) deals with food that is about to expire.

## Collaborators:

- `FEBHousehold`: the household under test, created through a `FEBModel` because agents need a model.
- `FEBFoodCategory` and `FEBFoodBatch`: the food put into the household's inventory.

## Public API and Key Messages

- `setUp` builds a household with a daily need of 50 meals, the preferences Animal proteins 0.5, Dairy 0.3, Fruits and vegetables 0.2, and an empty inventory.
- `add:of:expiringIn:` puts a batch into the inventory, and `mealsOf:in:` counts the meals of a category.

```smalltalk
FEBHouseholdConsumptionTest run: #testEatsEachCategoryInItsProportion
```

## Internal Representation

- `previousConsumptionStrategy` remembers the class-side strategy setting of `FEBHousehold`, which `tearDown` restores.
"
Class {
	#name : 'FEBHouseholdConsumptionTest',
	#superclass : 'TestCase',
	#instVars : [
		'household',
		'animalProteins',
		'dairy',
		'fruitsAndVegetables',
		'stapleFood',
		'processedFood',
		'previousConsumptionStrategy'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> add: aQuantity of: aCategory expiringIn: aNumberOfDays [

	household inventory addBatch: (FEBFoodBatch
			 category: aCategory
			 quantity: aQuantity
			 fridge: false
			 remainingDays: aNumberOfDays)
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> addAbundantFoodExpiringIn: aNumberOfDays [

	{
		animalProteins.
		dairy.
		fruitsAndVegetables } do: [ :each |
		self add: 100 of: each expiringIn: aNumberOfDays ]
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> initializeFoodCategories [

	animalProteins := FEBFoodCategory
		                  named: 'Animal proteins'
		                  shelfLifeInFridge: 5
		                  outsideFridge: 2.
	dairy := FEBFoodCategory
		         named: 'Dairy'
		         shelfLifeInFridge: 6
		         outsideFridge: 2.
	fruitsAndVegetables := FEBFoodCategory
		                       named: 'Fruits and vegetables'
		                       shelfLifeInFridge: 7
		                       outsideFridge: 3.
	stapleFood := FEBFoodCategory
		              named: 'Staple food'
		              shelfLifeInFridge: 30
		              outsideFridge: 30.
	processedFood := FEBFoodCategory
		                 named: 'Processed food'
		                 shelfLifeInFridge: 60
		                 outsideFridge: 60
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> mealsOf: aCategory in: aCollectionOfCategories [

	^ aCollectionOfCategories count: [ :each | each = aCategory ]
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> quantityOf: aCategory expiringIn: aNumberOfDays [

	^ (household inventory batches select: [ :each |
		   each category = aCategory and: [
			   each remainingDays = aNumberOfDays ] ])
		  sum: [ :each | each quantity ]
		  ifEmpty: [ 0 ]
]

{ #category : 'running' }
FEBHouseholdConsumptionTest >> setUp [

	super setUp.
	previousConsumptionStrategy := FEBHousehold consumptionStrategySymbol.
	self initializeFoodCategories.

	household := FEBModel new newEntity: FEBHousehold.
	self useDailyNeed: 50 preferences: {
			(animalProteins -> 0.5).
			(dairy -> 0.3).
			(fruitsAndVegetables -> 0.2) }.
	household substitutionList: {
			(animalProteins -> dairy).
			(dairy -> stapleFood).
			(fruitsAndVegetables -> stapleFood).
			(stapleFood -> processedFood) } asDictionary
]

{ #category : 'running' }
FEBHouseholdConsumptionTest >> tearDown [

	FEBHousehold consumptionStrategySymbol: previousConsumptionStrategy.
	super tearDown
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testEatsEachCategoryInItsProportion [

	| meals |
	self useSomeFuckAboutSpoil.
	self addAbundantFoodExpiringIn: 5.

	meals := household consumeFood.

	self assert: (self mealsOf: animalProteins in: meals) equals: 25.
	self assert: (self mealsOf: dairy in: meals) equals: 15.
	self assert: (self mealsOf: fruitsAndVegetables in: meals) equals: 10.
	self assert: meals size equals: 50
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testEatsLessWhenNoSubstituteIsLeft [

	| meals |
	self useSomeFuckAboutSpoil.
	self add: 10 of: animalProteins expiringIn: 5.
	self add: 15 of: dairy expiringIn: 5.
	self add: 10 of: fruitsAndVegetables expiringIn: 5.

	meals := household consumeFood.

	self assert: meals size equals: 35
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testEatsTheSoonestExpiringBatchOfACategoryFirst [

	self useSomeFuckAboutSpoil.
	self add: 100 of: animalProteins expiringIn: 5.
	self add: 100 of: fruitsAndVegetables expiringIn: 5.
	self add: 20 of: dairy expiringIn: 6.
	self add: 20 of: dairy expiringIn: 3.

	household consumeFood.

	self assert: (self quantityOf: dairy expiringIn: 3) equals: 5.
	self assert: (self quantityOf: dairy expiringIn: 6) equals: 20
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testMealsAddUpToTheDailyNeedWhenSharesAreNotWhole [
	"Shares of 10 meals: 3.5, 3, 1.5, 1.5 and 0.5. The two meals left after rounding down go to the most preferred of the categories with half a meal."

	| meals |
	self useSomeFuckAboutSpoil.
	self useDailyNeed: 10 preferences: {
			(animalProteins -> 0.35).
			(dairy -> 0.3).
			(fruitsAndVegetables -> 0.15).
			(stapleFood -> 0.15).
			(processedFood -> 0.05) }.
	self addAbundantFoodExpiringIn: 5.
	self add: 100 of: stapleFood expiringIn: 5.
	self add: 100 of: processedFood expiringIn: 5.

	meals := household consumeFood.

	self assert: meals size equals: 10.
	self assert: (self mealsOf: animalProteins in: meals) equals: 4.
	self assert: (self mealsOf: dairy in: meals) equals: 3.
	self
		assert: (self mealsOf: fruitsAndVegetables in: meals)
			+ (self mealsOf: stapleFood in: meals)
		equals: 3.
	self assert: (self mealsOf: processedFood in: meals) equals: 0
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testNoSpoilWeirdoEatsEachCategoryInItsProportionWhenNothingIsInItsLastDay [

	| meals |
	self useNoSpoilWeirdo.
	self addAbundantFoodExpiringIn: 5.

	meals := household consumeFood.

	self assert: (self mealsOf: animalProteins in: meals) equals: 25.
	self assert: (self mealsOf: dairy in: meals) equals: 15.
	self assert: (self mealsOf: fruitsAndVegetables in: meals) equals: 10
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testNoSpoilWeirdoEatsFoodInItsLastDayFirst [
	"The 20 Dairy meals in their last day come first. The other 30 meals are split by the preferences: 15, 9 and 6."

	| meals |
	self useNoSpoilWeirdo.
	self addAbundantFoodExpiringIn: 5.
	self add: 20 of: dairy expiringIn: 1.

	meals := household consumeFood.

	self assert: (self mealsOf: animalProteins in: meals) equals: 15.
	self assert: (self mealsOf: dairy in: meals) equals: 29.
	self assert: (self mealsOf: fruitsAndVegetables in: meals) equals: 6.
	self assert: (self quantityOf: dairy expiringIn: 1) equals: 0
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testNoSpoilWeirdoEatsThePreferredLastDayFoodWhenThereIsMoreThanTheDailyNeed [

	| meals |
	self useNoSpoilWeirdo.
	self add: 40 of: fruitsAndVegetables expiringIn: 1.
	self add: 40 of: animalProteins expiringIn: 1.

	meals := household consumeFood.

	self assert: (self mealsOf: animalProteins in: meals) equals: 40.
	self assert: (self mealsOf: fruitsAndVegetables in: meals) equals: 10
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testSomeFuckAboutSpoilKeepsTheProportionsWhenFoodIsInItsLastDay [

	| meals |
	self useSomeFuckAboutSpoil.
	self addAbundantFoodExpiringIn: 5.
	self add: 20 of: dairy expiringIn: 1.

	meals := household consumeFood.

	self assert: (self mealsOf: animalProteins in: meals) equals: 25.
	self assert: (self mealsOf: dairy in: meals) equals: 15.
	self assert: (self mealsOf: fruitsAndVegetables in: meals) equals: 10.
	self assert: (self quantityOf: dairy expiringIn: 1) equals: 5
]

{ #category : 'tests' }
FEBHouseholdConsumptionTest >> testSubstitutesMissingMealsAlongTheSubstitutionList [
	"15 Animal protein meals are missing. Dairy keeps its own 15 meals and has 5 left for them, and the last 10 go one step further down the list, to Staple food."

	| meals |
	self useSomeFuckAboutSpoil.
	self add: 10 of: animalProteins expiringIn: 5.
	self add: 20 of: dairy expiringIn: 5.
	self add: 100 of: fruitsAndVegetables expiringIn: 5.
	self add: 100 of: stapleFood expiringIn: 5.

	meals := household consumeFood.

	self assert: (self mealsOf: animalProteins in: meals) equals: 10.
	self assert: (self mealsOf: dairy in: meals) equals: 20.
	self assert: (self mealsOf: fruitsAndVegetables in: meals) equals: 10.
	self assert: (self mealsOf: stapleFood in: meals) equals: 10.
	self assert: meals size equals: 50
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> useDailyNeed: aNumber preferences: anArrayOfAssociations [
	"Give the household this daily need and these preferences, with an empty inventory. The daily need has no setter, because the model derives it from the household size."

	household instVarNamed: #dailyNeed put: aNumber.
	household foodPreferenceProportions:
		anArrayOfAssociations asDictionary.
	household inventory batches copy do: [ :each |
		household inventory removeBatch: each ]
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> useNoSpoilWeirdo [

	FEBHousehold consumptionStrategySymbol: #'No spoil weirdo'
]

{ #category : 'helpers' }
FEBHouseholdConsumptionTest >> useSomeFuckAboutSpoil [

	FEBHousehold consumptionStrategySymbol: #'Some fuck about spoil'
]
