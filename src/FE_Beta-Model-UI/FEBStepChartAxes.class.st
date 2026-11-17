"
I draw the x and y axis lines of a `FEBStepChart`, without a frame around it, like the charts of Cormas' own windows.

## Responsibility:

- Draw the x axis along the bottom of the chart and the y axis along its left side, whatever the values: Roassal's line axes cross at zero instead, which puts the y axis through the bar of step 0 and hides the step labels behind bars below zero.

## Collaborators:

- `FEBStepChart`: gives me to its Roassal chart as its spine decoration.
- `RSLineSpineDecoration`: my superclass, which draws the two lines.

## Public API and Key Messages

- `aRoassalChart spineDecoration: FEBStepChartAxes new`

```smalltalk
| chart |
chart := RSCompositeChart new.
chart spineDecoration: FEBStepChartAxes new.
chart add: (RSBarPlot new x: #(0 1 2) y: #(5 -3 2)).
chart open
```
"
Class {
	#name : 'FEBStepChartAxes',
	#superclass : 'RSLineSpineDecoration',
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'accessing' }
FEBStepChartAxes >> zeroPoint [
	"The bottom left corner, where my axes cross"

	^ 0 @ self chart extent y
]
