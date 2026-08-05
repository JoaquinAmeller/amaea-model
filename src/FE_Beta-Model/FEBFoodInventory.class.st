Class {
	#name : 'FEBFoodInventory',
	#superclass : 'Object',
	#instVars : [
		'batches',
		'fridgeCapacity',
		'trashbin'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'adding' }
FEBFoodInventory >> addBatch: aBatch [

	| existing |
	existing := self findMergeableBatchFor: aBatch.
	
	existing
		ifNil: [ batches add: aBatch ]
		ifNotNil: [ existing addQuantity: aBatch quantity ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> amountOfFoodInTrashbin [

	^ trashbin sum: [ :batch | batch quantity ]
]

{ #category : 'accessing' }
FEBFoodInventory >> batches [

	^ batches 
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> batchesExpiringSoon [

	^ self nonExpiredBatches select: [ :each | each willExpireSoon ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> batchesOfCategory: aCategory [

	^ self nonExpiredBatches select: [ :each | each category = aCategory ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> becomeOneDayOlder [

	batches do: [ :each | each becomeOneDayOlder ].
	self removeExpiredBatched
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> emptyTheTrashbin [

	trashbin removeAll
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> extractOneUnitFromBatch: aBatch [

	| extracted |
	extracted := aBatch extractQuantity: 1.
	self removeBatchIfEmpty: aBatch.
	^ extracted
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> findMergeableBatchFor: aBatch [

	^ batches
		detect: [ :each |
			each category = aBatch category
				and: [ each isInFridge = aBatch isInFridge
				and: [ each remainingDays = aBatch remainingDays ] ] ]
		ifNone: [ nil ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> freeFridgeSpace [
	
	^ fridgeCapacity - self quantityInFridge
]

{ #category : 'accessing' }
FEBFoodInventory >> fridgeCapacity [

	^ fridgeCapacity 
]

{ #category : 'accessing' }
FEBFoodInventory >> fridgeCapacity: anInteger [

	fridgeCapacity := anInteger
]

{ #category : 'testing' }
FEBFoodInventory >> hasBatchExpiringSoonOfCategory: aCategory [

	^ (self batchesOfCategory: aCategory)
		anySatisfy: [ :each | each willExpireSoon ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> hasFood [

	^ self nonExpiredBatches isNotEmpty
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> hasFoodInCategory: aCategory [

	^ (self quantityInCategory: aCategory) > 0
]

{ #category : 'initialization' }
FEBFoodInventory >> initialize [
	super initialize.
	batches := OrderedCollection new.
	trashbin := OrderedCollection new.
	fridgeCapacity := 0
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> nonExpiredBatches [

	^ batches reject: [ :each | each isExpired ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> oldestBatchOfCategory: aCategory [

	| candidates oldestBatch |	
	candidates := self batchesOfCategory: aCategory.
	
	candidates ifEmpty: [ self error: 'There are no batches in this category' ].
	
	oldestBatch := candidates first.
	
	batches do: [ :each |
		each remainingDays < oldestBatch remainingDays ifTrue: [ 
			oldestBatch := each ] ].
	
	^ oldestBatch 
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> quantitiesByCategory [

	| dict |
	dict := Dictionary new.
	
	self nonExpiredBatches do: [ :each |
		dict
			at: each category
			put: ((dict at: each category ifAbsent: [ 0 ]) + each quantity) ].
		
	^ dict
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> quantityInCategory: aCategory [

	^ (self batchesOfCategory: aCategory)
		sum: [ :each | each quantity ]
		ifEmpty: [ 0 ]
]

{ #category : 'accessing' }
FEBFoodInventory >> quantityInFridge [

	^ (batches select: [ :each | each isInFridge ])
		sum: [ :each | each quantity ]
		ifEmpty: [ 0 ]
]

{ #category : 'removing' }
FEBFoodInventory >> removeBatch: aBatch [

	batches remove: aBatch
]

{ #category : 'removing' }
FEBFoodInventory >> removeBatchIfEmpty: aBatch [

	aBatch isEmpty ifTrue: [ self removeBatch: aBatch ]
]

{ #category : 'removing' }
FEBFoodInventory >> removeEmptyBatches [

	batches do: [ :batch | self removeBatchIfEmpty: batch ]
]

{ #category : 'removing' }
FEBFoodInventory >> removeExpiredBatched [

	| expiredBatches |
	expiredBatches := batches select: [ :each | each isExpired ].
	
	expiredBatches do: [ :each |
		batches remove: each.
		trashbin add: each ]

]

{ #category : 'accessing' }
FEBFoodInventory >> totalQuantity [

	^ batches sum: [ :each | each quantity ] ifEmpty: [ 0 ]
]
