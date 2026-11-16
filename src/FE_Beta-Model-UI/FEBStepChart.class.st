"
I am a chart of values over the recorded time steps of an entity, with a line showing the selected step, and clicks that select a step.

## Responsibility:

- Collect named series over the steps: lines, and bars stacked above or below zero.
- Draw them with Roassal, with a legend, whole steps on the x axis and, for counts, whole numbers on the y axis, and keep a vertical line at the selected step.
- Turn a click anywhere on the chart into the closest recorded step and tell my listeners. I cannot be dragged, scrolled or zoomed.

## Collaborators:

- `FEBHouseholdCharts`: fills me with the series of a household's history; `FEBHouseholdDashboard` shows my canvas in a tab.
- `RSCompositeChart`, `RSLinePlot`, `RSBarPlot`, `RSLegend`: Roassal draws me.

## Public API and Key Messages

- `FEBStepChart title: 'Meals' steps: #(1 2 3)` creates me; `beCounts` makes my y axis count in whole numbers.
- `line:values:color:`, `bars:values:color:`, `barsBelow:values:color:` add series; `seriesNames` and `valuesOf:` answer them.
- `canvas` draws me the first time it is asked; `selectStep:`, `selectedStep`, `whenStepClickedDo:`, `xOfStep:`, `xTickValues`, `yTickValues`.

```smalltalk
| chart |
chart := FEBStepChart title: 'Meals' steps: #(1 2 3).
chart beCounts.
chart bars: 'Staple food' values: #(5 8 10) color: Color green.
chart line: 'Daily need' values: #(10 10 10) color: Color black.
chart selectStep: 2.
chart canvas open
```

## Internal Representation

- `series`: an OrderedCollection of Arrays `{ name. kind. values. color }`, where kind is `#line`, `#bars` or `#barsBelow`, in the order they were added; bars stack in that order.
- `chart` and `canvas`: the Roassal chart and its canvas, nil until first drawn; `selectionLine`: the RSLine at the selected step; `countsOnly`: whether my values are counts.

### Implementation Points

- The x axis goes half a step beyond the first and last steps, so that edge bars are whole and a single step still has a range. It labels at most about ten whole steps.
- My ticks are the chart's own default ticks, given explicit positions: adding tick decorations would draw a second, mismatched set of axes.
- Roassal sends a click to the shape under the mouse, so every shape, and the canvas, listens to clicks. The interactions Roassal gives a canvas (dragging, scrolling, zooming, keys) are removed.
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
		'stepClickedBlocks',
		'countsOnly'
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
		legend text: each first withBoxColor: each fourth ].
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
			kind = #line ifTrue: [
					aChart add: ((RSLinePlot new x: steps y: values)
							 color: each fourth;
							 width: 2;
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

{ #category : 'series' }
FEBStepChart >> beCounts [
	"My values are counts, such as meals: label them with whole numbers"

	countsOnly := true
]

{ #category : 'accessing' }
FEBStepChart >> canvas [

	canvas ifNil: [ self draw ].
	^ canvas
]

{ #category : 'accessing' }
FEBStepChart >> chartDecorations [

	self canvas.
	^ chart decorations
]

{ #category : 'private' }
FEBStepChart >> clickedAt: anX [

	steps ifEmpty: [ ^ self ].
	stepClickedBlocks do: [ :each | each value: (self stepAtX: anX) ]
]

{ #category : 'drawing' }
FEBStepChart >> draw [
	"Build the Roassal chart of my series, with whole steps and, for counts, whole numbers on its axes, its legend, the selected-step line and the clicks. The chart cannot be dragged, scrolled or zoomed."

	| xTicks yTicks |
	chart := RSCompositeChart new.
	chart extent: 800 @ 400.
	chart title: title.
	self addPlotsTo: chart.
	steps ifNotEmpty: [
			chart
				minChartValueX: steps first - 0.5;
				maxChartValueX: steps last + 0.5.
			xTicks := self xTickValues.
			chart
				xTicks: xTicks
				labels: (xTicks collect: [ :each | each printString ]) ].
	yTicks := self yTickValues.
	yTicks ifNotNil: [
			chart
				minChartValueY: yTicks first;
				maxChartValueY: yTicks last;
				yTicks: yTicks
				labels: (yTicks collect: [ :each | each printString ]) ].
	chart build.
	canvas := chart canvas.
	self addLegend.
	selectionLine := RSLine new
		                 color: Color darkGray;
		                 width: 1;
		                 yourself.
	canvas add: selectionLine.
	self placeSelectionLine.
	self removeCanvasInteractions.
	self listenToClicks.
	"Fill the space the chart is given in its window"
	canvas when: RSExtentChangedEvent do: [ canvas zoomToFit ] for: self
]

{ #category : 'private' }
FEBStepChart >> highestValue [
	"The top of the highest stack of bars or the highest point of a line"

	| stacked |
	stacked := steps collect: [ :each | 0 ].
	series do: [ :each |
		each second = #bars ifTrue: [ stacked := stacked + each third ] ].
	^ stacked , (series
		   select: [ :each | each second = #line ]
		   thenCollect: [ :each | each third max ])
		  inject: 0
		  into: [ :max :each | max max: each ]
]

{ #category : 'initialization' }
FEBStepChart >> initializeTitle: aString steps: aCollectionOfSteps [

	title := aString.
	steps := aCollectionOfSteps asArray.
	series := OrderedCollection new.
	stepClickedBlocks := OrderedCollection new.
	countsOnly := false
]

{ #category : 'series' }
FEBStepChart >> line: aName values: aCollection color: aColor [

	series add: {
			aName.
			#line.
			aCollection asArray.
			aColor }
]

{ #category : 'private' }
FEBStepChart >> listenToClicks [
	"A click goes to the shape under the mouse, bar, line or label, or to the canvas when there is none: listen to all of them"

	(canvas shapes copyWith: canvas) do: [ :each |
			each
				when: RSMouseClick
				do: [ :event | self clickedAt: event position x ]
				for: self ]
]

{ #category : 'private' }
FEBStepChart >> lowestValue [
	"The bottom of the stack of bars below zero, or zero"

	| stacked |
	stacked := steps collect: [ :each | 0 ].
	series do: [ :each |
		each second = #barsBelow ifTrue: [ stacked := stacked - each third ] ].
	^ stacked inject: 0 into: [ :min :each | min min: each ]
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

{ #category : 'private' }
FEBStepChart >> removeCanvasInteractions [
	"Remove the dragging, scrolling, zooming and keyboard navigation Roassal gives a canvas"

	((canvas announcer subscriptions subscriptions collect: [ :each |
		  each subscriber ]) asSet select: [ :each |
		 each isKindOf: RSInteraction ]) do: [ :each |
		canvas announcer unsubscribe: each ]
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
FEBStepChart >> seriesNames [

	^ series collect: [ :each | each first ]
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

{ #category : 'accessing' }
FEBStepChart >> xTickValues [
	"Whole steps to label, at most about ten of them, so that labels never repeat or overlap"

	| stride |
	steps ifEmpty: [ ^ #(  ) ].
	stride := (steps size / 10) ceiling max: 1.
	^ (1 to: steps size by: stride) collect: [ :index | steps at: index ]
]

{ #category : 'accessing' }
FEBStepChart >> yTickValues [
	"For counts, whole numbers spaced evenly from the lowest to the highest value drawn; otherwise nil, and Roassal chooses the ticks"

	| highest lowest stepSize |
	countsOnly ifFalse: [ ^ nil ].
	highest := self highestValue max: 1.
	lowest := self lowestValue.
	stepSize := #( 1 2 5 10 20 50 100 200 500 1000 2000 5000 10000 )
		            detect: [ :each | each >= (highest - lowest / 5) ]
		            ifNone: [ (highest - lowest / 5) ceiling ].
	^ ((lowest / stepSize) floor * stepSize to:
	   (highest / stepSize) ceiling * stepSize by: stepSize) asArray
]
