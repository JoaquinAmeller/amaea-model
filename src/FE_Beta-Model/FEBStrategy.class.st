Class {
	#name : 'FEBStrategy',
	#superclass : 'Object',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'testing' }
FEBStrategy >> isDesperateSaver [

	^ false
]

{ #category : 'testing' }
FEBStrategy >> isMoneySaver [

	^ false
]

{ #category : 'testing' }
FEBStrategy >> isRichBastard [

	^ false
]

{ #category : 'testing' }
FEBStrategy >> isTimeSaver [

	^ false
]

{ #category : 'as yet unclassified' }
FEBStrategy >> moneyThreshold [

	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
FEBStrategy >> shapeOfPov [

	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
FEBStrategy >> timeThreshold [

	self subclassResponsibility
]
