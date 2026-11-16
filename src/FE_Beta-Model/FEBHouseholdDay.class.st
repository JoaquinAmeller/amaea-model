"
I record what one household did during one time step of a simulation.

## Responsibility:

- Know the time step I am the record of.
- Keep the meals the household ate during that step, with why each was eaten, and the purchases it made.
- Know whether it went shopping, with the money and time it had and the time it spent walking. I hold only facts: money spent and the household's indicators are computed from me, not stored in me.

## Collaborators:

- `FEBHousehold`: fills the record of the current time step as it acts, and computes its indicators for any of its days.
- `FEBHistory`: keeps the household's records in order.
- `FEBMeal`: each meal I keep.
- `FEBPurchase`: each purchase, shared with the record of the outlet that sold it.

## Public API and Key Messages

- `step`, `meals`, `purchases`.
- `wentShopping`, `moneyAvailable`, `timeAvailable`, `timeSpent`, and `moneySpent`, the sum of the purchases' prices.
- `addMeals:`, `addPurchase:` and `recordShoppingWithMoney:time:timeSpent:` record what happens during my step.
- Create me with `FEBHouseholdDay step: 3`.

```smalltalk
| day |
day := FEBHouseholdDay step: 3.
day wentShopping ""false""
```

## Internal Representation

- `step`: an Integer, the Cormas time step.
- `meals`: a Bag of `FEBMeal`. Meals of the same category eaten for the same reason are equal, so the Bag keeps one entry per category and reason with its count: a day stays small however many meals were eaten. Its order is not meaningful.
- `purchases`: an OrderedCollection of `FEBPurchase`, in the order they were made.
- `moneyAvailable` and `timeAvailable`: nil until the household goes shopping that day; `timeSpent`: a Duration, zero unless it went shopping.
"
Class {
	#name : 'FEBHouseholdDay',
	#superclass : 'Object',
	#instVars : [
		'step',
		'meals',
		'purchases',
		'moneyAvailable',
		'timeAvailable',
		'timeSpent'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'instance creation' }
FEBHouseholdDay class >> step: anInteger [

	^ self new
		  initializeStep: anInteger;
		  yourself
]

{ #category : 'recording' }
FEBHouseholdDay >> addMeals: aCollectionOfMeals [

	meals addAll: aCollectionOfMeals
]

{ #category : 'recording' }
FEBHouseholdDay >> addPurchase: aPurchase [

	purchases add: aPurchase
]

{ #category : 'initialization' }
FEBHouseholdDay >> initializeStep: anInteger [

	step := anInteger.
	"A Bag counts equal meals once each, so a day keeps at most one entry per category and reason, however many meals were eaten"
	meals := Bag new.
	purchases := OrderedCollection new.
	timeSpent := Duration zero
]

{ #category : 'accessing' }
FEBHouseholdDay >> meals [

	^ meals
]

{ #category : 'accessing' }
FEBHouseholdDay >> moneyAvailable [

	^ moneyAvailable
]

{ #category : 'accessing' }
FEBHouseholdDay >> moneySpent [

	^ purchases sum: [ :each | each price ] ifEmpty: [ 0 ]
]

{ #category : 'printing' }
FEBHouseholdDay >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (step ' << step printString << ')'
]

{ #category : 'accessing' }
FEBHouseholdDay >> purchases [

	^ purchases
]

{ #category : 'recording' }
FEBHouseholdDay >> recordShoppingWithMoney: aMoneyAmount time: aDuration timeSpent: anotherDuration [
	"Record that the household went shopping this day, with the money and time it had, and the time it spent walking"

	moneyAvailable := aMoneyAmount.
	timeAvailable := aDuration.
	timeSpent := anotherDuration
]

{ #category : 'accessing' }
FEBHouseholdDay >> step [

	^ step
]

{ #category : 'accessing' }
FEBHouseholdDay >> timeAvailable [

	^ timeAvailable
]

{ #category : 'accessing' }
FEBHouseholdDay >> timeSpent [

	^ timeSpent
]

{ #category : 'accessing' }
FEBHouseholdDay >> wentShopping [

	^ moneyAvailable isNotNil
]
