Class {
	#name : 'AMAEALandPlot',
	#superclass : 'CMCell',
	#instVars : [
		'household'
	],
	#category : 'AMAEA-Model',
	#package : 'AMAEA-Model'
}

{ #category : 'accessing' }
AMAEALandPlot >> household [

	^ household
]

{ #category : 'accessing' }
AMAEALandPlot >> household: aHousehold [

	household := aHousehold
]

{ #category : 'accessing' }
AMAEALandPlot >> pov [
	<pov>
	
	| color pov |
	color := household
		ifNil: [ Color gray ]
		ifNotNil: [ household pov color + Color lightGray ].
	
	pov := CMPointOfView color: color.
	
	household 
		ifNotNil: [ 
			pov
				borderColor: household pov color;
				borderWidth: 0.03 ].
	
	^ pov
	
	
]
