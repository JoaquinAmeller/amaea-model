Class {
	#name : 'FEBModel',
	#superclass : 'CMModel',
	#instVars : [
		'listOfOutlets',
		'foodCategories'
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
FEBModel >> foodCategories [

	^ foodCategories
]

{ #category : 'accessing' }
FEBModel >> foodCategoryNamed: aString [

	^ foodCategories detect: [ :each | each name = aString ]
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
	
	self initializeFoodCategories.
	self initializeAgents.

]

{ #category : 'as yet unclassified' }
FEBModel >> initializeAgents [

	self create: 100 randomlyLocatedAloneEntitiesOfClass: FEBHousehold.

	self initializePreferences.
	self initializeStrategies.

	self create: 40 randomlyLocatedAloneEntitiesOfClass: FEBOutlet.

	self households do: [ :each | each outlets: self outlets ]
]

{ #category : 'initialization' }
FEBModel >> initializeFoodCategories [

	foodCategories := OrderedCollection withAll: {
		FEBFoodCategory
			named: 'Meat'
			shelfLifeInFridge: 5
			outsideFridge: 2.
			
		FEBFoodCategory
			named: 'Vegetables'
			shelfLifeInFridge: 7
			outsideFridge: 3.
			
		FEBFoodCategory
			named: 'Rice'
			shelfLifeInFridge: 30
			outsideFridge: 30.
			
		FEBFoodCategory
			named: 'Dairy'
			shelfLifeInFridge: 6
			outsideFridge: 2
	}
]

{ #category : 'initialization' }
FEBModel >> initializePreferences [

	| preferenceA preferenceB preferenceC |
	
	preferenceA := #('Meat' 'Rice' 'Vegetables' 'Dairy')
		collect: [ :name | self foodCategoryNamed: name ].
		
	preferenceB := #('Rice' 'Dairy' 'Vegetables' 'Meat')
		collect: [ :name | self foodCategoryNamed: name ].
		
	preferenceC := #('Vegetables' 'Rice' 'Meat' 'Dairy')
		collect: [ :name | self foodCategoryNamed: name ].

	(self shuffled: self households) withIndexDo: [ :household :index |
		index % 3 = 1 ifTrue: [ household foodPreferenceOrder: preferenceA copy ].
		index % 3 = 2 ifTrue: [ household foodPreferenceOrder: preferenceB copy ].
		index % 3 = 0 ifTrue: [ household foodPreferenceOrder: preferenceC copy ] ]
]

{ #category : 'initialization' }
FEBModel >> initializeStrategies [

	"You can change this number to be different than 50%"
	| proportion numberOfAgents shuffledAgents |
	
	"Create a copy of agents collection where agents are shuffled randomly. Now if we take the first half of that collection, this will give us exactly 50% of agents selected randomly. And the second half is another 50%"
	shuffledAgents := self agents asOrderedCollection shuffle.
	
	proportion := 0.5.
	numberOfAgents := self agents size.

	"First part - from 1 to p*N where N is the number of agents and p is proportion"
	(1 to: (proportion * numberOfAgents) asInteger) do: [ :i |
		(shuffledAgents at: i) beMoneySaver ].

	"Second part - from p*N to N (all other agents)"
	((proportion * numberOfAgents) asInteger to: numberOfAgents) do: [ :i |
		(shuffledAgents at: i) beTimeSaver ].
]

{ #category : 'as yet unclassified' }
FEBModel >> numberOfHungryPeople [

	<probeNamed: 'Number of hungry people' color: #red>
	^ (self households select: #isHungry ) sum: #householdSize 
]

{ #category : 'as yet unclassified' }
FEBModel >> numberOfSatisfiedPeople [

	<probeNamed: 'Number of satisfied people' color: #green>
	^ (self households select: #isSatisfied) sum: #householdSize
]

{ #category : 'accessing' }
FEBModel >> outlets [

 ^ self @@ FEBOutlet .
]

{ #category : 'as yet unclassified' }
FEBModel >> percentageOfHungryPeople [

	<probeNamed: 'Percentage of hungry people' color: #red>
	^ self numberOfHungryPeople / self totalNumberOfPeople
]

{ #category : 'as yet unclassified' }
FEBModel >> percentageOfSatisfiedPeople [

	<probeNamed: 'Percentage of satisfied people' color: #green>
	^ self numberOfSatisfiedPeople / self totalNumberOfPeople
]

{ #category : 'as yet unclassified' }
FEBModel >> step [

	<control>
	(self @@ FEBHousehold) shuffled do: #step.
	(self @@ FEBOutlet) shuffled do: #step.
]

{ #category : 'as yet unclassified' }
FEBModel >> totalNumberOfPeople [
^ self households sum: #householdSize 
]
