"
I test how a `FEBFoodBatch` keeps and spoils.

## Responsibility:

- Check that food lasts its shelf life, which is longer in the fridge.
- Check that moving food in or out of the fridge keeps the share of shelf life it has left.
- Check that a batch cannot be created empty.

## Collaborators:

- `FEBFoodBatch`: the food under test.
- `FEBFoodCategory`: gives the shelf life in and out of the fridge.

## Public API and Key Messages

- `batchOf:inFridge:` makes a fresh batch of 10 units.

```smalltalk
FEBFoodBatchTest run: #testFoodLastsLongerInTheFridge
```
"
Class {
	#name : 'FEBFoodBatchTest',
	#superclass : 'TestCase',
	#instVars : [
		'fruitsAndVegetables',
		'animalProteins'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBFoodBatchTest >> batchOf: aCategory inFridge: aBoolean [

	^ FEBFoodBatch category: aCategory quantity: 10 fridge: aBoolean
]

{ #category : 'helpers' }
FEBFoodBatchTest >> daysUntilExpiryOf: aBatch [

	| days |
	days := 0.
	[ aBatch isExpired ] whileFalse: [
			aBatch becomeOneDayOlder.
			days := days + 1 ].
	^ days
]

{ #category : 'running' }
FEBFoodBatchTest >> setUp [

	super setUp.
	fruitsAndVegetables := FEBFoodCategory
		                       named: 'Fruits and vegetables'
		                       shelfLifeInFridge: 7
		                       outsideFridge: 3.
	animalProteins := FEBFoodCategory
		                  named: 'Animal proteins'
		                  shelfLifeInFridge: 5
		                  outsideFridge: 2
]

{ #category : 'tests' }
FEBFoodBatchTest >> testABatchCannotBeEmpty [

	self
		should: [
		FEBFoodBatch category: animalProteins quantity: 0 fridge: false ]
		raise: Error
		whoseDescriptionIncludes: 'greater than 0'
		description: 'An empty batch must be refused'
]

{ #category : 'tests' }
FEBFoodBatchTest >> testFoodDoesNotBecomeFresherWhenMovedToTheFridge [
	"After 1 of its 2 days outside, half its shelf life is gone, so in the fridge it gets half of 5 days, rounded up"

	| batch |
	batch := self batchOf: animalProteins inFridge: false.
	batch becomeOneDayOlder.
	batch moveToFridge.
	self assert: (self daysUntilExpiryOf: batch) equals: 3
]

{ #category : 'tests' }
FEBFoodBatchTest >> testFoodLastsItsShelfLifeOutsideTheFridge [

	self
		assert: (self daysUntilExpiryOf:
				 (self batchOf: fruitsAndVegetables inFridge: false))
		equals: 3
]

{ #category : 'tests' }
FEBFoodBatchTest >> testFoodLastsLongerInTheFridge [

	self
		assert: (self daysUntilExpiryOf:
				 (self batchOf: fruitsAndVegetables inFridge: true))
		equals: 7
]

{ #category : 'tests' }
FEBFoodBatchTest >> testFoodTakenOutOfTheFridgeKeepsTheShareOfShelfLifeItHasLeft [
	"Fresh in the fridge it has all of its 5 days left, so outside it has all of its 2 days"

	| batch |
	batch := self batchOf: animalProteins inFridge: true.
	batch moveOutsideFridge.
	self assert: (self daysUntilExpiryOf: batch) equals: 2
]
