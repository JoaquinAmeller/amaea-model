"
I am the record of what an entity of the model did during one time step. My subclasses add what is particular to households and outlets.

## Responsibility:

- Know the time step I am the record of.
- Keep the entity's stock at the end of the day, after the night's spoiled food is removed, as numbers per food category.
- Keep the food that spoiled that night, per category.

## Collaborators:

- `FEBHistory`: keeps an entity's records in order, by `step`.
- `FEBFoodInventory`: gives the stock levels and the spoiled food at the end of the day.
- `FEBStockLevel`: each category's stock.
- `FEBHouseholdDay` and `FEBOutletDay`: my subclasses.

## Public API and Key Messages

- `step`, `stock`, `stockOf:`, `spoiledFood`.
- `recordEndOfDayOf:` records the stock and the spoiled food of an inventory whose food has just aged.
- Create my subclasses with `step:`, for example `FEBHouseholdDay step: 3`.

```smalltalk
| day |
day := FEBOutletDay step: 3.
day spoiledFood isEmpty ""true""
```

## Internal Representation

- `step`: an Integer, the Cormas time step.
- `stock`: a collection of `FEBStockLevel`, one per category held, empty until the end of the day is recorded.
- `spoiledFood`: a Bag counting the spoiled meals of each `FEBFoodCategory`.
"
Class {
	#name : 'FEBDay',
	#superclass : 'Object',
	#instVars : [
		'step',
		'stock',
		'spoiledFood'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'instance creation' }
FEBDay class >> step: anInteger [

	^ self new
		  initializeStep: anInteger;
		  yourself
]

{ #category : 'initialization' }
FEBDay >> initializeStep: anInteger [

	step := anInteger.
	stock := OrderedCollection new.
	spoiledFood := Bag new
]

{ #category : 'printing' }
FEBDay >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (step ' << step printString << ')'
]

{ #category : 'recording' }
FEBDay >> recordEndOfDayOf: anInventory [
	"Record the stock left and the food spoiled, once the inventory's food has aged for the night"

	stock := anInventory stockLevels.
	spoiledFood := anInventory spoiledFood
]

{ #category : 'accessing' }
FEBDay >> spoiledFood [

	^ spoiledFood
]

{ #category : 'accessing' }
FEBDay >> step [

	^ step
]

{ #category : 'accessing' }
FEBDay >> stock [

	^ stock
]

{ #category : 'accessing' }
FEBDay >> stockOf: aCategory [

	^ stock
		  detect: [ :each | each category = aCategory ]
		  ifNone: [ FEBStockLevel noneOf: aCategory ]
]
