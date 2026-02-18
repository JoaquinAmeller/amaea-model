Class {
	#name : 'FEBMoneySaverStrategy',
	#superclass : 'FEBStrategy',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'testing' }
FEBMoneySaverStrategy >> isMoneySaver [

	^ true
]

{ #category : 'as yet unclassified' }
FEBMoneySaverStrategy >> moneyThreshold [

	^ 0.2
]

{ #category : 'as yet unclassified' }
FEBMoneySaverStrategy >> shapeOfPov [ 

	^ #square
]

{ #category : 'as yet unclassified' }
FEBMoneySaverStrategy >> timeThreshold [

	^ 0.6
]
