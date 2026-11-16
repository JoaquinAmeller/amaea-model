Class {
	#name : 'FEBModelTest',
	#superclass : 'TestCase',
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBModelTest >> bigGridModel [

	^ FEBModel new
		  initBigGridScenario;
		  yourself
]

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
	"Outlets set their prices for the model's food categories"
	model initializeFoodCategories.

	model newEntity: FEBOutlet locatedAt: (model cellAt: 2 at: 3).
	model newEntity: FEBOutlet locatedAt: (model cellAt: 9 at: 8).
	model newEntity: FEBHousehold locatedAt: (model cellAt: 4 at: 2).

	^ model
]

{ #category : 'helpers' }
FEBModelTest >> mealsEatenInFiveStepsWithSeed: aNumber [
	"Answer, for each household in turn, the food it ate each day of a big grid simulation run for 5 steps from that random seed"

	| simulation |
	simulation := (CMSimulation for: FEBModel new)
		              activeInitSelector: #initBigGridScenario;
		              activeControlSelector: #step;
		              randomSeed: aNumber;
		              hasFixedRandomSeed: true;
		              initializeSimulation;
		              yourself.
	5 timesRepeat: [ simulation runStep ].
	^ simulation cormasModel households asArray collect: [ :each |
			  each history days asArray collect: [ :day |
				  (day meals asArray collect: [ :meal | meal category name ]) sort ] ]
]

{ #category : 'tests' }
FEBModelTest >> testAModelWithoutHouseholdsCanBeObserved [
	"The number of households is a parameter that can be 0"

	| model |
	model := FEBModel new.

	self
		shouldnt: [
				model averageSatietyScore.
				model averageCaloricAdequacyScore.
				model averageProteinAdequacyScore ]
		raise: Error
]

{ #category : 'tests' }
FEBModelTest >> testAModelWithoutHouseholdsCanGiveOutStrategies [

	self shouldnt: [ FEBModel new initializeStrategies ] raise: Error
]

{ #category : 'tests' }
FEBModelTest >> testASimulationKeepsFoodAndMoneyValid [

	| model inventories |
	model := self bigGridModel.
	10 timesRepeat: [ model step ].

	self denyEmpty: model households.
	self denyEmpty: model outlets.
	model households do: [ :each | self assert: each remainingMoney >= 0 ].
	inventories := (model households collect: [ :each | each inventory ])
	               ,
	               (model outlets collect: [ :each |
		                each instVarNamed: #inventory ]).
	inventories do: [ :inventory |
			inventory batches do: [ :batch |
					self assert: batch quantity > 0.
					self deny: batch isExpired ] ]
]

{ #category : 'tests' }
FEBModelTest >> testEveryFridgeFoodHasASubstituteThatKeepsOutsideTheFridge [

	| model household fridgeFood |
	model := self bigGridModel.
	household := model households first.
	fridgeFood := model foodCategories select: [ :each |
		              each shouldBeStoredInFridge ].
	self denyEmpty: fridgeFood.
	fridgeFood do: [ :each |
			self deny: (household findNonPerishableSubstitutionFor: each)
					shouldBeStoredInFridge ]
]

{ #category : 'tests' }
FEBModelTest >> testEveryHouseholdKnowsEveryOutlet [

	| model |
	model := self bigGridModel.
	self denyEmpty: model households.
	model households do: [ :each |
		self assert: each outlets asSet equals: model outlets asSet ]
]

{ #category : 'tests' }
FEBModelTest >> testEveryHouseholdsPreferencesAddUpToOne [

	| households |
	households := self bigGridModel households.
	self denyEmpty: households.
	households do: [ :each |
			self assert:
				((each instVarNamed: #foodPreferenceProportions) values sum
					 closeTo: 1) ]
]

{ #category : 'tests' }
FEBModelTest >> testEveryoneHasExactlyOneCaloricAndOneProteinLevel [

	| simulation model |
	simulation := (CMSimulation for: FEBModel new)
		              activeInitSelector: #initBigGridScenario;
		              activeControlSelector: #step;
		              initializeSimulation;
		              yourself.
	3 timesRepeat: [ simulation runStep ].
	model := simulation cormasModel.

	self assert: model currentTimeStep equals: 3.
	self
		assert: model numberOfCaloricSeverelyInadequatePeople
			+ model numberOfCaloricInadequatePeople
			+ model numberOfCaloricAdequatePeople
			+ model numberOfCaloricExcessPeople
		equals: model totalNumberOfPeople.
	self
		assert: model numberOfProteinSeverelyInadequatePeople
			+ model numberOfProteinInadequatePeople
			+ model numberOfProteinAdequatePeople
		equals: model totalNumberOfPeople
]

{ #category : 'tests' }
FEBModelTest >> testFoodSoldByOutletsIsTheFoodBoughtByHouseholds [
	"Over one step: what outlets lose, other than spoiled food and counting their restock, households gain, other than what they eat and what spoils"

	| model outletInventories stockOf trashOf householdStock outletStock outletTrash soldByOutlets boughtByHouseholds eaten |
	model := self bigGridModel.
	model step.
	outletInventories := model outlets collect: [ :each |
		                     each instVarNamed: #inventory ].
	stockOf := [ :inventories |
	           inventories sum: [ :each | each totalQuantity ] ].
	trashOf := [ :inventories |
	           inventories sum: [ :each | each amountOfFoodInTrashbin ] ].
	householdStock := stockOf value:
		                  (model households collect: [ :each |
			                   each inventory ]).
	outletStock := stockOf value: outletInventories.
	outletTrash := trashOf value: outletInventories.

	model simulationContext currentTimeStep: 1.
	model step.

	eaten := model households sum: [ :each |
		         (each history dayAt: 1) meals size ].
	soldByOutlets := outletStock + model supply
	                 - ((trashOf value: outletInventories) - outletTrash)
	                 - (stockOf value: outletInventories).
	boughtByHouseholds := (stockOf value:
		                       (model households collect: [ :each |
			                        each inventory ])) - householdStock + eaten
	                      +
	                      (trashOf value:
		                       (model households collect: [ :each |
			                        each inventory ])).
	self assert: soldByOutlets > 0.
	self assert: soldByOutlets equals: boughtByHouseholds
]

{ #category : 'tests' }
FEBModelTest >> testHalfOfTheHouseholdsSaveMoneyAndHalfSaveTime [

	| households |
	households := self bigGridModel households.
	self assert: households size equals: 100.
	self
		assert: (households count: [ :each | each isMoneySaver ])
		equals: 50.
	self
		assert: (households count: [ :each | each isTimeSaver ])
		equals: 50
]

{ #category : 'tests' }
FEBModelTest >> testHouseholdSizesStayWithinTheirLimits [

	| households |
	households := self bigGridModel households.
	self denyEmpty: households.
	households do: [ :each |
			self assert: (each householdSize
					 between: FEBHousehold minHouseholdSize
					 and: FEBHousehold maxHouseholdSize) ]
]

{ #category : 'tests' }
FEBModelTest >> testHouseholdsNeedTenMealsPerPersonADay [

	| households |
	households := self bigGridModel households.
	self denyEmpty: households.
	households do: [ :each |
		self assert: each dailyNeed equals: 10 * each householdSize ]
]

{ #category : 'tests' }
FEBModelTest >> testTheSameRandomSeedGivesTheSameSimulation [

	| first second |
	first := self mealsEatenInFiveStepsWithSeed: 42.
	second := self mealsEatenInFiveStepsWithSeed: 42.

	self denyEmpty: first.
	self
		assert: first = second
		description:
		'Two simulations from the same seed fed households differently'
]

{ #category : 'tests' }
FEBModelTest >> testTimeToTravelTo [

	| model household outlet1 outlet2 time1 time2 |
	model := self dummyModel.
	household := model households first.

	outlet1 := model outlets first.
	outlet2 := model outlets second.
	time1 := household cell timeToTravelTo: outlet1 cell.
	time2 := household cell timeToTravelTo: outlet2 cell.
	self assert: time1 < time2 
]
