"
I am the dashboard of one outlet of the AMAEA model: what it sold and to whom, what it restocked, what spoiled and what it holds, step by step.

## Responsibility:

- Show the outlet in the header, with how much it restocks each day.
- Show the chosen day with a `FEBOutletDayPresenter`: its sales with their revenue, and each food category's price, restock, sales, spoiled food and stock.
- Chart its history with `FEBOutletCharts`: sales, food in and out, stock, and households served.

## Collaborators:

- `FEBEntityDashboard`: my superclass, with the header, the step navigator, the tabs and the window.
- `FEBOutlet`: the outlet I show.
- `FEBOutletDayPresenter` and `FEBOutletCharts`: my ""Day"" tab and my chart tabs.

## Public API and Key Messages

- `FEBOutletDashboard openOn: anOutlet` opens me in a window; `on: anOutlet` creates me, as the outlet's inspector tab does.

```smalltalk
| simulation |
simulation := (CMSimulation for: FEBModel new)
	activeInitSelector: #initBigGridScenario;
	activeControlSelector: #step;
	initializeSimulation;
	yourself.
5 timesRepeat: [ simulation runStep ].
FEBOutletDashboard openOn: simulation cormasModel outlets first
```
"
Class {
	#name : 'FEBOutletDashboard',
	#superclass : 'FEBEntityDashboard',
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'private' }
FEBOutletDashboard >> headerInfo [

	^ 'restocks ' , entity restockAmount printString , ' meals a day'
]

{ #category : 'private' }
FEBOutletDashboard >> headerTitle [

	^ 'Outlet ' , entity id printString
]

{ #category : 'private' }
FEBOutletDashboard >> newCharts [

	^ FEBOutletCharts on: entity
]

{ #category : 'private' }
FEBOutletDashboard >> newDayPresenter [

	^ self instantiate: FEBOutletDayPresenter on: entity
]
