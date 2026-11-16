"
I test how a `FEBOutlet` restocks and sells food to households.

## Responsibility:

- Check that an outlet restocks the amount it is set to each day.
- Check that it sells its freshest food first, and never more than it has or than the household can pay.
- Check that food and money only change hands: what the outlet loses, the household gains, at the outlet's price.

## Collaborators:

- `FEBModel`: gives the food categories the outlet sets its prices for.
- `FEBHousehold`: the buyer.
- `FEBFoodInventory` and `FEBFoodBatch`: the outlet's stock.

## Public API and Key Messages

- `stock:of:expiringIn:` replaces the outlet's random stock with known food.
- `sell:of:withMoney:` sells to the household and answers the quantity sold.

```smalltalk
FEBOutletTest run: #testSellsItsFreshestFoodFirst
```

## Internal Representation

- The outlet's inventory has no accessor, so `outletInventory` reads it with `instVarNamed:`.
"
Class {
	#name : 'FEBOutletTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'outlet',
		'household',
		'dairy',
		'stapleFood'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBOutletTest >> outletInventory [

	^ outlet instVarNamed: #inventory
]

{ #category : 'helpers' }
FEBOutletTest >> sell: aQuantity of: aCategory withMoney: aMoneyAmount [

	^ outlet
		  sellCategory: aCategory
		  quantityUpTo: aQuantity
		  withMoneyUpTo: aMoneyAmount
		  to: household
]

{ #category : 'running' }
FEBOutletTest >> setUp [
	"An outlet emptied of its random first stock, and a household with an empty inventory"

	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	dairy := model foodCategoryNamed: 'Dairy'.
	stapleFood := model foodCategoryNamed: 'Staple food'.
	outlet := model newEntity: FEBOutlet.
	self outletInventory batches removeAll.
	household := model newEntity: FEBHousehold.
	household foodPreferenceProportions:
		{ (stapleFood -> 1.0) } asDictionary.
	household inventory batches removeAll.
	household resetRemainingTimeAndMoney
]

{ #category : 'helpers' }
FEBOutletTest >> stock: aQuantity of: aCategory expiringIn: aNumberOfDays [

	self outletInventory addBatch: (FEBFoodBatch
			 category: aCategory
			 quantity: aQuantity
			 fridge: false
			 remainingDays: aNumberOfDays)
]

{ #category : 'tests' }
FEBOutletTest >> testADayRecordsTheOutletsStockAtTheEndOfTheDay [

	model simulationContext currentTimeStep: 1.
	outlet step.

	self
		assert: (model foodCategories sum: [ :each |
				 (outlet today stockOf: each) total ])
		equals: outlet inventorySize
]

{ #category : 'tests' }
FEBOutletTest >> testADayRecordsWhatTheOutletRestocked [

	model simulationContext currentTimeStep: 1.
	outlet step.

	self assert: outlet today restock size equals: outlet restockAmount
]

{ #category : 'tests' }
FEBOutletTest >> testAnOutletThrowsAwayItsSpoiledFoodEachDay [
	"Restocked food keeps at least 2 days, so nothing spoils on the second day"

	self stock: 10 of: dairy expiringIn: 1.
	model simulationContext currentTimeStep: 1.
	outlet step.
	model simulationContext currentTimeStep: 2.
	outlet step.

	self
		assert: ((outlet history dayAt: 1) spoiledFood occurrencesOf: dairy)
		equals: 10.
	self assert: (outlet history dayAt: 2) spoiledFood isEmpty.
	self assert: self outletInventory amountOfFoodInTrashbin equals: 0
]

{ #category : 'tests' }
FEBOutletTest >> testDoesNotSellFoodInItsLastDay [
	"Households buy for the next day, and food in its last day will be spoiled by then"

	self stock: 10 of: dairy expiringIn: 1.
	self stock: 10 of: dairy expiringIn: 4.

	self assert: (self sell: 15 of: dairy withMoney: 1000) equals: 10.
	self
		assert: (self outletInventory quantityInCategory: dairy)
		equals: 10.
	self
		assert:
		(household inventory batchesOfCategory: dairy) first remainingDays
		equals: 4
]

{ #category : 'tests' }
FEBOutletTest >> testFoodAndMoneyOnlyChangeHands [

	| moneyBefore |
	self stock: 10 of: stapleFood expiringIn: 20.
	moneyBefore := household remainingMoney.

	self sell: 4 of: stapleFood withMoney: 100.

	self assert: outlet inventorySize equals: 6.
	self assert: household inventory totalQuantity equals: 4.
	self
		assert: household remainingMoney
		equals: moneyBefore - (4 * (outlet pricePerUnitFor: stapleFood))
]

{ #category : 'tests' }
FEBOutletTest >> testRestockingAddsTheRestockAmount [

	outlet restock.

	self assert: outlet inventorySize equals: outlet restockAmount
]

{ #category : 'tests' }
FEBOutletTest >> testSellsItsFreshestFoodFirst [

	self stock: 10 of: dairy expiringIn: 1.
	self stock: 10 of: dairy expiringIn: 4.

	self sell: 6 of: dairy withMoney: 100.

	self
		assert: (household inventory batchesOfCategory: dairy) size
		equals: 1.
	self
		assert:
		(household inventory batchesOfCategory: dairy) first remainingDays
		equals: 4
]

{ #category : 'tests' }
FEBOutletTest >> testSellsNoMoreThanItHas [

	self stock: 10 of: stapleFood expiringIn: 20.

	self
		assert: (self sell: 50 of: stapleFood withMoney: 1000)
		equals: 10.
	self assert: outlet inventorySize equals: 0
]

{ #category : 'tests' }
FEBOutletTest >> testSellsNoMoreThanTheHouseholdCanPay [
	"At 5 per unit, 12 pays for 2 units"

	self stock: 10 of: stapleFood expiringIn: 20.

	self assert: (self sell: 5 of: stapleFood withMoney: 12) equals: 2
]

{ #category : 'tests' }
FEBOutletTest >> testUnsoldFoodSpoilsAtTheOutlet [

	self stock: 10 of: dairy expiringIn: 1.

	outlet step.

	self assert: self outletInventory amountOfFoodInTrashbin equals: 10
]
