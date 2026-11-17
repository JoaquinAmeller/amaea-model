"
I am a dashboard to explore one entity of the AMAEA model step by step. My subclasses say what to show for households and for outlets.

## Responsibility:

- Show a header with the entity at the left and what does not change over time at the right.
- Let the user choose a recorded time step with a step navigator, opening on the latest one.
- Show the chosen day in a ""Day"" tab, and each chart of the history in its own tab, where a click selects a step.
- Follow the simulation: at the end of each time step, refresh in the UI process, showing the new step unless an earlier one was chosen. Stop when my window closes.

## Collaborators:

- `FEBStepNavigator`: chooses the time step.
- `FEBEntityCharts`: the history charts, given by my subclass.
- The ""Day"" presenter given by my subclass, which answers `showDay:`, and opens the dashboards of the households or outlets it lists.
- `CMTimeStepEnded`: announced by the simulation context's `timeStepAnnouncer` at the end of each step.
- `FEBHouseholdDashboard` and `FEBOutletDashboard`: my subclasses.

## Public API and Key Messages

- `openOn: anEntity` opens an instance of a subclass in a window, and `openOn: anEntity atStep: aStep` opens it on aStep; `on: anEntity` creates one, for example for an inspector tab.
- `refresh` shows the steps recorded since I was drawn; `entity`, `navigator`, `dayPresenter`, `charts`, `tabTitles`.
- Subclasses implement `headerTitle`, `headerInfo`, `newDayPresenter` and `newCharts`.

```smalltalk
FEBOutletDashboard openOn: aModel outlets first
```

## Internal Representation

- `entity`: the household or outlet shown, set before my presenters are created.
- `titleLabel` and `infoLabel`: the header; `notebook`: the tabs.

### Implementation Points

- My subscription to `CMTimeStepEnded` is weak, so that a dashboard in an inspector tab, which has no window to close, is not kept alive by the simulation.
- A refresh rebuilds the charts, keeping the series hidden from their legends, and resets the tabs, which draw the chart of their title in the current charts.
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

{ #category : 'opening' }
FEBEntityDashboard class >> openOn: anEntity atStep: aStep [
	"Open a dashboard on anEntity in its own window, showing aStep, and answer the window. It follows the simulation only if aStep is the latest step"

	| dashboard |
	dashboard := self on: anEntity.
	dashboard navigator selectStep: aStep.
	^ dashboard open
]

{ #category : 'accessing' }
FEBEntityDashboard >> charts [

	^ charts
]

{ #category : 'initialization' }
FEBEntityDashboard >> connectPresenters [

	navigator whenStepChangedDo: [ :step | self showStep: step ].
	self listenToChartClicks.
	navigator steps: self recordedSteps.
	self followSimulation
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

{ #category : 'accessing' }
FEBEntityDashboard >> entity [

	^ entity
]

{ #category : 'updating' }
FEBEntityDashboard >> followSimulation [
	"Refresh at the end of each time step of the simulation. The subscription is weak, so that a dashboard shown in an inspector is not kept alive by the simulation"

	self timeStepAnnouncer weak
		when: CMTimeStepEnded
		send: #timeStepEnded:
		to: self
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
	"Each tab draws the chart of its title in my current charts, which are rebuilt at each refresh"
	charts charts do: [ :chart |
			| title |
			title := chart title.
			notebook addPageTitle: title provider: [
					self newRoassal
						canvas: (charts chartTitled: title) canvas;
						yourself ] ]
]

{ #category : 'initialization' }
FEBEntityDashboard >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self headerTitle;
		initialExtent: 1100 @ 700;
		whenClosedDo: [ self stopFollowingSimulation ]
]

{ #category : 'updating' }
FEBEntityDashboard >> listenToChartClicks [

	charts whenStepClickedDo: [ :step | navigator selectStep: step ]
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

{ #category : 'updating' }
FEBEntityDashboard >> recordedSteps [

	^ entity history days collect: [ :each | each step ]
]

{ #category : 'updating' }
FEBEntityDashboard >> refresh [
	"Show the steps recorded since I was drawn: rebuild the charts, keeping the series hidden from their legends hidden, and show the latest step if the navigator follows the simulation, or keep showing the chosen one"

	| oldCharts |
	oldCharts := charts.
	charts := self newCharts.
	charts hideSeriesHiddenIn: oldCharts.
	self listenToChartClicks.
	notebook resetAllPageContents.
	navigator steps: self recordedSteps.
	self showStep: navigator selectedStep
]

{ #category : 'initialization' }
FEBEntityDashboard >> setModelBeforeInitialization: anEntity [

	entity := anEntity
]

{ #category : 'updating' }
FEBEntityDashboard >> showStep: aStep [

	dayPresenter showDay: (entity history dayAt: aStep).
	charts selectStep: aStep
]

{ #category : 'updating' }
FEBEntityDashboard >> stopFollowingSimulation [

	self timeStepAnnouncer unsubscribe: self
]

{ #category : 'accessing' }
FEBEntityDashboard >> tabTitles [

	^ notebook pages collect: [ :each | each title ]
]

{ #category : 'updating' }
FEBEntityDashboard >> timeStepAnnouncer [

	^ entity cormasModel simulationContext timeStepAnnouncer
]

{ #category : 'updating' }
FEBEntityDashboard >> timeStepEnded: aTimeStepEnded [
	"The simulation announces the end of a step in its own process: refresh in the UI process"

	self defer: [ self refresh ]
]
