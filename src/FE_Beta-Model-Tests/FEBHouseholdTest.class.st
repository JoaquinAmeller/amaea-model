Class {
	#name : 'FEBHouseholdTest',
	#superclass : 'TestCase',
	#instVars : [
		'household',
		'animalProteins',
		'fruitsAndVegetables',
		'stapleFood'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'running' }
FEBHouseholdTest >> setUp [
	"A household needing 10 meals a day, with an empty inventory and the model's substitution list"

	| model |
	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	animalProteins := model foodCategoryNamed: 'Animal proteins'.
	fruitsAndVegetables := model foodCategoryNamed:
		                       'Fruits and vegetables'.
	stapleFood := model foodCategoryNamed: 'Staple food'.

	household := model newEntity: FEBHousehold.
	household instVarNamed: #dailyNeed put: 10.
	household foodPreferenceProportions: {
			(stapleFood -> 0.5).
			(fruitsAndVegetables -> 0.3).
			(animalProteins -> 0.2) } asDictionary.
	model initializeSubstitutionList.
	household inventory batches copy do: [ :each |
		household inventory removeBatch: each ]
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenLotsOfFood [
	"Far more than six days of food in total, so nothing is needed, even though it is all Staple food"

	| shoppingList |
	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 10000 fridge: false).

	shoppingList := household buildShoppingList.

	self deny: shoppingList hasAnyNeeds
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
	"4 meals leave 6 essential ones, split by the preferences and rounded down, with at least 1 per category. They are less than a day, so storage is the same as with no food."

	| shoppingList |
	household inventory addBatch:
		(FEBFoodBatch category: stapleFood quantity: 4 fridge: false).

	shoppingList := household buildShoppingList.

	self assert: (shoppingList essentialNeedOf: stapleFood) equals: 3.
	self
		assert: (shoppingList essentialNeedOf: fruitsAndVegetables)
		equals: 1.
	self assert: (shoppingList essentialNeedOf: animalProteins) equals: 1.

	self assert: (shoppingList storageNeedOf: stapleFood) equals: 29.
	self
		assert: (shoppingList storageNeedOf: fruitsAndVegetables)
		equals: 15.
	self assert: (shoppingList storageNeedOf: animalProteins) equals: 6
]
