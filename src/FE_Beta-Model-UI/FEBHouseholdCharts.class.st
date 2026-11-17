"
I am the five charts of a household's history over its recorded steps: its indicators, its meals, its purchases, the money and time it spent, and its stock with the food that spoiled.

## Responsibility:

- Chart the household's indicator scores and healthy diet as one line each.
- Chart its meals, purchases and stock per food category as stacked bars, with the daily need and the spoiled food.
- Chart the share of its money and time it spent shopping.

## Collaborators:

- `FEBEntityCharts`: my superclass, keeping the selected step and the clicks.
- `FEBHousehold`: its history of days and its indicators for any day.
- `FEBStepChart`: each chart.

## Public API and Key Messages

- `FEBHouseholdCharts on: aHousehold` creates me; `charts` answers my charts in the order of the dashboard's tabs.

```smalltalk
((FEBHouseholdCharts on: aHousehold) chartTitled: 'Meals') canvas open
```
"
Class {
	#name : 'FEBHouseholdCharts',
	#superclass : 'FEBEntityCharts',
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'charts' }
FEBHouseholdCharts >> buildCharts [

	^ {
		  self indicatorsChart.
		  self mealsChart.
		  self purchasesChart.
		  self moneyAndTimeChart.
		  self stockChart }
]

{ #category : 'charts' }
FEBHouseholdCharts >> household [

	^ entity
]

{ #category : 'charts' }
FEBHouseholdCharts >> indicatorsChart [
	"Satiety, and healthy diet at 1 on healthy days and 0 otherwise, range from 0 to 1 on the left axis. Caloric and protein adequacy are adequate at 1 but can go well above it, so they go on the right axis"

	| chart palette |
	chart := self newChart: 'Indicators'.
	chart yFrom: 0 to: 1.
	chart rightYFrom: 0 to: 1.
	palette := FEBStepChart categoricalPalette.
	chart
		line: 'Satiety'
		values:
		(self valuesPerDay: [ :day | self household satietyScoreOn: day ])
		color: palette first.
	chart
		line: 'Healthy diet'
		values: (self valuesPerDay: [ :day |
					 (self household isHavingHealthyDietOn: day)
						 ifTrue: [ 1 ]
						 ifFalse: [ 0 ] ])
		color: palette fourth.
	chart
		rightLine: 'Caloric adequacy (right axis)'
		values: (self valuesPerDay: [ :day |
				 self household caloricAdequacyScoreOn: day ])
		color: palette second.
	chart
		rightLine: 'Protein adequacy (right axis)'
		values: (self valuesPerDay: [ :day |
				 self household proteinAdequacyScoreOn: day ])
		color: palette third.
	^ chart
]

{ #category : 'charts' }
FEBHouseholdCharts >> mealsChart [

	| chart |
	chart := (self newChart: 'Meals')
		         beCounts;
		         yourself.
	entity cormasModel foodCategories do: [ :category |
			chart
				bars: category name
				values:
				(self valuesPerDay: [ :day | day numberOfMealsOf: category ])
				color: (self colorOf: category) ].
	chart
		guide: 'Daily need'
		at: self household dailyNeed
		color: Color gray.
	^ chart
]

{ #category : 'charts' }
FEBHouseholdCharts >> moneyAndTimeChart [
	"The share of the money and of the time available that the household spent shopping, 0 on days it did not go"

	| chart palette |
	chart := self newChart: 'Money and time spent'.
	chart yFrom: 0 to: 1.
	palette := FEBStepChart categoricalPalette.
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

{ #category : 'charts' }
FEBHouseholdCharts >> purchasesChart [

	| chart |
	chart := (self newChart: 'Purchases')
		         beCounts;
		         yourself.
	entity cormasModel foodCategories do: [ :category |
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

{ #category : 'charts' }
FEBHouseholdCharts >> stockChart [

	| chart |
	chart := (self newChart: 'Stock and spoiled food')
		         beCounts;
		         yourself.
	entity cormasModel foodCategories do: [ :category |
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
