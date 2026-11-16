"
I record what one outlet did during one time step of a simulation.

## Responsibility:

- Know the time step I am the record of.
- Keep the sales the outlet made during that step.
- Hold only facts, so that the dashboard can compute totals and revenue from me.

## Collaborators:

- `FEBOutlet`: fills the record of the current time step as it sells.
- `FEBHistory`: keeps the outlet's records in order.
- `FEBPurchase`: each sale, shared with the buying household's record.

## Public API and Key Messages

- `step` and `sales`.
- `addSale:` adds a sale made during my step.
- Create me with `FEBOutletDay step: 3`.

```smalltalk
| day |
day := FEBOutletDay step: 3.
day sales isEmpty ""true""
```

## Internal Representation

- `step`: an Integer, the Cormas time step.
- `sales`: an OrderedCollection of `FEBPurchase`, in the order they were made.
"
Class {
	#name : 'FEBOutletDay',
	#superclass : 'Object',
	#instVars : [
		'step',
		'sales'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'instance creation' }
FEBOutletDay class >> step: anInteger [

	^ self new
		  initializeStep: anInteger;
		  yourself
]

{ #category : 'recording' }
FEBOutletDay >> addSale: aPurchase [

	sales add: aPurchase
]

{ #category : 'initialization' }
FEBOutletDay >> initializeStep: anInteger [

	step := anInteger.
	sales := OrderedCollection new
]

{ #category : 'printing' }
FEBOutletDay >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (step ' << step printString << ')'
]

{ #category : 'accessing' }
FEBOutletDay >> sales [

	^ sales
]

{ #category : 'accessing' }
FEBOutletDay >> step [

	^ step
]
