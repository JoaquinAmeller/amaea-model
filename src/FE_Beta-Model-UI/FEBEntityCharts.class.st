"
I am the charts of an entity's history over its recorded steps. My subclasses say which charts, for households and for outlets.

## Responsibility:

- Build my subclass's charts when I am created, and keep every chart's selected-step line on the selected step.
- Tell my listeners when a chart is clicked.
- Give my subclasses the recorded days, the values of a series per day, and the colour of each food category.

## Collaborators:

- `FEBStepChart`: each chart, and the categorical palette.
- `FEBEntityDashboard`: shows each of my charts in its own tab, and links my clicks to its step navigator.
- `FEBHouseholdCharts` and `FEBOutletCharts`: my subclasses.

## Public API and Key Messages

- `on:` creates an instance of a subclass on an entity.
- `charts`, `chartTitled:`, `selectStep:`, `whenStepClickedDo:`.
- Subclasses implement `buildCharts`, answering their charts in the order of the dashboard's tabs.

```smalltalk
((FEBHouseholdCharts on: aHousehold) chartTitled: 'Meals') canvas open
```

## Internal Representation

- `entity`: the household or outlet whose history I chart; `charts`: its `FEBStepChart`s.
"
Class {
	#name : 'FEBEntityCharts',
	#superclass : 'Object',
	#instVars : [
		'entity',
		'charts',
		'stepClickedBlocks'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'instance creation' }
FEBEntityCharts class >> on: anEntity [

	^ self new
		  initializeEntity: anEntity;
		  yourself
]

{ #category : 'charts' }
FEBEntityCharts >> buildCharts [
	"Answer my charts, in the order of the dashboard's tabs"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
FEBEntityCharts >> chartTitled: aString [

	^ charts detect: [ :each | each title = aString ]
]

{ #category : 'accessing' }
FEBEntityCharts >> charts [

	^ charts
]

{ #category : 'private' }
FEBEntityCharts >> colorOf: aCategory [
	"The colour of a food category, the same in every chart, following the model's order of categories"

	^ FEBStepChart categoricalPalette at:
		  (entity cormasModel foodCategories indexOf: aCategory)
]

{ #category : 'private' }
FEBEntityCharts >> days [

	^ entity history days
]

{ #category : 'initialization' }
FEBEntityCharts >> initializeEntity: anEntity [

	entity := anEntity.
	stepClickedBlocks := OrderedCollection new.
	charts := self buildCharts.
	charts do: [ :each |
		each whenStepClickedDo: [ :step | self stepClicked: step ] ]
]

{ #category : 'private' }
FEBEntityCharts >> newChart: aTitle [

	^ FEBStepChart
		  title: aTitle
		  steps: (self days collect: [ :each | each step ])
]

{ #category : 'accessing' }
FEBEntityCharts >> selectStep: aStep [

	charts do: [ :each | each selectStep: aStep ]
]

{ #category : 'private' }
FEBEntityCharts >> stepClicked: aStep [

	stepClickedBlocks do: [ :each | each value: aStep ]
]

{ #category : 'private' }
FEBEntityCharts >> valuesPerDay: aBlock [

	^ self days collect: aBlock
]

{ #category : 'accessing' }
FEBEntityCharts >> whenStepClickedDo: aBlock [

	stepClickedBlocks add: aBlock
]
