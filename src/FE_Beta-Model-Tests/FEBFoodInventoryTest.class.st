"
I test the queries of a `FEBFoodInventory` about the batches it holds.

## Responsibility:

- Check which batches the inventory answers when asked about expiry.
- Check that expired batches are left out of those answers.
- Keep each test independent, with a fresh inventory and food categories.

## Collaborators:

- `FEBFoodInventory`: the inventory under test.
- `FEBFoodBatch` and `FEBFoodCategory`: the food put into it.

## Public API and Key Messages

- `add:of:expiringIn:` puts a batch outside the fridge into the inventory.

```smalltalk
FEBFoodInventoryTest run: #testBatchesExpiringTomorrowAreTheOnesInTheirLastDay
```
"
Class {
	#name : 'FEBFoodInventoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'inventory',
		'dairy',
		'rice'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBFoodInventoryTest >> add: aQuantity of: aCategory expiringIn: aNumberOfDays [

	inventory addBatch: (FEBFoodBatch
			 category: aCategory
			 quantity: aQuantity
			 fridge: false
			 remainingDays: aNumberOfDays)
]

{ #category : 'running' }
FEBFoodInventoryTest >> setUp [

	super setUp.
	inventory := FEBFoodInventory new.
	dairy := FEBFoodCategory
		         named: 'Dairy'
		         shelfLifeInFridge: 6
		         outsideFridge: 2.
	rice := FEBFoodCategory
		        named: 'Rice'
		        shelfLifeInFridge: 30
		        outsideFridge: 30
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testAddingFoodKeepsEveryUnit [

	self add: 3 of: dairy expiringIn: 2.
	self add: 4 of: dairy expiringIn: 2.
	self add: 5 of: dairy expiringIn: 3.

	self assert: (inventory quantityInCategory: dairy) equals: 12
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testBatchesExpiringTomorrowAreTheOnesInTheirLastDay [

	| batches |
	self add: 3 of: dairy expiringIn: 1.
	self add: 4 of: rice expiringIn: 1.
	self add: 5 of: dairy expiringIn: 2.
	self add: 6 of: rice expiringIn: 0.

	batches := inventory batchesExpiringTomorrow.

	self
		assert: (batches collect: [ :each | each quantity ]) asSet
		equals: #( 3 4 ) asSet
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testEmptyingTheTrashbinThrowsTheSpoiledFoodAway [

	self add: 3 of: dairy expiringIn: 1.
	inventory becomeOneDayOlder.

	inventory emptyTheTrashbin.

	self assert: inventory amountOfFoodInTrashbin equals: 0
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testFoodLeftTomorrowLeavesOutFoodInItsLastDay [

	self add: 3 of: dairy expiringIn: 1.
	self add: 4 of: dairy expiringIn: 2.
	self add: 5 of: rice expiringIn: 2.

	self
		assert: (inventory quantityLeftTomorrowInCategory: dairy)
		equals: 4
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testFreeFridgeSpaceIsTheCapacityNotYetUsed [

	inventory fridgeCapacity: 10.
	inventory addBatch:
		(FEBFoodBatch category: dairy quantity: 4 fridge: true).
	inventory addBatch:
		(FEBFoodBatch category: rice quantity: 20 fridge: false).

	self assert: inventory freeFridgeSpace equals: 6
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testRemovingEmptyBatchesLeavesOnlyFood [

	| first second |
	self add: 3 of: dairy expiringIn: 4.
	self add: 4 of: rice expiringIn: 1.
	self add: 5 of: dairy expiringIn: 2.
	first := inventory batches first.
	second := inventory batches second.
	first extractQuantity: first quantity.
	second extractQuantity: second quantity.

	inventory removeEmptyBatches.

	self assert: inventory batches size equals: 1.
	self assert: inventory totalQuantity equals: 5
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testSpoiledFoodGoesToTheTrashbin [

	self add: 3 of: dairy expiringIn: 1.
	self add: 4 of: rice expiringIn: 5.

	inventory becomeOneDayOlder.

	self assert: inventory totalQuantity equals: 4.
	self assert: inventory amountOfFoodInTrashbin equals: 3
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testSpoiledFoodIsCountedPerCategory [

	self add: 3 of: dairy expiringIn: 1.
	self add: 2 of: dairy expiringIn: 1.
	self add: 5 of: rice expiringIn: 2.

	inventory becomeOneDayOlder.

	self assert: (inventory spoiledFood occurrencesOf: dairy) equals: 5.
	self assert: (inventory spoiledFood occurrencesOf: rice) equals: 0
]

{ #category : 'tests' }
FEBFoodInventoryTest >> testStockLevelsTellWhatIsInTheFridgeOutsideAndInItsLastDay [

	| dairyLevel riceLevel |
	inventory fridgeCapacity: 10.
	inventory addBatch:
		(FEBFoodBatch category: dairy quantity: 4 fridge: true).
	self add: 3 of: dairy expiringIn: 1.
	self add: 5 of: rice expiringIn: 2.

	dairyLevel := inventory stockLevels detect: [ :each |
		              each category = dairy ].
	riceLevel := inventory stockLevels detect: [ :each |
		             each category = rice ].
	self assert: dairyLevel inFridge equals: 4.
	self assert: dairyLevel outsideFridge equals: 3.
	self assert: dairyLevel inLastDay equals: 3.
	self assert: riceLevel outsideFridge equals: 5.
	self assert: riceLevel inLastDay equals: 0
]
