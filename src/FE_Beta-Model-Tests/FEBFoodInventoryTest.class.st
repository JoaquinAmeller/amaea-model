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
