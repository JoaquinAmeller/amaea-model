"
I am a chart of values over the recorded time steps of an entity, with a line showing the selected step, and clicks that select a step.

## Responsibility:

- Collect named series over the steps: lines, and bars stacked above or below zero.
- Draw them with Roassal, with x and y axis lines but no frame, a legend, whole steps on the x axis, and a y axis from zero, or from the lowest value, to the highest value, or to the known range of my values; for counts, whole numbers. Lines measured in another unit, such as money, go on a second y axis on the right. Keep a vertical line at the selected step.
- Turn a click anywhere on the chart but the legend into the closest recorded step and tell my listeners; a click on a legend entry hides or shows its series, and its box is filled only while the series is shown. I cannot be dragged, scrolled or zoomed.

## Collaborators:

- `FEBHouseholdCharts`: fills me with the series of a household's history; `FEBHouseholdDashboard` shows my canvas in a tab.
- `RSCompositeChart`, `RSLinePlot`, `RSBarPlot`, `RSLegend`: Roassal draws me; `FEBStepChartAxes` draws my axis lines.

## Public API and Key Messages

- `FEBStepChart title: 'Meals' steps: #(1 2 3)` creates me; `beCounts` makes my y axis count in whole numbers.
- `line:values:color:`, `bars:values:color:`, `barsBelow:values:color:`, `rightLine:values:color:` add series; `seriesNames` and `valuesOf:` answer them, and `drawnValuesOf:` answers them as drawn against the left axis.
- `yFrom: 0 to: 1` says my values range from 0 to 1, such as shares: my y axis is that range unless a value goes beyond it; `rightYFrom:to:` does the same for the right axis.
- `guide:at:color:` adds a horizontal line at a value, labelled on the chart rather than in the legend.
- `toggleSeries:`, `isShowing:`, `shapesOf:` and `legendEntryOf:` hide and show series.
- `canvas` draws me the first time it is asked; `selectStep:`, `selectedStep`, `whenStepClickedDo:`, `xOfStep:`, `xTickValues`, `yTickValues`, `yTickLabels`, `rightTickValues`, `yLimits`.

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

- `series`: an OrderedCollection of Arrays `{ name. kind. values. color }`, where kind is `#line`, `#rightLine`, `#bars` or `#barsBelow`, in the order they were added; bars stack in that order.
- `chart` and `canvas`: the Roassal chart and its canvas, nil until first drawn; `selectionLine`: the RSLine at the selected step; `countsOnly`: whether my values are counts; `yMinimum` and `yMaximum`, `rightMinimum` and `rightMaximum`: the known ranges of my values on each axis, 0 to 0 when not known; `guides`: Arrays `{ name. value. color }`; `plots` and `legendEntries`: the Roassal plot and the legend entry of each series, by name; `hiddenSeries`: the names of the series hidden from the legend.

### Implementation Points

- The x axis goes half a step beyond the first and last steps, so that edge bars are whole and a single step still has a range. It labels at most about ten whole steps.
- My ticks are the chart's own default ticks, given explicit positions: adding tick decorations would draw a second, mismatched set of axes. Roassal ends each axis at its first and last ticks, so I always choose the y ticks myself, about five of them, 1, 2 or 5 times a power of ten apart, covering every value.
- A line on the right axis is scaled so that the right axis spans the left one, and labelled by a `RSVerticalRightTick`. `FEBStepChartAxes` keeps the axis lines at the bottom and left edges.
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
		'countsOnly',
		'yMinimum',
		'yMaximum',
		'guides',
		'rightMinimum',
		'rightMaximum',
		'plots',
		'legendEntries',
		'hiddenSeries'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'colors' }
FEBStepChart class >> categoricalPalette [
	"Categorical colours in a fixed order, validated for colour-blind readers when adjacent in stacks, bars and lines: blue, orange, aqua, yellow, magenta, green, violet, red"

	^ #( '2a78d6' 'eb6834' '1baf7a' 'eda100' 'e87ba4' '008300' '6250d6'
	     'e34948' ) collect: [ :each | Color fromHexString: each ]
]

{ #category : 'instance creation' }
FEBStepChart class >> title: aString steps: aCollectionOfSteps [

	^ self new
		  initializeTitle: aString steps: aCollectionOfSteps;
		  yourself
]

{ #category : 'drawing' }
FEBStepChart >> addGuides [
	"Each guide as a line across the chart, with its name above its right end"

	guides do: [ :each |
			| y label |
			y := self yOfValue: each second.
			canvas add: (RSLine new
					 startPoint: 0 @ y;
					 endPoint: chart extent x @ y;
					 color: each third;
					 width: 2;
					 yourself).
			label := RSLabel new
				         text: each first;
				         fontSize: 10;
				         color: each third;
				         yourself.
			label translateTo:
				chart extent x - (label width / 2) - 4
				@ (y - (label height / 2) - 2).
			canvas add: label ]
]

{ #category : 'drawing' }
FEBStepChart >> addLegend [
	"One entry per series, its box filled while the series is shown and empty once hidden: clicking an entry hides or shows its series"

	| legend |
	legend := RSLegend new.
	legend container: canvas.
	legend layout horizontal gapSize: 12.
	series do: [ :each |
			| entry name |
			name := each first.
			entry := legend text: name withBoxColor: each fourth.
			entry shapes first border: (RSBorder new
					 color: each fourth;
					 width: 1.5;
					 yourself).
			entry
				when: RSMouseClick
				do: [ :event | self toggleSeries: name ]
				for: self.
			legendEntries at: name put: entry ].
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
			| kind values plot |
			kind := each second.
			values := (self drawnValuesOf: each first) collect: [ :value |
				          value asFloat ].
			kind = #bars ifTrue: [
					plot := (RSBarPlot new x: steps y: values)
						        bottom: above;
						        yourself.
					above := above + values ].
			kind = #barsBelow ifTrue: [
					plot := (RSBarPlot new x: steps y: values negated)
						        bottom: below;
						        yourself.
					below := below - values ].
			(#( #line #rightLine ) includes: kind) ifTrue: [
					plot := (RSLinePlot new x: steps y: values)
						        width: 2;
						        yourself ].
			plot color: each fourth.
			plots at: each first put: plot.
			aChart add: plot ]
]

{ #category : 'drawing' }
FEBStepChart >> addRightAxisLine [
	"The axis line along the right edge, which Roassal does not draw for right ticks"

	self rightTickValues ifNil: [ ^ self ].
	canvas add: (RSLine new
			 startPoint: chart extent x @ 0;
			 endPoint: chart extent x @ chart extent y negated;
			 color: Color black;
			 yourself)
]

{ #category : 'drawing' }
FEBStepChart >> addRightAxisTo: aChart [
	"Ticks on the right for my lines on the right axis, if I have any"

	| ticks |
	ticks := self rightTickValues ifNil: [ ^ self ].
	aChart addDecoration: (RSVerticalRightTick new
			 values: {
					 ticks first.
					 ticks last };
			 ticks: ticks labels: (self labelsOf: ticks);
			 yourself)
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
	"Build the Roassal chart of my series, with x and y axis lines but no frame, whole steps on the x axis, my own ticks on the y axes, my guides, a legend, the selected-step line and the clicks. The chart cannot be dragged, scrolled or zoomed."

	| xTicks yTicks |
	chart := RSCompositeChart new.
	chart extent: 800 @ 400.
	chart spineDecoration: FEBStepChartAxes new.
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
	chart
		minChartValueY: yTicks first;
		maxChartValueY: yTicks last;
		yTicks: yTicks labels: (self labelsOf: yTicks).
	self addRightAxisTo: chart.
	chart build.
	canvas := chart canvas.
	self addRightAxisLine.
	self addGuides.
	self addLegend.
	selectionLine := RSLine new
		                 color: Color darkGray;
		                 width: 2;
		                 dashArray: #( 6 4 );
		                 yourself.
	canvas add: selectionLine.
	self placeSelectionLine.
	self removeCanvasInteractions.
	self listenToClicks.
	"Fill the space the chart is given in its window"
	canvas when: RSExtentChangedEvent do: [ canvas zoomToFit ] for: self
]

{ #category : 'accessing' }
FEBStepChart >> drawnValuesOf: aName [
	"The values of a series as drawn against my left axis: a line on the right axis is scaled so that its axis spans the left one"

	| entry left right |
	entry := series detect: [ :each | each first = aName ].
	entry second = #rightLine ifFalse: [ ^ entry third ].
	left := self yTickValues.
	right := self rightTickValues.
	^ entry third collect: [ :each |
			  left first + (each - right first * (left last - left first)
			   / (right last - right first)) ]
]

{ #category : 'adding' }
FEBStepChart >> guide: aName at: aValue color: aColor [
	"A horizontal line across the chart at aValue, such as a daily need, named by a label above it rather than in the legend"

	guides add: {
			aName.
			aValue.
			aColor }
]

{ #category : 'private' }
FEBStepChart >> highestValue [
	"The top of the highest stack of bars, the highest point of a line, or the highest guide"

	| stacked |
	stacked := steps collect: [ :each | 0 ].
	series do: [ :each |
		each second = #bars ifTrue: [ stacked := stacked + each third ] ].
	^ stacked , (series
		   select: [ :each | each second = #line ]
		   thenCollect: [ :each | each third max ])
	  , (guides collect: [ :each | each second ])
		  inject: 0
		  into: [ :max :each | max max: each ]
]

{ #category : 'initialization' }
FEBStepChart >> initializeTitle: aString steps: aCollectionOfSteps [

	title := aString.
	steps := aCollectionOfSteps asArray.
	series := OrderedCollection new.
	guides := OrderedCollection new.
	stepClickedBlocks := OrderedCollection new.
	countsOnly := false.
	yMinimum := 0.
	yMaximum := 0.
	rightMinimum := 0.
	rightMaximum := 0.
	plots := Dictionary new.
	legendEntries := Dictionary new.
	hiddenSeries := Set new
]

{ #category : 'showing series' }
FEBStepChart >> isShowing: aName [

	^ (hiddenSeries includes: aName) not
]

{ #category : 'private' }
FEBStepChart >> labelsOf: someTicks [
	"Each tick with as many decimals as their spacing needs, 0.2 apart as 0.0, 0.2, 0.4..."

	| decimals |
	decimals := 0.
	someTicks size > 1 ifTrue: [
			[
				(someTicks second - someTicks first * (10 raisedTo: decimals))
					isInteger ] whileFalse: [ decimals := decimals + 1 ] ].
	^ someTicks collect: [ :each |
			  decimals = 0
				  ifTrue: [ each printString ]
				  ifFalse: [ each asFloat printShowingDecimalPlaces: decimals ] ]
]

{ #category : 'showing series' }
FEBStepChart >> legendEntryOf: aName [

	self canvas.
	^ legendEntries at: aName
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
	"A click goes to the shape under the mouse, bar, line or label, or to the canvas when there is none: listen to all of them but the legend, whose entries hide and show their series"

	| legend |
	legend := legendEntries values flatCollect: [ :each |
			          {
				          each.
				          each parent } ].
	((canvas shapes copyWithoutAll: legend) copyWith: canvas) do: [ :each |
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

{ #category : 'series' }
FEBStepChart >> rightLine: aName values: aCollection color: aColor [
	"A line measured on a second y axis, on my right, such as money over bars counting meals"

	series add: {
			aName.
			#rightLine.
			aCollection asArray.
			aColor }
]

{ #category : 'accessing' }
FEBStepChart >> rightTickValues [
	"Evenly spaced values from zero to the highest value of my lines on the right axis, including the known range of those values, or nil when I have no such line"

	| values |
	values := (series select: [ :each | each second = #rightLine ])
		          flatCollect: [ :each | each third ].
	values ifEmpty: [ ^ nil ].
	^ self
		  ticksFrom: ((values min min: 0) min: rightMinimum)
		  to: (values max max: rightMaximum)
		  wholeNumbers: false
]

{ #category : 'series' }
FEBStepChart >> rightYFrom: aMinimum to: aMaximum [
	"The values of my lines on the right axis range from aMinimum to aMaximum: that axis covers that range, and more if a value goes beyond it"

	rightMinimum := aMinimum.
	rightMaximum := aMaximum
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

{ #category : 'showing series' }
FEBStepChart >> shapesOf: aName [
	"The Roassal shapes drawing the series named aName"

	self canvas.
	^ (plots at: aName) createdShapes
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

{ #category : 'private' }
FEBStepChart >> ticksFrom: aLowest to: aHighest wholeNumbers: aBoolean [
	"About five evenly spaced ticks, 1, 2 or 5 times a power of ten apart, from at most aLowest to at least aHighest. They are exact numbers, so that they can be labelled with as many decimals as their spacing needs"

	| highest spacing power |
	highest := aHighest = aLowest
		           ifTrue: [ aLowest + 1 ]
		           ifFalse: [ aHighest ].
	power := 10 raisedTo: (highest - aLowest / 5 log: 10) floor.
	spacing := #( 1 2 5 10 )
		           detect: [ :each |
		           each * power >= (highest - aLowest / 5) ]
		           ifNone: [ 10 ].
	spacing := spacing * power.
	aBoolean ifTrue: [ spacing := spacing max: 1 ].
	^ ((aLowest / spacing) floor * spacing to:
	   (highest / spacing) ceiling * spacing by: spacing) asArray
]

{ #category : 'accessing' }
FEBStepChart >> title [

	^ title
]

{ #category : 'showing series' }
FEBStepChart >> toggleSeries: aName [
	"Hide the series named aName if it is shown, show it otherwise, and fill its legend box to match"

	| color |
	(hiddenSeries includes: aName)
		ifTrue: [ hiddenSeries remove: aName ]
		ifFalse: [ hiddenSeries add: aName ].
	color := (self isShowing: aName)
		         ifTrue: [
		         (series detect: [ :each | each first = aName ]) fourth ]
		         ifFalse: [ Color transparent ].
	(self shapesOf: aName) do: [ :each | each color: color ].
	(self legendEntryOf: aName) shapes first color: color.
	canvas signalUpdate
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

{ #category : 'series' }
FEBStepChart >> yFrom: aMinimum to: aMaximum [
	"My values range from aMinimum to aMaximum, as shares range from 0 to 1: my y axis covers that range, and more if a value goes beyond it"

	yMinimum := aMinimum.
	yMaximum := aMaximum
]

{ #category : 'accessing' }
FEBStepChart >> yLimits [
	"The lowest and highest values of my drawn y axis"

	self canvas.
	^ {
		  chart minChartValueY.
		  chart maxChartValueY }
]

{ #category : 'accessing' }
FEBStepChart >> yOfValue: aNumber [
	"Where aNumber is on the canvas, against my left axis"

	self canvas.
	^ chart yScale scale: aNumber
]

{ #category : 'accessing' }
FEBStepChart >> yTickLabels [

	^ self labelsOf: self yTickValues
]

{ #category : 'accessing' }
FEBStepChart >> yTickValues [
	"Evenly spaced values from the lowest to the highest value drawn, including zero and the range of my values if it is known; whole numbers for counts"

	^ self
		  ticksFrom: (self lowestValue min: yMinimum)
		  to: (self highestValue max: yMaximum)
		  wholeNumbers: countsOnly
]
