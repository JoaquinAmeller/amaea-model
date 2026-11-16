"
I am the five charts of a household's history over its recorded steps: its indicators, its meals, its purchases, the money and time it spent, and its stock with the food that spoiled.

## Responsibility:

- Turn the household's days into the series of five `FEBStepChart`s.
- Give each food category the same colour in every chart, following the model's order of categories.
- Keep every chart's selected-step line on the selected step, and tell my listeners when a chart is clicked.

## Collaborators:

- `FEBHousehold`: its history of days and its indicators for any day.
- `FEBStepChart`: each chart.
- `FEBHouseholdDashboard`: shows each of my charts in its own tab, and links my clicks to its step navigator.

## Public API and Key Messages

- `FEBHouseholdCharts on: aHousehold` creates me.
- `charts`, `chartTitled:`, `selectStep:`, `whenStepClickedDo:`.

```smalltalk
((FEBHouseholdCharts on: aHousehold) chartTitled: 'Meals') canvas open
```

## Internal Representation

- `charts`: the five `FEBStepChart`, built when I am created, in the order of the dashboard's tabs.

### Implementation Points

- Category colours are the first slots of a categorical palette validated for colour-blind readers in stacks, bars and lines, given to categories in the model's fixed order, never by rank.
"
Class {
	#name : 'FEBHouseholdCharts',
	#superclass : 'Object',
	#instVars : [
		'household',
		'charts',
		'stepClickedBlocks'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'colors' }
FEBHouseholdCharts class >> categoricalPalette [
	"Categorical colours in a fixed order, validated for colour-blind readers when adjacent in stacks, bars and lines: blue, orange, aqua, yellow, magenta, green, violet, red"

	^ #( '2a78d6' 'eb6834' '1baf7a' 'eda100' 'e87ba4' '008300' '6250d6'
	     'e34948' ) collect: [ :each | Color fromHexString: each ]
]

{ #category : 'instance creation' }
FEBHouseholdCharts class >> on: aHousehold [

	^ self new
		  initializeHousehold: aHousehold;
		  yourself
]

{ #category : 'private' }
FEBHouseholdCharts >> buildCharts [

	^ {
		  self indicatorsChart.
		  self mealsChart.
		  self purchasesChart.
		  self moneyAndTimeChart.
		  self stockChart }
]

{ #category : 'accessing' }
FEBHouseholdCharts >> chartTitled: aString [

	^ charts detect: [ :each | each title = aString ]
]

{ #category : 'accessing' }
FEBHouseholdCharts >> charts [

	^ charts
]

{ #category : 'private' }
FEBHouseholdCharts >> colorOf: aCategory [
	"The colour of a food category, the same in every chart"

	^ self class categoricalPalette at:
		  (household cormasModel foodCategories indexOf: aCategory)
]

{ #category : 'private' }
FEBHouseholdCharts >> days [

	^ household history days
]

{ #category : 'charts' }
FEBHouseholdCharts >> indicatorsChart [

	| chart palette healthy |
	chart := self newChart: 'Indicators'.
	palette := self class categoricalPalette.
	chart
		line: 'Satiety'
		values:
		(self valuesPerDay: [ :day | household satietyScoreOn: day ])
		color: palette first.
	chart
		line: 'Caloric adequacy'
		values:
		(self valuesPerDay: [ :day | household caloricAdequacyScoreOn: day ])
		color: palette second.
	chart
		line: 'Protein adequacy'
		values:
		(self valuesPerDay: [ :day | household proteinAdequacyScoreOn: day ])
		color: palette third.
	#( 0.8 1 1.2 ) do: [ :each |
		chart guide: 'Level ' , each printString at: each ].
	healthy := self valuesPerDay: [ :day |
		           household isHavingHealthyDietOn: day ].
	chart
		bars: 'Healthy diet'
		values: (healthy collect: [ :each |
					 each
						 ifTrue: [ 0.1 ]
						 ifFalse: [ 0 ] ])
		color: (household colorOfLevel: #full).
	chart
		bars: 'Not a healthy diet'
		values: (healthy collect: [ :each |
					 each
						 ifTrue: [ 0 ]
						 ifFalse: [ 0.1 ] ])
		color: (household colorOfLevel: #hungry).
	^ chart
]

{ #category : 'initialization' }
FEBHouseholdCharts >> initializeHousehold: aHousehold [

	household := aHousehold.
	stepClickedBlocks := OrderedCollection new.
	charts := self buildCharts.
	charts do: [ :each |
		each whenStepClickedDo: [ :step | self stepClicked: step ] ]
]

{ #category : 'charts' }
FEBHouseholdCharts >> mealsChart [

	| chart |
	chart := self newChart: 'Meals'.
	household cormasModel foodCategories do: [ :category |
			chart
				bars: category name
				values:
				(self valuesPerDay: [ :day | day numberOfMealsOf: category ])
				color: (self colorOf: category) ].
	chart
		line: 'Daily need'
		values: (self valuesPerDay: [ :day | household dailyNeed ])
		color: Color darkGray.
	^ chart
]

{ #category : 'charts' }
FEBHouseholdCharts >> moneyAndTimeChart [
	"The share of the money and of the time available that the household spent shopping, 0 on days it did not go"

	| chart palette |
	chart := self newChart: 'Money and time spent'.
	palette := self class categoricalPalette.
	chart
		line: 'Money'
		values: (self valuesPerDay: [ :day |
					 day wentShopping
						 ifTrue: [ day moneySpent / day moneyAvailable ]
						 ifFalse: [ 0 ] ])
		color: palette first.
	chart
		line: 'Time'
		values: (self valuesPerDay: [ :day |
					 day wentShopping
						 ifTrue: [ day timeSpent / day timeAvailable ]
						 ifFalse: [ 0 ] ])
		color: palette second.
	^ chart
]

{ #category : 'private' }
FEBHouseholdCharts >> newChart: aTitle [

	^ FEBStepChart
		  title: aTitle
		  steps: (self days collect: [ :each | each step ])
]

{ #category : 'charts' }
FEBHouseholdCharts >> purchasesChart [

	| chart |
	chart := self newChart: 'Purchases'.
	household cormasModel foodCategories do: [ :category |
			chart
				bars: category name
				values: (self valuesPerDay: [ :day |
							 day purchases inject: 0 into: [ :sum :each |
									 each category = category
										 ifTrue: [ sum + each quantity ]
										 ifFalse: [ sum ] ] ])
				color: (self colorOf: category) ].
	^ chart
]

{ #category : 'accessing' }
FEBHouseholdCharts >> selectStep: aStep [

	charts do: [ :each | each selectStep: aStep ]
]

{ #category : 'private' }
FEBHouseholdCharts >> stepClicked: aStep [

	stepClickedBlocks do: [ :each | each value: aStep ]
]

{ #category : 'charts' }
FEBHouseholdCharts >> stockChart [

	| chart |
	chart := self newChart: 'Stock and spoiled food'.
	household cormasModel foodCategories do: [ :category |
			chart
				bars: category name
				values:
				(self valuesPerDay: [ :day | (day stockOf: category) total ])
				color: (self colorOf: category) ].
	chart
		barsBelow: 'Spoiled food'
		values: (self valuesPerDay: [ :day | day spoiledFood size ])
		color: Color gray.
	^ chart
]

{ #category : 'private' }
FEBHouseholdCharts >> valuesPerDay: aBlock [

	^ self days collect: aBlock
]

{ #category : 'accessing' }
FEBHouseholdCharts >> whenStepClickedDo: aBlock [

	stepClickedBlocks add: aBlock
]
