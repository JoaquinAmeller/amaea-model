"
I let the user choose one of the recorded time steps of an entity: one step back or forward, any step with a slider or by typing it, or the latest one.

## Responsibility:

- Know the recorded steps and the one selected, and keep my slider and step field showing it.
- Move to the previous, next or latest step, and refuse steps that were not recorded.
- Tell my listeners when the selected step changes.
- Follow the recorded steps while the latest one is selected: new steps given by `steps:` are then selected. Choosing an earlier step stops following them, and choosing the latest, with ""Latest"" or otherwise, follows them again.

## Collaborators:

- `FEBEntityDashboard`: gives me the recorded steps and shows the day of the step I select.

## Public API and Key Messages

- `steps:` sets the recorded steps and selects the latest one while following them; `isFollowing`.
- `selectStep:`, `previous`, `next`, `latest`, and `selectedStep`.
- `whenStepChangedDo:` registers a block called with the newly selected step.

```smalltalk
| navigator |
navigator := FEBStepNavigator new.
navigator whenStepChangedDo: [ :step | step traceCr ].
navigator steps: (1 to: 10).
navigator previous ""traces 9""
```

## Internal Representation

- `steps`: an Array of Integers in increasing order; `selectedStep`: one of them, or nil when there is none.
- `stepChangedBlocks`: the listeners' blocks; `following`: whether new steps are selected as they are recorded.

### Implementation Points

- Setting the slider or the step field to the selected step triggers their own change blocks, which call `selectStep:` again: it returns at once when the step is already selected.
"
Class {
	#name : 'FEBStepNavigator',
	#superclass : 'SpPresenter',
	#instVars : [
		'steps',
		'selectedStep',
		'previousButton',
		'nextButton',
		'slider',
		'stepField',
		'latestButton',
		'stepChangedBlocks',
		'following'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'initialization' }
FEBStepNavigator >> connectPresenters [

	slider whenValueChangedDo: [ :value |
		value ifNotNil: [ self selectStep: value rounded ] ].
	stepField whenNumberChangedDo: [ :number |
		number ifNotNil: [ self selectStep: number ] ]
]

{ #category : 'initialization' }
FEBStepNavigator >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 4;
		  add: previousButton expand: false;
		  add: nextButton expand: false;
		  add: slider;
		  add: stepField width: 60;
		  add: latestButton expand: false;
		  yourself
]

{ #category : 'initialization' }
FEBStepNavigator >> initialize [

	steps := #(  ).
	stepChangedBlocks := OrderedCollection new.
	following := true.
	super initialize
]

{ #category : 'initialization' }
FEBStepNavigator >> initializePresenters [

	previousButton := self newButton
		                  label: 'Previous';
		                  icon: (self iconNamed: #back);
		                  action: [ self previous ];
		                  yourself.
	nextButton := self newButton
		              label: 'Next';
		              icon: (self iconNamed: #forward);
		              action: [ self next ];
		              yourself.
	latestButton := self newButton
		                label: 'Latest';
		                action: [ self latest ];
		                yourself.
	slider := self newSlider
		          min: 0;
		          max: 0;
		          quantum: 1;
		          yourself.
	stepField := self newNumberInput
		             beInteger;
		             yourself
]

{ #category : 'testing' }
FEBStepNavigator >> isFollowing [
	"Whether I select each step as soon as it is recorded"

	^ following
]

{ #category : 'actions' }
FEBStepNavigator >> latest [

	steps ifNotEmpty: [ self selectStep: steps last ]
]

{ #category : 'actions' }
FEBStepNavigator >> next [

	selectedStep ifNil: [ ^ self ].
	self selectStep:
		(steps at: ((steps indexOf: selectedStep) + 1 min: steps size))
]

{ #category : 'actions' }
FEBStepNavigator >> previous [

	selectedStep ifNil: [ ^ self ].
	self selectStep:
		(steps at: ((steps indexOf: selectedStep) - 1 max: 1))
]

{ #category : 'actions' }
FEBStepNavigator >> selectStep: aStep [
	"Select aStep if it was recorded, show it, and tell the listeners. Selecting the latest step follows the steps recorded next; selecting an earlier one stops following them"

	(steps includes: aStep) ifFalse: [ ^ self ].
	following := aStep = steps last.
	aStep = selectedStep ifTrue: [ ^ self ].
	selectedStep := aStep.
	slider value: aStep.
	stepField number: aStep.
	stepChangedBlocks do: [ :each | each value: aStep ]
]

{ #category : 'accessing' }
FEBStepNavigator >> selectedStep [

	^ selectedStep
]

{ #category : 'accessing' }
FEBStepNavigator >> slider [

	^ slider
]

{ #category : 'accessing' }
FEBStepNavigator >> stepField [

	^ stepField
]

{ #category : 'accessing' }
FEBStepNavigator >> steps [

	^ steps
]

{ #category : 'accessing' }
FEBStepNavigator >> steps: aCollectionOfSteps [
	"Set the recorded steps, and select the latest one while following them"

	steps := aCollectionOfSteps asArray.
	steps ifEmpty: [ ^ self ].
	slider
		min: steps first;
		max: steps last.
	stepField rangeMinimum: steps first maximum: steps last.
	following ifTrue: [ self latest ]
]

{ #category : 'events' }
FEBStepNavigator >> whenStepChangedDo: aBlock [

	stepChangedBlocks add: aBlock
]
