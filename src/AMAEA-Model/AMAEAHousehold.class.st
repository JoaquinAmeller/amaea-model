Class {
	#name : 'AMAEAHousehold',
	#superclass : 'CMAgent',
	#instVars : [
		'land'
	],
	#category : 'AMAEA-Model',
	#package : 'AMAEA-Model'
}

{ #category : 'accessing' }
AMAEAHousehold >> land [

	^ land
]

{ #category : 'accessing' }
AMAEAHousehold >> land: aCollectionOfCells [

	land := aCollectionOfCells.
	land do: [ :each | each household: self ]
]

{ #category : 'accessing' }
AMAEAHousehold >> pov [
   <pov>
	| colors |
	colors := { CMColor red . CMColor blue . CMColor green }.

    ^ CMPointOfView
        color: (colors at: (self id % colors size) + 1)
        shape: #star
        size: 0.6
]
