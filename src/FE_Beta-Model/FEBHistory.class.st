"
I am the history of an entity of the model: one record per time step, in order.

## Responsibility:

- Keep one record per time step, ordered by step.
- Answer the record of a given step, and create the record of the current step when it is first needed.
- Answer the records up to a given day, for indicators computed over several days.

## Collaborators:

- `FEBHousehold` and `FEBOutlet`: keep me, and ask me for the record of the current time step as they act.
- `FEBHouseholdDay` and `FEBOutletDay`: the records I keep. I only need them to answer their `step`.

## Public API and Key Messages

- `days`, `lastDay`, `isEmpty`.
- `dayAt:` answers the record of a step, and fails when there is none.
- `dayAt:ifAbsentPut:` answers the record of a step, creating it with a block when there is none.
- `daysUpTo:` answers the records up to and including a record.

```smalltalk
| history day |
history := FEBHistory new.
day := history dayAt: 1 ifAbsentPut: [ FEBHouseholdDay step: 1 ].
(history dayAt: 1) == day ""true""
```

## Internal Representation

- `days`: an OrderedCollection of records in increasing step order. Records are created as time goes forward, so new ones are always added at the end.

### Implementation Points

- The record of the current step is nearly always the last one, so `dayAt:ifAbsentPut:` looks there first.
"
Class {
	#name : 'FEBHistory',
	#superclass : 'Object',
	#instVars : [
		'days'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBHistory >> dayAt: aStep [

	^ days detect: [ :each | each step = aStep ]
]

{ #category : 'accessing' }
FEBHistory >> dayAt: aStep ifAbsentPut: aBlock [
	"Answer the record of aStep, creating it with aBlock when there is none. Records are created as time goes forward, so a missing record comes after all the others."

	| day |
	(days isNotEmpty and: [ days last step = aStep ]) ifTrue: [
		^ days last ].
	(days isNotEmpty and: [ days last step > aStep ]) ifTrue: [
			^ days detect: [ :each | each step = aStep ] ifNone: [
					  self error: 'A record cannot be added before time step '
						  , days last step printString ] ].
	day := aBlock value.
	days add: day.
	^ day
]

{ #category : 'accessing' }
FEBHistory >> days [

	^ days
]

{ #category : 'accessing' }
FEBHistory >> daysUpTo: aDay [
	"Answer the records up to and including aDay, in order"

	^ days copyFrom: 1 to: (days indexOf: aDay)
]

{ #category : 'initialization' }
FEBHistory >> initialize [

	super initialize.
	days := OrderedCollection new
]

{ #category : 'accessing' }
FEBHistory >> isEmpty [

	^ days isEmpty
]

{ #category : 'accessing' }
FEBHistory >> lastDay [

	^ days last
]
