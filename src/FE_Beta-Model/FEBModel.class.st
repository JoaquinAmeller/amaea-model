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

{ #category : 'as yet unclassified' }
FEBModel >> amountOfSpoledFoodInHouseholds [

	<probeNamed: 'Amount of spoiled food in households' color: #brown>
	^ self households sum: [ :h | h inventory amountOfFoodInTrashbin ]
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
	self initializeSubstitutionList.
	self initializeStrategies.

	self create: 40 randomlyLocatedAloneEntitiesOfClass: FEBOutlet.

	self households do: [ :each | each outlets: self outlets ]
]

{ #category : 'initialization' }
FEBModel >> initializeFoodCategories [

	foodCategories := OrderedCollection withAll: {
		FEBFoodCategory new
			name: 'Animal proteins';
			shelfLifeInFridge: 5;
			shelfLifeOutsideFridge: 2;
			kilocaloriesPerPortion: 250;
			proteinsPerPortion: 30;
			yourself.
			
		FEBFoodCategory new
			name: 'Fruits and vegetables';
			shelfLifeInFridge: 7;
			shelfLifeOutsideFridge: 3;
			kilocaloriesPerPortion: 70;
			proteinsPerPortion: 2;
			yourself.
			
		FEBFoodCategory new
			name: 'Staple food';
			shelfLifeInFridge: 30;
			shelfLifeOutsideFridge: 30;
			kilocaloriesPerPortion: 190;
			proteinsPerPortion: 4;
			yourself.
			
		FEBFoodCategory new
			name: 'Dairy';
			shelfLifeInFridge: 6;
			shelfLifeOutsideFridge: 2;
			kilocaloriesPerPortion: 120;
			proteinsPerPortion: 7;
			yourself.
			
		FEBFoodCategory new
			name: 'Processed food';
			shelfLifeInFridge: 30;
			shelfLifeOutsideFridge: 30;
			kilocaloriesPerPortion: 750;
			proteinsPerPortion: 9;
			yourself.
	}
]

{ #category : 'initialization' }
FEBModel >> initializePreferences [

	| preferenceA preferenceB preferenceC |
	
	preferenceA := { "eats a lot of meat and dairy"
		(self foodCategoryNamed: 'Animal proteins') -> 0.35 .
		(self foodCategoryNamed: 'Fruits and vegetables') -> 0.15 .
		(self foodCategoryNamed: 'Staple food') -> 0.15 .
		(self foodCategoryNamed: 'Dairy') -> 0.3 .
		(self foodCategoryNamed: 'Processed food') -> 0.05 .
	} asDictionary.
	
	preferenceB := { "eats a lot of staple and processed food"
		(self foodCategoryNamed: 'Animal proteins') -> 0.1 .
		(self foodCategoryNamed: 'Fruits and vegetables') -> 0.1 .
		(self foodCategoryNamed: 'Staple food') -> 0.4 .
		(self foodCategoryNamed: 'Dairy') -> 0.1 .
		(self foodCategoryNamed: 'Processed food') -> 0.3 .
	} asDictionary.
	
	preferenceC := { "has a balanced diet"
		(self foodCategoryNamed: 'Animal proteins') -> 0.2 .
		(self foodCategoryNamed: 'Fruits and vegetables') -> 0.3 .
		(self foodCategoryNamed: 'Staple food') -> 0.25 .
		(self foodCategoryNamed: 'Dairy') -> 0.15 .
		(self foodCategoryNamed: 'Processed food') -> 0.1 .
	} asDictionary.

	(self shuffled: self households) withIndexDo: [ :household :index |
		index % 3 = 1 ifTrue: [ household foodPreferenceProportions: preferenceA copy ].
		index % 3 = 2 ifTrue: [ household foodPreferenceProportions: preferenceB copy ].
		index % 3 = 0 ifTrue: [ household foodPreferenceProportions: preferenceC copy ] ]
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

{ #category : 'initialization' }
FEBModel >> initializeSubstitutionList [

	| substitutionList |
	
	substitutionList := { 
		(self foodCategoryNamed: 'Animal proteins') -> (self foodCategoryNamed: 'Dairy') .
		(self foodCategoryNamed: 'Dairy') -> (self foodCategoryNamed: 'Staple food') .
		(self foodCategoryNamed: 'Fruits and vegetables') -> (self foodCategoryNamed: 'Staple food') .
		(self foodCategoryNamed: 'Staple food') -> (self foodCategoryNamed: 'Processed food')
	} asDictionary.
	
	self households do: [ :each |
		each substitutionList: substitutionList ]
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
