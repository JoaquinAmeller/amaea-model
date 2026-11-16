Class {
	#name : 'FEBFoodBatch',
	#superclass : 'Object',
	#instVars : [
		'category',
		'quantity',
		'isInFridge',
		'remainingDays'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'as yet unclassified' }
FEBFoodBatch class >> category: aCategory quantity: aNumber fridge: aBoolean [
	
	^ self new
		initializeCategory: aCategory quantity: aNumber fridge: aBoolean;
		yourself
]

{ #category : 'as yet unclassified' }
FEBFoodBatch class >> category: aCategory quantity: aNumber fridge: aBoolean remainingDays: aNumberOfDays [
	
	^ self new
		initializeCategory: aCategory quantity: aNumber fridge: aBoolean remainingDays: aNumberOfDays;
		yourself
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> addQuantity: anInteger [

	quantity := quantity + anInteger 
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> becomeOneDayOlder [

	remainingDays := remainingDays - 1
]

{ #category : 'accessing' }
FEBFoodBatch >> category [

	^ category
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> extractQuantity: anInteger [

	| extracted |
	anInteger > quantity ifTrue: [ self error: 'Not enough quantity in the food batch!' ].
	
	extracted := self class
		category: category
		quantity: anInteger
		fridge: isInFridge
		remainingDays: remainingDays.
		
	quantity := quantity - anInteger.
	^ extracted 
]

{ #category : 'accessing' }
FEBFoodBatch >> initializeCategory: aCategory quantity: aNumber fridge: aBoolean [

	aNumber isInteger ifFalse: [ self error: 'Food quantity must be an integer' ].
	aNumber > 0 ifFalse: [ self error: 'Food quantity must be greater than 0' ].
	
	category := aCategory.
	quantity := aNumber.
	isInFridge := aBoolean.
	remainingDays := aCategory shelfLifeGivenFridge: isInFridge 
]

{ #category : 'accessing' }
FEBFoodBatch >> initializeCategory: aCategory quantity: aNumber fridge: aBoolean remainingDays: aNumberOfDays [

	self initializeCategory: aCategory quantity: aNumber fridge: aBoolean. 
	remainingDays := aNumberOfDays
]

{ #category : 'testing' }
FEBFoodBatch >> isEmpty [

	^ quantity <= 0
]

{ #category : 'accessing' }
FEBFoodBatch >> isExpired [

	^ remainingDays <= 0
]

{ #category : 'accessing' }
FEBFoodBatch >> isInFridge [

	^ isInFridge
]

{ #category : 'testing' }
FEBFoodBatch >> isNotEmpty [

	^ self isEmpty not
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> moveOutsideFridge [

	self moveToFridge: false
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> moveToFridge [

	self moveToFridge: true
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> moveToFridge: aBoolean [
	"Adjust remaining shelf life when moving between fridge and non-fridge storage.

	We preserve the fraction of shelf life remaining rather than resetting it.
	Example: if 50% of shelf life is left in the fridge, then after moving outside,
	the batch keeps 50% of the outside shelf life.

	This models the idea that food does not become 'fresh again' when moved,
	but continues aging consistently under the new storage conditions."

	| oldMaxLife newMaxLife |
	isInFridge = aBoolean ifTrue: [ ^ self ].
	
	oldMaxLife := category shelfLifeGivenFridge: isInFridge.
	newMaxLife := category shelfLifeGivenFridge: aBoolean.
	
	isInFridge := aBoolean.
	remainingDays := (newMaxLife * (remainingDays / oldMaxLife)) ceiling.
]

{ #category : 'accessing' }
FEBFoodBatch >> quantity [

	^ quantity 
]

{ #category : 'accessing' }
FEBFoodBatch >> remainingDays [

	^ remainingDays
]

{ #category : 'as yet unclassified' }
FEBFoodBatch >> willExpireTomorrow [

	^ remainingDays = 1
]
