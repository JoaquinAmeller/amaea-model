"
I am one row of the indicators table of a household's day: an indicator's name, its score that day, its level and the colour of that level.

## Responsibility:

- Know an indicator's name, score and level for one day.
- Know the colour that shows the level, the same as in the model's perspectives.
- Print my score and level the way the dashboard shows them.

## Collaborators:

- `FEBHouseholdDayPresenter`: creates me for each indicator and lists me in its table.
- `FEBHousehold`: computes the scores, levels and colours I hold.

## Public API and Key Messages

- `name`, `score`, `level`, `color`, `scoreText`, `levelText`.
- Create me with `FEBIndicatorReading name: 'Satiety' score: 4/5 level: #unsatiated color: Color orange`.

```smalltalk
(FEBIndicatorReading name: 'Satiety' score: 4/5 level: #unsatiated color: Color orange) levelText
""'unsatiated'""
```

## Internal Representation

- `score`: a Number, or nil for an indicator without a score, such as healthy diet.
- `level`: a Symbol such as `#hungry` or `#severelyInadequate`.
"
Class {
	#name : 'FEBIndicatorReading',
	#superclass : 'Object',
	#instVars : [
		'name',
		'score',
		'level',
		'color'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'instance creation' }
FEBIndicatorReading class >> name: aString score: aNumber level: aSymbol color: aColor [

	^ self new
		  initializeName: aString
		  score: aNumber
		  level: aSymbol
		  color: aColor;
		  yourself
]

{ #category : 'accessing' }
FEBIndicatorReading >> color [

	^ color
]

{ #category : 'initialization' }
FEBIndicatorReading >> initializeName: aString score: aNumber level: aSymbol color: aColor [

	name := aString.
	score := aNumber.
	level := aSymbol.
	color := aColor
]

{ #category : 'accessing' }
FEBIndicatorReading >> level [

	^ level
]

{ #category : 'accessing' }
FEBIndicatorReading >> levelText [
	"The level in words: #severelyInadequate is 'severely inadequate'"

	^ (level asString piecesCutWhere: [ :a :b | b isUppercase ])
		  inject: ''
		  into: [ :text :each |
				  text isEmpty
					  ifTrue: [ each ]
					  ifFalse: [ text , ' ' , each asLowercase ] ]
]

{ #category : 'accessing' }
FEBIndicatorReading >> name [

	^ name
]

{ #category : 'accessing' }
FEBIndicatorReading >> score [

	^ score
]

{ #category : 'accessing' }
FEBIndicatorReading >> scoreText [

	^ score
		  ifNil: [ '' ]
		  ifNotNil: [ score asFloat printShowingDecimalPlaces: 2 ]
]
