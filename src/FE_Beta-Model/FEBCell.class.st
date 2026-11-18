Class {
	#name : 'FEBCell',
	#superclass : 'CMCell',
	#instVars : [
		'state'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'aspects' }
FEBCell >> aspectDefault: look [ 
	<aspect>
	look
		image: 'grass';
		borderThickness: 0
]

{ #category : 'aspects' }
FEBCell >> aspectWhite: look [ 
	<aspect>
	look color: Color white
]

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
FEBCell >> state [
	^ state
]

{ #category : 'as yet unclassified' }
FEBCell >> timeToTravelTo: anotherCell [

	| numberOfCellsToTravel |
	numberOfCellsToTravel := self distanceTo: anotherCell.
	
	"each cell takes 5 minutes walk to travel" 
	^ 5 minutes * numberOfCellsToTravel
]
