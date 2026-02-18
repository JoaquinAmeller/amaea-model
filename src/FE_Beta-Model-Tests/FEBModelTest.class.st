Class {
	#name : 'FEBModelTest',
	#superclass : 'TestCase',
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'tests' }
FEBModelTest >> dummyModel [
	<script: 'self new dummyModel openSpacePresenter'>
	| model |

	model := FEBModel new 
		createGridNumberOfRows: 10
		numberOfColumns: 10
		neighbourhood: 8
		closed: true;
		yourself.
		
	model newEntity: FEBOutlet locatedAt: (model cellAt: 2 at: 3).
	model newEntity: FEBOutlet locatedAt: (model cellAt: 9 at: 8).
	model newEntity: FEBHousehold locatedAt: (model cellAt: 4 at: 2).
	
	^ model


]

{ #category : 'tests' }
FEBModelTest >> testTimeToTravelTo [

	| model household outlet1 outlet2 time1 time2 |
	model := self dummyModel.
	household := model households first.

	outlet1 := model outlets first.
	outlet2 := model outlets second.
	time1 := household timeToTravelTo: outlet1.
	time2 := household timeToTravelTo: outlet2.
	self assert: time1 < time2 
]
