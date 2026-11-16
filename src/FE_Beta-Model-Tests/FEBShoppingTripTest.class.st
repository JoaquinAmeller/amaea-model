"
I test the shopping trips of a `FEBHousehold`: whether it goes shopping, where, and what it can afford.

## Responsibility:

- Check that a household shops when it lacks its preferred food for the day, and only then.
- Check that it visits the closest outlet first and goes no further than its time allows.
- Check that it never spends more than it has, and keeps a money reserve when buying for storage.

## Collaborators:

- `FEBModel`: gives the 30 by 30 grid, the food categories and the substitution list.
- `FEBOutlet`: the outlets the household knows, stocked with known food.
- `FEBHousehold`: the shopper, a person needing 10 meals a day, at the corner cell.

## Public API and Key Messages

- `outletAt:at:stocking:of:` puts an outlet on the grid with only that food, and tells the household about it.
- `give:of:` puts food in the household's inventory.

```smalltalk
FEBShoppingTripTest run: #testShopsAtTheClosestOutletFirst
```

## Internal Representation

- An outlet's inventory has no accessor, so `inventoryOf:` reads it with `instVarNamed:`.
"
Class {
	#name : 'FEBShoppingTripTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'household',
		'stapleFood',
		'animalProteins',
		'processedFood'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBShoppingTripTest >> give: aQuantity of: aCategory [

	household inventory addBatch:
		(FEBFoodBatch category: aCategory quantity: aQuantity fridge: false)
]

{ #category : 'helpers' }
FEBShoppingTripTest >> giveMoney: anAmount [

	household instVarNamed: #availableMoneyPerStep put: anAmount
]

{ #category : 'helpers' }
FEBShoppingTripTest >> inventoryOf: anOutlet [

	^ anOutlet instVarNamed: #inventory
]

{ #category : 'helpers' }
FEBShoppingTripTest >> outletAt: aRow at: aColumn stocking: aQuantity of: aCategory [

	| outlet |
	outlet := model
		          newEntity: FEBOutlet
		          locatedAt: (model cellAt: aRow at: aColumn).
	(self inventoryOf: outlet) batches removeAll.
	(self inventoryOf: outlet) addBatch: (FEBFoodBatch
			 category: aCategory
			 quantity: aQuantity
			 fridge: aCategory shouldBeStoredInFridge).
	household outlets add: outlet.
	^ outlet
]

{ #category : 'running' }
FEBShoppingTripTest >> setUp [
	"A person needing 10 meals a day, preferring only staple food, at the corner of a 30 by 30 grid, with no food and no outlet yet"

	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	model
		createGridNumberOfRows: 30
		numberOfColumns: 30
		neighbourhood: 8
		closed: true.
	stapleFood := model foodCategoryNamed: 'Staple food'.
	animalProteins := model foodCategoryNamed: 'Animal proteins'.
	processedFood := model foodCategoryNamed: 'Processed food'.

	household := model
		             newEntity: FEBHousehold
		             locatedAt: (model cellAt: 1 at: 1).
	household instVarNamed: #householdSize put: 1.
	household instVarNamed: #dailyNeed put: 10.
	household foodPreferenceProportions:
		{ (stapleFood -> 1.0) } asDictionary.
	model initializeSubstitutionList.
	household inventory batches removeAll.
	household outlets: OrderedCollection new
]

{ #category : 'tests' }
FEBShoppingTripTest >> testDoesNotGoFurtherThanItsTimeAllows [
	"The outlet is 29 cells away, 145 minutes of walking, and the household has 2 hours"

	self
		outletAt: 30
		at: 30
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 0
]

{ #category : 'tests' }
FEBShoppingTripTest >> testGoesShoppingWhenItHasNoFood [

	self assert: household shouldGoShopping
]

{ #category : 'tests' }
FEBShoppingTripTest >> testGoesShoppingWhenItLacksItsPreferredFood [

	self give: 10 of: processedFood.

	self assert: household shouldGoShopping
]

{ #category : 'tests' }
FEBShoppingTripTest >> testKeepsAMoneyReserveWhenBuyingForStorage [
	"It has today's food, so it only buys for storage, and keeps the share of its 100 that its strategy holds back"

	self giveMoney: 100.
	self give: 10 of: stapleFood.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity > 10.
	self assert:
		household remainingMoney >= (100 * household moneyThreshold)
]

{ #category : 'tests' }
FEBShoppingTripTest >> testNeverSpendsMoreThanItHas [

	self giveMoney: 23.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.
	self
		outletAt: 2
		at: 4
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household remainingMoney >= 0.
	self assert: household inventory totalQuantity * 5 <= 23
]

{ #category : 'tests' }
FEBShoppingTripTest >> testShoppingNeverOverfillsTheFridge [
	"Animal proteins keep only 2 days outside, so they go in the fridge, which holds 6 meals"

	household foodPreferenceProportions:
		{ (animalProteins -> 1.0) } asDictionary.
	household inventory batches removeAll.
	self giveMoney: 1000.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: animalProteins.

	household goShopping.

	self assert: household inventory quantityInFridge
		<= household inventory fridgeCapacity
]

{ #category : 'tests' }
FEBShoppingTripTest >> testShopsAtTheClosestOutletFirst [

	| near far |
	far := self
		       outletAt: 5
		       at: 5
		       stocking: 100
		       of: stapleFood.
	near := self
		        outletAt: 1
		        at: 3
		        stocking: 100
		        of: stapleFood.

	household goShopping.

	self assert: (self inventoryOf: near) totalQuantity < 100.
	self assert: (self inventoryOf: far) totalQuantity equals: 100
]

{ #category : 'tests' }
FEBShoppingTripTest >> testSpendsAllItsMoneyOnFoodForTheDayIfNeeded [
	"30 pays for 6 of the 10 meals it needs today, at 5 each"

	self giveMoney: 30.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 6.
	self assert: household remainingMoney equals: 0
]

{ #category : 'tests' }
FEBShoppingTripTest >> testStaysHomeWhenItHasItsPreferredFoodForTheDay [

	self give: 10 of: stapleFood.

	self deny: household shouldGoShopping
]
