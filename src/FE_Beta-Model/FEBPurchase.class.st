"
I represent one sale of food by an outlet to a household: what was sold, how much, at what price, and where the household put it.

## Responsibility:

- Know who bought, who sold, the food category, the quantity and the price paid.
- Know how much of the food the household could put in its fridge; the rest was kept outside.
- Be shared: the same object is in the household's record and in the outlet's record of the day, so that the two always agree.

## Collaborators:

- `FEBOutlet`: creates me when it sells, and keeps me among the sales of its day.
- `FEBHousehold`: receives the food, sets how much went into its fridge, pays, and keeps me among the purchases of its day.
- `FEBFoodCategory`: the food sold.

## Public API and Key Messages

- `household`, `outlet`, `category`, `quantity`, `price`, `quantityInFridge`.
- Create me with `FEBPurchase household: aHousehold outlet: anOutlet category: aCategory quantity: 10 price: 50`. My `quantityInFridge` starts at 0 and is set by the household once it has stored the food.

```smalltalk
| purchase |
purchase := FEBPurchase household: nil outlet: nil category: nil quantity: 10 price: 50.
purchase quantityInFridge: 6.
purchase quantity - purchase quantityInFridge ""4 meals kept outside the fridge""
```

## Internal Representation

- `household`: the buying `FEBHousehold`; `outlet`: the selling `FEBOutlet`.
- `category`: a `FEBFoodCategory`.
- `quantity` and `quantityInFridge`: Integers, in meals; `price`: the money paid for all of it.
"
Class {
	#name : 'FEBPurchase',
	#superclass : 'Object',
	#instVars : [
		'household',
		'outlet',
		'category',
		'quantity',
		'price',
		'quantityInFridge'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'instance creation' }
FEBPurchase class >> household: aHousehold outlet: anOutlet category: aCategory quantity: anInteger price: aNumber [

	^ self new
		  initializeHousehold: aHousehold
		  outlet: anOutlet
		  category: aCategory
		  quantity: anInteger
		  price: aNumber;
		  yourself
]

{ #category : 'accessing' }
FEBPurchase >> category [

	^ category
]

{ #category : 'accessing' }
FEBPurchase >> household [

	^ household
]

{ #category : 'initialization' }
FEBPurchase >> initializeHousehold: aHousehold outlet: anOutlet category: aCategory quantity: anInteger price: aNumber [

	household := aHousehold.
	outlet := anOutlet.
	category := aCategory.
	quantity := anInteger.
	price := aNumber.
	quantityInFridge := 0
]

{ #category : 'accessing' }
FEBPurchase >> outlet [

	^ outlet
]

{ #category : 'accessing' }
FEBPurchase >> price [

	^ price
]

{ #category : 'printing' }
FEBPurchase >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (' << quantity printString << ' ' << category name
	<< ')'
]

{ #category : 'accessing' }
FEBPurchase >> quantity [

	^ quantity
]

{ #category : 'accessing' }
FEBPurchase >> quantityInFridge [

	^ quantityInFridge
]

{ #category : 'accessing' }
FEBPurchase >> quantityInFridge: anInteger [

	quantityInFridge := anInteger
]
