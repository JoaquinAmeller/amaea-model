"
I am the four charts of an outlet's history over its recorded steps: its sales, the food that came in and went out, its stock, and the households it served.

## Responsibility:

- Chart the outlet's sales per food category as stacked bars.
- Chart the food restocked above zero against the food sold and spoiled below it, and its stock per category with the part in its last day.
- Chart the number of households served each day.

## Collaborators:

- `FEBEntityCharts`: my superclass, keeping the selected step and the clicks.
- `FEBOutlet`: its history of days.
- `FEBStepChart`: each chart.

## Public API and Key Messages

- `FEBOutletCharts on: anOutlet` creates me; `charts` answers my charts in the order of the dashboard's tabs.

```smalltalk
((FEBOutletCharts on: anOutlet) chartTitled: 'Sales') canvas open
```

### Implementation Points

- Sales are not drawn with the revenue: one is in meals and the other in money, which would need two y axes on one chart. The revenue is on the ""Day"" tab.
"
Class {
	#name : 'FEBOutletCharts',
	#superclass : 'FEBEntityCharts',
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'charts' }
FEBOutletCharts >> buildCharts [

	^ {
		  self salesChart.
		  self foodInAndOutChart.
		  self stockChart.
		  self householdsChart }
]

{ #category : 'charts' }
FEBOutletCharts >> foodInAndOutChart [
	"The food restocked above zero, and the food sold and spoiled below it"

	| chart palette |
	chart := (self newChart: 'Food in and out')
		         beCounts;
		         yourself.
	palette := FEBStepChart categoricalPalette.
	chart
		bars: 'Restocked'
		values: (self valuesPerDay: [ :day | day restock size ])
		color: palette first.
	chart
		barsBelow: 'Sold'
		values: (self valuesPerDay: [ :day |
				 day sales inject: 0 into: [ :sum :each | sum + each quantity ] ])
		color: palette second.
	chart
		barsBelow: 'Spoiled'
		values: (self valuesPerDay: [ :day | day spoiledFood size ])
		color: Color gray.
	^ chart
]

{ #category : 'charts' }
FEBOutletCharts >> householdsChart [

	| chart |
	chart := (self newChart: 'Households served')
		         beCounts;
		         yourself.
	chart
		line: 'Households'
		values: (self valuesPerDay: [ :day |
				 (day sales collect: [ :each | each household ]) asSet size ])
		color: FEBStepChart categoricalPalette first.
	^ chart
]

{ #category : 'charts' }
FEBOutletCharts >> salesChart [
	"The meals sold per food category, and the revenue on a second axis"

	| chart |
	chart := (self newChart: 'Sales')
		         beCounts;
		         yourself.
	entity cormasModel foodCategories do: [ :category |
			chart
				bars: category name
				values:
				(self valuesPerDay: [ :day | self soldOf: category on: day ])
				color: (self colorOf: category) ].
	chart
		rightLine: 'Revenue (right axis)'
		values: (self valuesPerDay: [ :day |
				 day sales inject: 0 into: [ :sum :each | sum + each price ] ])
		color: Color black.
	^ chart
]

{ #category : 'private' }
FEBOutletCharts >> soldOf: aCategory on: aDay [

	^ aDay sales inject: 0 into: [ :sum :each |
			  each category = aCategory
				  ifTrue: [ sum + each quantity ]
				  ifFalse: [ sum ] ]
]

{ #category : 'charts' }
FEBOutletCharts >> stockChart [

	| chart |
	chart := (self newChart: 'Stock')
		         beCounts;
		         yourself.
	entity cormasModel foodCategories do: [ :category |
			chart
				bars: category name
				values:
				(self valuesPerDay: [ :day | (day stockOf: category) total ])
				color: (self colorOf: category) ].
	chart
		line: 'In their last day'
		values: (self valuesPerDay: [ :day |
				 day stock inject: 0 into: [ :sum :each | sum + each inLastDay ] ])
		color: Color darkGray.
	^ chart
]
