"
I am the dashboard of one household of the AMAEA model: what it ate, what it bought, what spoiled, what it holds, and how its indicators went, step by step.

## Responsibility:

- Show the household in the header, with its size, daily need and strategy.
- Show the chosen day with a `FEBHouseholdDayPresenter`, where the meals table holds the household's preferences.
- Chart its history with `FEBHouseholdCharts`: indicators, meals, purchases, money and time spent, stock and spoiled food.

## Collaborators:

- `FEBEntityDashboard`: my superclass, with the header, the step navigator, the tabs and the window.
- `FEBHousehold`: the household I show.
- `FEBHouseholdDayPresenter` and `FEBHouseholdCharts`: my ""Day"" tab and my chart tabs.

## Public API and Key Messages

- `FEBHouseholdDashboard openOn: aHousehold` opens me in a window; `on: aHousehold` creates me, as the household's inspector tab does.

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
"
Class {
	#name : 'FEBHouseholdDashboard',
	#superclass : 'FEBEntityDashboard',
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'private' }
FEBHouseholdDashboard >> headerInfo [
	"What does not change over time: size, daily need and strategy. The preferences are in the meals table."

	^ String streamContents: [ :stream |
			  stream << entity householdSize printString
			  << (entity householdSize = 1
					   ifTrue: [ ' person' ]
					   ifFalse: [ ' persons' ]) << ', needs '
			  << entity dailyNeed printString << ' meals a day, '
			  << self strategyName ]
]

{ #category : 'private' }
FEBHouseholdDashboard >> headerTitle [

	^ 'Household ' , entity id printString
]

{ #category : 'private' }
FEBHouseholdDashboard >> newCharts [

	^ FEBHouseholdCharts on: entity
]

{ #category : 'private' }
FEBHouseholdDashboard >> newDayPresenter [

	^ self instantiate: FEBHouseholdDayPresenter on: entity
]

{ #category : 'private' }
FEBHouseholdDashboard >> strategyName [
	"FEBMoneySaverStrategy is shown as 'money saver'"

	| words |
	words := ((entity strategy class name withoutPrefix: 'FEB')
		          withoutSuffix: 'Strategy') piecesCutWhere: [ :a :b |
		         b isUppercase ].
	^ ' ' join: (words collect: [ :each | each asLowercase ])
]
