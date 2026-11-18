"
I am the shopping trip of a household today: the network of the legs it walked from its home to the outlets where it shopped. I draw the path along my legs, which are never drawn on their own.

## Responsibility:

- I group the legs of one household, so that its trip can be found, followed and shown as one path.
- I last for the whole simulation, while my legs change every day: the model deletes them at the start of a step, which takes them out of me.
- I remember whether I am highlighted. My default aspect draws every trip in orange and the highlighted one in red; `aspectHousehold:` gives each household its own color. In both, a highlighted trip hides the others.

## Collaborators:

- `FEBHousehold` creates me the first time it shops. Its actions `highlightTrip` and `unhighlightTrip` highlight me, or leave no trip highlighted.
- `FEBTripLeg`: my links, added by `FEBSimpleShoppingStrategy`.
- `FEBModel`: its perspectives hide me; the Aspects panel shows me again.

## Public API and Key Messages

- `household`: whose trip I am.
- `links`: the legs of today, in the order they were walked.
- `isHighlighted`, `highlight`, `unhighlight`.

```
household trip links
```
"
Class {
	#name : 'FEBTrip',
	#superclass : 'CMNetwork',
	#instVars : [
		'household',
		'isHighlighted'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'aspects' }
FEBTrip >> aspectDefault: look [
	"Every trip in the same color. When a trip is highlighted, it is red and the others are hidden"

	<aspect>
	self isHiddenByAnotherTrip ifTrue: [ ^ look beInvisible ].
	look
		color: (isHighlighted
				 ifTrue: [ Color red ]
				 ifFalse: [ Color orange ]);
		thickness: 0.05
]

{ #category : 'aspects' }
FEBTrip >> aspectHousehold: look [
	"Each household's trip has its own color, so that trips can be told apart where they cross. When a trip is highlighted, the others are hidden"

	<aspect>
	self isHiddenByAnotherTrip ifTrue: [ ^ look beInvisible ].
	look
		colorGroupedBy: household id;
		thickness: 0.05
]

{ #category : 'highlighting' }
FEBTrip >> highlight [

	isHighlighted := true
]

{ #category : 'accessing' }
FEBTrip >> household [

	^ household
]

{ #category : 'accessing' }
FEBTrip >> household: aHousehold [

	household := aHousehold
]

{ #category : 'initialization' }
FEBTrip >> initialize [

	super initialize.
	isHighlighted := false
]

{ #category : 'highlighting' }
FEBTrip >> isHiddenByAnotherTrip [
	"Answer whether another trip is highlighted, which hides me"

	^ isHighlighted not and: [
			  (cormasModel entitiesOfClass: FEBTrip) anySatisfy: [ :each |
				  each isHighlighted ] ]
]

{ #category : 'highlighting' }
FEBTrip >> isHighlighted [

	^ isHighlighted
]

{ #category : 'highlighting' }
FEBTrip >> unhighlight [

	isHighlighted := false
]
