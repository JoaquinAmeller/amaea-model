Class {
	#name : 'FEBTimeSaverStrategy',
	#superclass : 'FEBStrategy',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'testing' }
FEBTimeSaverStrategy >> isTimeSaver [

	^ true
]

{ #category : 'as yet unclassified' }
FEBTimeSaverStrategy >> moneyThreshold [

	^ 0.6
]

{ #category : 'as yet unclassified' }
FEBTimeSaverStrategy >> shapeOfPov [ 

	^ #triangle
]

{ #category : 'as yet unclassified' }
FEBTimeSaverStrategy >> timeThreshold [

	^ 0.2
]
