Class {
	#name : 'FEBHouseholdTest',
	#superclass : 'TestCase',
	#instVars : [
		'household',
		'meat',
		'vegetables',
		'rice',
		'dairy'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'accessing' }
FEBHouseholdTest >> initializeFoodCategories [

	meat := FEBFoodCategory
		named: 'Meat'
		shelfLifeInFridge: 5
		outsideFridge: 2.
			
	vegetables := FEBFoodCategory
		named: 'Vegetables'
		shelfLifeInFridge: 7
		outsideFridge: 3.
			
	rice := FEBFoodCategory
		named: 'Rice'
		shelfLifeInFridge: 30
		outsideFridge: 30.
			
	dairy := FEBFoodCategory
		named: 'Dairy'
		shelfLifeInFridge: 6
		outsideFridge: 2
]

{ #category : 'running' }
FEBHouseholdTest >> setUp [

	| model |
	super setUp.
	
	model := FEBModel new
		init.
		
	household := model households first.
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenLotsOfFood [

	| shoppingList |
	
	"Household has lots of meals"
	household inventory addBatch: (FEBFoodBatch
		category: rice
		quantity: 10000
		fridge: false).
	
	shoppingList := household buildShoppingList.
	
	"Household has enough food for 1 day, so food is essential to buy"
	self assert: (shoppingList essentialNeedOf: meat) equals: 0.
	self assert: (shoppingList essentialNeedOf: rice) equals: 0.
	self assert: (shoppingList essentialNeedOf: vegetables) equals: 0.
	self assert: (shoppingList essentialNeedOf: dairy) equals: 0.
	
	"Household still buys 3 meals for storage"
	self assert: (shoppingList storageNeedOf: meat) equals: 1.
	self assert: (shoppingList storageNeedOf: rice) equals: 1.
	self assert: (shoppingList storageNeedOf: vegetables) equals: 1.
	self assert: (shoppingList storageNeedOf: dairy) equals: 0.
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenNoFood [

	| shoppingList |
	shoppingList := household buildShoppingList.
	
	self assert: (shoppingList essentialNeedOf: meat) equals: 1.
	self assert: (shoppingList essentialNeedOf: rice) equals: 1.
	self assert: (shoppingList essentialNeedOf: vegetables) equals: 1.
	self assert: (shoppingList essentialNeedOf: dairy) equals: 0.
	
	self assert: (shoppingList storageNeedOf: meat) equals: 1.
	self assert: (shoppingList storageNeedOf: rice) equals: 1.
	self assert: (shoppingList storageNeedOf: vegetables) equals: 1.
	self assert: (shoppingList storageNeedOf: dairy) equals: 0.
]

{ #category : 'tests' }
FEBHouseholdTest >> testShoppingListWhenSomeFood [

	| shoppingList |
	
	"Household has 2 meals"
	household inventory addBatch: (FEBFoodBatch
		category: rice
		quantity: 2
		fridge: false).
	
	shoppingList := household buildShoppingList.
	
	"It is essential that household gets 1 more meal to have 3 meals for one day"
	self assert: (shoppingList essentialNeedOf: meat) equals: 1.
	self assert: (shoppingList essentialNeedOf: rice) equals: 0.
	self assert: (shoppingList essentialNeedOf: vegetables) equals: 0.
	self assert: (shoppingList essentialNeedOf: dairy) equals: 0.
	
	"Household still buys 3 meals for storage"
	self assert: (shoppingList storageNeedOf: meat) equals: 1.
	self assert: (shoppingList storageNeedOf: rice) equals: 1.
	self assert: (shoppingList storageNeedOf: vegetables) equals: 1.
	self assert: (shoppingList storageNeedOf: dairy) equals: 0.
]
