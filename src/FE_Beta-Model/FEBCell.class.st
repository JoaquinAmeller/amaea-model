Class {
	#name : 'FEBCell',
	#superclass : 'CMCell',
	#instVars : [
		'state'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'initialization' }
FEBCell >> initialize [

	super initialize.
	self isEmpty.
	state := #empty
]

{ #category : 'accessing' }
FEBCell >> isEmpty [

	^ state = #empty
]

{ #category : 'accessing' }
FEBCell >> pov [ 

	<pov>
	
	state = #empty ifTrue: [ ^ CMPointOfView color: Color white ].
]

{ #category : 'accessing' }
FEBCell >> state [
	^ state
]
