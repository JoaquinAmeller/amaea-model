"
I represent how much of one food category an entity holds, as recorded at the end of a day.

## Responsibility:

- Know how many meals of the category are in the fridge and outside it.
- Know how many of them are in their last day, and will spoil tonight unless they are eaten.
- Hold numbers only, so that a history of days stays small.

## Collaborators:

- `FEBFoodInventory`: computes one of me per category it holds.
- `FEBDay`: keeps me in the record of a day.
- `FEBFoodCategory`: the food I count.

## Public API and Key Messages

- `category`, `inFridge`, `outsideFridge`, `inLastDay`, and `total`.
- Create me with `FEBStockLevel category: aCategory inFridge: 4 outsideFridge: 3 inLastDay: 3`, or with `FEBStockLevel noneOf: aCategory`.

```smalltalk
| level |
level := FEBStockLevel category: nil inFridge: 4 outsideFridge: 3 inLastDay: 3.
level total ""7""
```

## Internal Representation

- `category`: a `FEBFoodCategory`.
- `inFridge`, `outsideFridge`, `inLastDay`: quantities in meals. `inLastDay` counts meals both in and outside the fridge.
"
Class {
	#name : 'FEBStockLevel',
	#superclass : 'Object',
	#instVars : [
		'category',
		'inFridge',
		'outsideFridge',
		'inLastDay'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'instance creation' }
FEBStockLevel class >> category: aCategory inFridge: aQuantity outsideFridge: anotherQuantity inLastDay: aThirdQuantity [

	^ self new
		  initializeCategory: aCategory
		  inFridge: aQuantity
		  outsideFridge: anotherQuantity
		  inLastDay: aThirdQuantity;
		  yourself
]

{ #category : 'instance creation' }
FEBStockLevel class >> noneOf: aCategory [

	^ self
		  category: aCategory
		  inFridge: 0
		  outsideFridge: 0
		  inLastDay: 0
]

{ #category : 'accessing' }
FEBStockLevel >> category [

	^ category
]

{ #category : 'accessing' }
FEBStockLevel >> inFridge [

	^ inFridge
]

{ #category : 'accessing' }
FEBStockLevel >> inLastDay [

	^ inLastDay
]

{ #category : 'initialization' }
FEBStockLevel >> initializeCategory: aCategory inFridge: aQuantity outsideFridge: anotherQuantity inLastDay: aThirdQuantity [

	category := aCategory.
	inFridge := aQuantity.
	outsideFridge := anotherQuantity.
	inLastDay := aThirdQuantity
]

{ #category : 'accessing' }
FEBStockLevel >> outsideFridge [

	^ outsideFridge
]

{ #category : 'printing' }
FEBStockLevel >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (' << category name << ': ' << inFridge printString
	<< ' in fridge, ' << outsideFridge printString << ' outside, '
	<< inLastDay printString << ' in last day)'
]

{ #category : 'accessing' }
FEBStockLevel >> total [

	^ inFridge + outsideFridge
]
