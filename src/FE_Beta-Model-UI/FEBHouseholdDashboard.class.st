"
I am a dashboard to explore one household of the AMAEA model, step by step: what it ate, what it bought, what spoiled, what it holds, and how its indicators went.

## Responsibility:

- Show what does not change over time in a header: the household's size, daily need and strategy. Its preferences are in the meals table of the ""Day"" tab.
- Let the user choose a recorded time step with a step navigator, opening on the latest one.
- Show the chosen day in a ""Day"" tab, and the whole history as charts, each in its own tab, where a click selects a step.

## Collaborators:

- `FEBHousehold`: the household I show, with its history of days.
- `FEBStepNavigator`: chooses the time step.
- `FEBHouseholdDayPresenter`: shows the day of the chosen step.
- `FEBHouseholdCharts`: the charts, each shown in its own tab, with a line at the chosen step.

## Public API and Key Messages

- `FEBHouseholdDashboard openOn: aHousehold` opens me in a window.
- `FEBHouseholdDashboard on: aHousehold` creates me, for example to embed me in an inspector tab.
- `navigator` and `dayPresenter` give my parts.

```smalltalk
| simulation |
simulation := (CMSimulation for: FEBModel new)
	activeInitSelector: #initBigGridScenario;
	activeControlSelector: #step;
	initializeSimulation;
	yourself.
5 timesRepeat: [ simulation runStep ].
FEBHouseholdDashboard openOn: simulation cormasModel households first
```

## Internal Representation

- `household`: the `FEBHousehold` I show, set before my presenters are created.
- `titleLabel` and `infoLabel`: the header, the household at the left and what does not change over time at the right; `navigator`: a `FEBStepNavigator`; `dayPresenter`: a `FEBHouseholdDayPresenter`; `notebook`: the tabs.
"
Class {
	#name : 'FEBHouseholdDashboard',
	#superclass : 'SpPresenter',
	#instVars : [
		'household',
		'navigator',
		'dayPresenter',
		'notebook',
		'titleLabel',
		'infoLabel',
		'charts'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'opening' }
FEBHouseholdDashboard class >> openOn: aHousehold [
	"Open a dashboard on aHousehold in its own window, and answer the window"

	^ (self on: aHousehold) open
]

{ #category : 'accessing' }
FEBHouseholdDashboard >> charts [

	^ charts
]

{ #category : 'initialization' }
FEBHouseholdDashboard >> connectPresenters [

	navigator whenStepChangedDo: [ :step |
			dayPresenter showDay: (household history dayAt: step).
			charts selectStep: step ].
	charts whenStepClickedDo: [ :step | navigator selectStep: step ].
	navigator steps:
		(household history days collect: [ :each | each step ])
]

{ #category : 'accessing' }
FEBHouseholdDashboard >> dayPresenter [

	^ dayPresenter
]

{ #category : 'initialization' }
FEBHouseholdDashboard >> defaultLayout [

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

{ #category : 'private' }
FEBHouseholdDashboard >> headerInfo [
	"What does not change over time: size, daily need and strategy. The preferences are in the meals table."

	^ String streamContents: [ :stream |
			  stream << household householdSize printString
			  << (household householdSize = 1
					   ifTrue: [ ' person' ]
					   ifFalse: [ ' persons' ]) << ', needs '
			  << household dailyNeed printString << ' meals a day, '
			  << self strategyName ]
]

{ #category : 'private' }
FEBHouseholdDashboard >> headerTitle [

	^ 'Household ' , household id printString
]

{ #category : 'initialization' }
FEBHouseholdDashboard >> initializePresenters [

	titleLabel := self newLabel
		              label: self headerTitle;
		              yourself.
	infoLabel := self newLabel
		             label: self headerInfo;
		             yourself.
	navigator := self instantiate: FEBStepNavigator.
	dayPresenter := self
		                instantiate: FEBHouseholdDayPresenter
		                on: household.
	charts := FEBHouseholdCharts on: household.
	notebook := self newNotebook.
	notebook addPageTitle: 'Day' provider: [ dayPresenter ].
	charts charts do: [ :chart |
			notebook addPageTitle: chart title provider: [
					self newRoassal
						canvas: chart canvas;
						yourself ] ]
]

{ #category : 'initialization' }
FEBHouseholdDashboard >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Household ' , household id printString;
		initialExtent: 1100 @ 700
]

{ #category : 'accessing' }
FEBHouseholdDashboard >> navigator [

	^ navigator
]

{ #category : 'initialization' }
FEBHouseholdDashboard >> setModelBeforeInitialization: aHousehold [

	household := aHousehold
]

{ #category : 'private' }
FEBHouseholdDashboard >> strategyName [
	"FEBMoneySaverStrategy is shown as 'money saver'"

	| words |
	words := ((household strategy class name withoutPrefix: 'FEB')
		          withoutSuffix: 'Strategy') piecesCutWhere: [ :a :b |
		         b isUppercase ].
	^ ' ' join: (words collect: [ :each | each asLowercase ])
]

{ #category : 'accessing' }
FEBHouseholdDashboard >> tabTitles [

	^ notebook pages collect: [ :each | each title ]
]
