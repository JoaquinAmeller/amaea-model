"
I am a dashboard to explore one entity of the AMAEA model step by step. My subclasses say what to show for households and for outlets.

## Responsibility:

- Show a header with the entity at the left and what does not change over time at the right.
- Let the user choose a recorded time step with a step navigator, opening on the latest one.
- Show the chosen day in a ""Day"" tab, and each chart of the history in its own tab, where a click selects a step.

## Collaborators:

- `FEBStepNavigator`: chooses the time step.
- `FEBEntityCharts`: the history charts, given by my subclass.
- The ""Day"" presenter given by my subclass, which answers `showDay:`.
- `FEBHouseholdDashboard` and `FEBOutletDashboard`: my subclasses.

## Public API and Key Messages

- `openOn: anEntity` opens an instance of a subclass in a window; `on: anEntity` creates one, for example for an inspector tab.
- `navigator`, `dayPresenter`, `charts`, `tabTitles`.
- Subclasses implement `headerTitle`, `headerInfo`, `newDayPresenter` and `newCharts`.

```smalltalk
FEBOutletDashboard openOn: aModel outlets first
```

## Internal Representation

- `entity`: the household or outlet shown, set before my presenters are created.
- `titleLabel` and `infoLabel`: the header; `notebook`: the tabs.
"
Class {
	#name : 'FEBEntityDashboard',
	#superclass : 'SpPresenter',
	#instVars : [
		'entity',
		'titleLabel',
		'infoLabel',
		'navigator',
		'dayPresenter',
		'charts',
		'notebook'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'opening' }
FEBEntityDashboard class >> openOn: anEntity [
	"Open a dashboard on anEntity in its own window, and answer the window"

	^ (self on: anEntity) open
]

{ #category : 'accessing' }
FEBEntityDashboard >> charts [

	^ charts
]

{ #category : 'initialization' }
FEBEntityDashboard >> connectPresenters [

	navigator whenStepChangedDo: [ :step |
			dayPresenter showDay: (entity history dayAt: step).
			charts selectStep: step ].
	charts whenStepClickedDo: [ :step | navigator selectStep: step ].
	navigator steps: (entity history days collect: [ :each | each step ])
]

{ #category : 'accessing' }
FEBEntityDashboard >> dayPresenter [

	^ dayPresenter
]

{ #category : 'initialization' }
FEBEntityDashboard >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 6;
		  add: (SpBoxLayout newLeftToRight
				   add: titleLabel expand: false;
				   addLast: infoLabel expand: false;
				   yourself)
		  expand: false;
		  add: navigator expand: false;
		  add: notebook;
		  yourself
]

{ #category : 'subclass responsibility' }
FEBEntityDashboard >> headerInfo [
	"What does not change over time, shown at the right of the header"

	^ self subclassResponsibility
]

{ #category : 'subclass responsibility' }
FEBEntityDashboard >> headerTitle [
	"The entity, shown at the left of the header and as the window's title"

	^ self subclassResponsibility
]

{ #category : 'initialization' }
FEBEntityDashboard >> initializePresenters [

	titleLabel := self newLabel
		              label: self headerTitle;
		              yourself.
	infoLabel := self newLabel
		             label: self headerInfo;
		             yourself.
	navigator := self instantiate: FEBStepNavigator.
	dayPresenter := self newDayPresenter.
	charts := self newCharts.
	notebook := self newNotebook.
	notebook addPageTitle: 'Day' provider: [ dayPresenter ].
	charts charts do: [ :chart |
			notebook addPageTitle: chart title provider: [
					self newRoassal
						canvas: chart canvas;
						yourself ] ]
]

{ #category : 'initialization' }
FEBEntityDashboard >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self headerTitle;
		initialExtent: 1100 @ 700
]

{ #category : 'accessing' }
FEBEntityDashboard >> navigator [

	^ navigator
]

{ #category : 'subclass responsibility' }
FEBEntityDashboard >> newCharts [
	"The FEBEntityCharts of the entity's history"

	^ self subclassResponsibility
]

{ #category : 'subclass responsibility' }
FEBEntityDashboard >> newDayPresenter [
	"A presenter of one day of the entity's history, answering showDay:"

	^ self subclassResponsibility
]

{ #category : 'initialization' }
FEBEntityDashboard >> setModelBeforeInitialization: anEntity [

	entity := anEntity
]

{ #category : 'accessing' }
FEBEntityDashboard >> tabTitles [

	^ notebook pages collect: [ :each | each title ]
]
