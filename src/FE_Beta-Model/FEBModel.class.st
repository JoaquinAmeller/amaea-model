Class {
	#name : 'FEBModel',
	#superclass : 'CMAbstractModel',
	#instVars : [
		'listOfOutlets'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'as yet unclassified' }
FEBModel class >> modelName [

	^ 'FE_Beta'
]

{ #category : 'accessing' }
FEBModel class >> prefix [

	^ 'FEB'
]

{ #category : 'accessing' }
FEBModel >> households [

	^ self @@ FEBHousehold.
]

{ #category : 'as yet unclassified' }
FEBModel >> init [
	<init>
	| plots |
	self
		createGridNumberOfRows: 30
		numberOfColumns: 30
		neighbourhood: 8
		closed: true.
		
	plots := self @@ FEBCell.
	
	self initializeAgents .

]

{ #category : 'as yet unclassified' }
FEBModel >> initializeAgents [

	| shuffledAgents proportion numberOfAgents |
	self createN: 100 randomlyLocatedAloneEntities: FEBHousehold.

	"Create a copy of agents collection where agents are shuffled randomly. Now if we take the first half of that collection, this will give us exactly 50% of agents selected randomly. And the second half is another 50%"
	shuffledAgents := self agents asOrderedCollection shuffle.

	"You can change this number to be different than 50%"
	proportion := 0.5.
	numberOfAgents := self agents size.

	"First part - from 1 to p*N where N is the number of agents and p is proportion"
	(1 to: (proportion * numberOfAgents) asInteger) do: [ :i |
		(shuffledAgents at: i) preferHealthy ].

	"Second part - from p*N to N (all other agents)"
	((proportion * numberOfAgents) asInteger to: numberOfAgents) do: [ :i |
		(shuffledAgents at: i) preferConventional ].

	self createN: 10 randomlyLocatedAloneEntities: FEBOutlet.

	self households do: [ :each | each outlets: self outlets ]
]

{ #category : 'as yet unclassified' }
FEBModel >> numberOfConventionalHouseholds [

	<probeNamed: 'Number of conventional households' color: #orange>
	^ self households count: #doesPreferConventional
]

{ #category : 'as yet unclassified' }
FEBModel >> numberOfHealthyHouseholds [

	<probeNamed: 'Number of healthy households' color: #purple>
	^ self households count: #doesPreferHealthy
]

{ #category : 'accessing' }
FEBModel >> outlets [

 ^ self @@ FEBOutlet .
]

{ #category : 'as yet unclassified' }
FEBModel >> step [

	<control>
	(self @@ FEBHousehold) shuffled do: #step.

	(self @@ FEBOutlet) shuffled do: #restock.
]
