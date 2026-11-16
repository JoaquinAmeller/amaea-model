"
I am a chart of values over the recorded time steps of an entity, with a line showing the selected step, and clicks that select a step.

## Responsibility:

- Collect named series over the steps: lines, bars stacked above zero, bars stacked below zero, and horizontal guides.
- Draw them with Roassal, with a legend, and keep a vertical line at the selected step.
- Turn a click into the closest recorded step and tell my listeners.

## Collaborators:

- `FEBHouseholdCharts`: fills me with the series of a household's history; `FEBHouseholdDashboard` shows my canvas in a tab.
- `RSCompositeChart`, `RSLinePlot`, `RSBarPlot`, `RSLegend`: Roassal draws me.

## Public API and Key Messages

- `FEBStepChart title: 'Meals' steps: #(1 2 3)` creates me.
- `line:values:color:`, `bars:values:color:`, `barsBelow:values:color:`, `guide:at:` add series; `valuesOf:` answers a series' values.
- `canvas` draws me the first time it is asked; `selectStep:`, `selectedStep`, `whenStepClickedDo:`, `xOfStep:`.

```smalltalk
| chart |
chart := FEBStepChart title: 'Meals' steps: #(1 2 3).
chart bars: 'Staple food' values: #(5 8 10) color: Color green.
chart line: 'Daily need' values: #(10 10 10) color: Color black.
chart selectStep: 2.
chart canvas open
```

## Internal Representation

- `series`: an OrderedCollection of Arrays `{ name. kind. values. color }`, where kind is `#line`, `#bars`, `#barsBelow` or `#guide`, in the order they were added; bars stack in that order.
- `chart` and `canvas`: the Roassal chart and its canvas, nil until first drawn; `selectionLine`: the RSLine at the selected step.

### Implementation Points

- The x axis goes half a step beyond the first and last steps, so that edge bars are whole and a single step still has a range.
"
Class {
	#name : 'FEBStepChart',
	#superclass : 'Object',
	#instVars : [
		'title',
		'steps',
		'series',
		'chart',
		'canvas',
		'selectionLine',
		'selectedStep',
		'stepClickedBlocks'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'instance creation' }
FEBStepChart class >> title: aString steps: aCollectionOfSteps [

	^ self new
		  initializeTitle: aString steps: aCollectionOfSteps;
		  yourself
]

{ #category : 'drawing' }
FEBStepChart >> addLegend [

	| legend |
	legend := RSLegend new.
	legend container: canvas.
	legend layout horizontal gapSize: 12.
	series do: [ :each |
			each second = #guide ifFalse: [
				legend text: each first withBoxColor: each fourth ] ].
	legend location below offset: 0 @ 18.
	legend build
]

{ #category : 'drawing' }
FEBStepChart >> addPlotsTo: aChart [

	| above below |
	steps ifEmpty: [ ^ self ].
	above := steps collect: [ :each | 0 ].
	below := steps collect: [ :each | 0 ].
	series do: [ :each |
			| kind values |
			kind := each second.
			values := each third collect: [ :value | value asFloat ].
			kind = #bars ifTrue: [
					aChart add: ((RSBarPlot new x: steps y: values)
							 bottom: above;
							 color: each fourth;
							 yourself).
					above := above + values ].
			kind = #barsBelow ifTrue: [
					aChart add: ((RSBarPlot new x: steps y: values negated)
							 bottom: below;
							 color: each fourth;
							 yourself).
					below := below - values ].
			(#( #line #guide ) includes: kind) ifTrue: [
					aChart add: ((RSLinePlot new x: steps y: values)
							 color: each fourth;
							 width: (kind = #line
									  ifTrue: [ 2 ]
									  ifFalse: [ 1 ]);
							 yourself) ] ]
]

{ #category : 'series' }
FEBStepChart >> bars: aName values: aCollection color: aColor [
	"Bars stacked above zero, on top of the bars added before"

	series add: {
			aName.
			#bars.
			aCollection asArray.
			aColor }
]

{ #category : 'series' }
FEBStepChart >> barsBelow: aName values: aCollection color: aColor [
	"Bars stacked below zero, under the bars below zero added before"

	series add: {
			aName.
			#barsBelow.
			aCollection asArray.
			aColor }
]

{ #category : 'accessing' }
FEBStepChart >> canvas [

	canvas ifNil: [ self draw ].
	^ canvas
]

{ #category : 'private' }
FEBStepChart >> clickedAt: anX [

	steps ifEmpty: [ ^ self ].
	stepClickedBlocks do: [ :each | each value: (self stepAtX: anX) ]
]

{ #category : 'drawing' }
FEBStepChart >> draw [
	"Build the Roassal chart of my series, its legend, the selected-step line and the click handler"

	chart := RSCompositeChart new.
	chart extent: 800 @ 400.
	chart title: title.
	steps ifNotEmpty: [
			chart
				minChartValueX: steps first - 0.5;
				maxChartValueX: steps last + 0.5 ].
	self addPlotsTo: chart.
	chart addDecoration: RSHorizontalTick new integer.
	chart addDecoration: RSVerticalTick new.
	chart build.
	canvas := chart canvas.
	self addLegend.
	selectionLine := RSLine new
		                 color: Color darkGray;
		                 width: 1;
		                 yourself.
	canvas add: selectionLine.
	self placeSelectionLine.
	canvas
		when: RSMouseClick
		do: [ :event | self clickedAt: event position x ]
		for: self.
	"Fill the space the chart is given in its window"
	canvas when: RSExtentChangedEvent do: [ canvas zoomToFit ] for: self
]

{ #category : 'series' }
FEBStepChart >> guide: aName at: aValue [
	"A thin horizontal line at aValue, such as a threshold"

	series add: {
			aName.
			#guide.
			(steps collect: [ :each | aValue ]).
			Color lightGray }
]

{ #category : 'initialization' }
FEBStepChart >> initializeTitle: aString steps: aCollectionOfSteps [

	title := aString.
	steps := aCollectionOfSteps asArray.
	series := OrderedCollection new.
	stepClickedBlocks := OrderedCollection new
]

{ #category : 'series' }
FEBStepChart >> line: aName values: aCollection color: aColor [

	series add: {
			aName.
			#line.
			aCollection asArray.
			aColor }
]

{ #category : 'selecting' }
FEBStepChart >> placeSelectionLine [

	| x |
	selectedStep ifNil: [ ^ self ].
	x := chart xScale scale: selectedStep.
	selectionLine
		startPoint: x @ (chart yScale scale: chart minChartValueY);
		endPoint: x @ (chart yScale scale: chart maxChartValueY).
	canvas signalUpdate
]

{ #category : 'selecting' }
FEBStepChart >> selectStep: aStep [

	selectedStep := aStep.
	selectionLine ifNotNil: [ self placeSelectionLine ]
]

{ #category : 'accessing' }
FEBStepChart >> selectedStep [

	^ selectedStep
]

{ #category : 'accessing' }
FEBStepChart >> stepAtX: anX [
	"The recorded step closest to anX on the canvas"

	^ steps detectMin: [ :each | ((self xOfStep: each) - anX) abs ]
]

{ #category : 'accessing' }
FEBStepChart >> steps [

	^ steps
]

{ #category : 'accessing' }
FEBStepChart >> title [

	^ title
]

{ #category : 'series' }
FEBStepChart >> valuesOf: aName [

	^ (series detect: [ :each | each first = aName ]) third
]

{ #category : 'selecting' }
FEBStepChart >> whenStepClickedDo: aBlock [

	stepClickedBlocks add: aBlock
]

{ #category : 'accessing' }
FEBStepChart >> xOfStep: aStep [

	self canvas.
	^ chart xScale scale: aStep
]
