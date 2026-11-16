"
I record what one household did during one time step of a simulation.

## Responsibility:

- Know the time step I am the record of.
- Keep the meals the household ate during that step, with why each was eaten.
- Hold only facts: the household's indicators for the day are computed from me, not stored in me.

## Collaborators:

- `FEBHousehold`: fills the record of the current time step as it acts, and computes its indicators for any of its days.
- `FEBHistory`: keeps the household's records in order.
- `FEBMeal`: each meal I keep.

## Public API and Key Messages

- `step` and `meals`.
- `addMeals:` adds meals eaten during my step.
- Create me with `FEBHouseholdDay step: 3`.

```smalltalk
| day |
day := FEBHouseholdDay step: 3.
day meals size ""0""
```

## Internal Representation

- `step`: an Integer, the Cormas time step.
- `meals`: a Bag of `FEBMeal`. Meals of the same category eaten for the same reason are equal, so the Bag keeps one entry per category and reason with its count: a day stays small however many meals were eaten. Its order is not meaningful.
"
Class {
	#name : 'FEBHouseholdDay',
	#superclass : 'Object',
	#instVars : [
		'step',
		'meals'
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

{ #category : 'adding' }
FEBHouseholdDay >> addMeals: aCollectionOfMeals [

	meals addAll: aCollectionOfMeals
]

{ #category : 'initialization' }
FEBHouseholdDay >> initializeStep: anInteger [

	step := anInteger.
	"A Bag counts equal meals once each, so a day keeps at most one entry per category and reason, however many meals were eaten"
	meals := Bag new
]

{ #category : 'accessing' }
FEBHouseholdDay >> meals [

	^ meals
]

{ #category : 'printing' }
FEBHouseholdDay >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (step ' << step printString << ')'
]

{ #category : 'accessing' }
FEBHouseholdDay >> step [

	^ step
]
