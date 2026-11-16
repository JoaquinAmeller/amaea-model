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
FEBFoodInventory >> batchesExpiringTomorrow [
	"Answer the batches in their last day: they will be expired tomorrow"

	^ self nonExpiredBatches select: [ :each | each willExpireTomorrow ]
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> batchesLeftTomorrowOfCategory: aCategory [
	"Answer the batches of aCategory that will not be expired tomorrow"

	^ (self batchesOfCategory: aCategory) reject: [ :each |
		  each willExpireTomorrow ]
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
	
	^ (fridgeCapacity - self quantityInFridge) max: 0
]

{ #category : 'accessing' }
FEBFoodInventory >> fridgeCapacity [

	^ fridgeCapacity 
]

{ #category : 'accessing' }
FEBFoodInventory >> fridgeCapacity: anInteger [

	fridgeCapacity := anInteger
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

{ #category : 'as yet unclassified' }
FEBFoodInventory >> quantityLeftTomorrowInCategory: aCategory [
	"Answer the quantity of aCategory that will not be expired tomorrow"

	^ (self batchesLeftTomorrowOfCategory: aCategory)
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

	(batches select: [ :each | each isEmpty ]) do: [ :each |
		self removeBatch: each ]
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
FEBFoodInventory >> spoiledFood [
	"Answer the food in the trashbin, as a Bag counting the meals of each category"

	| spoiledFood |
	spoiledFood := Bag new.
	trashbin do: [ :each |
		spoiledFood add: each category withOccurrences: each quantity ].
	^ spoiledFood
]

{ #category : 'accessing' }
FEBFoodInventory >> stockLevels [
	"Answer a FEBStockLevel for each category of food held, in the order the categories first appear"

	| categories |
	categories := (self nonExpiredBatches collect: [ :each |
			               each category ]) asOrderedCollection
		              removeDuplicates;
		              yourself.
	^ categories collect: [ :category |
			  | categoryBatches |
			  categoryBatches := self batchesOfCategory: category.
			  FEBStockLevel
				  category: category
				  inFridge:
					  ((categoryBatches select: [ :each | each isInFridge ])
						   sum: [ :each | each quantity ]
						   ifEmpty: [ 0 ])
				  outsideFridge:
					  ((categoryBatches reject: [ :each | each isInFridge ])
						   sum: [ :each | each quantity ]
						   ifEmpty: [ 0 ])
				  inLastDay:
					  ((categoryBatches select: [ :each | each willExpireTomorrow ])
						   sum: [ :each | each quantity ]
						   ifEmpty: [ 0 ]) ]
]

{ #category : 'accessing' }
FEBFoodInventory >> totalQuantity [

	^ batches sum: [ :each | each quantity ] ifEmpty: [ 0 ]
]
