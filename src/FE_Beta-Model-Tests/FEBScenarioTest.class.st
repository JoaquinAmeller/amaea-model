"
I check the scenarios of the experimental design: their supply against demand, and where their outlets are.

The scenario inits set the class parameters of households and outlets, so I save them before each test and restore them after it.
"
Class {
	#name : 'FEBScenarioTest',
	#superclass : 'TestCase',
	#instVars : [
		'householdParameters',
		'restockAmount'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'running' }
FEBScenarioTest >> householdParameterSelectors [

	^ #( #minHouseholdSize #maxHouseholdSize #availableMoneyPerStep
	     #availableTimePerStep #fridgeCapacity #consumptionStrategySymbol )
]

{ #category : 'running' }
FEBScenarioTest >> modelInitializedWith: anInitSelector [

	^ FEBModel new
		  perform: anInitSelector;
		  yourself
]

{ #category : 'running' }
FEBScenarioTest >> setUp [
	"The scenarios set the class parameters of households and outlets, which other tests rely on"

	super setUp.
	householdParameters := self householdParameterSelectors collect: [
		                       :each | FEBHousehold perform: each ].
	restockAmount := FEBOutlet restockAmount
]

{ #category : 'running' }
FEBScenarioTest >> supplyOverDemandWith: anInitSelector [

	| model |
	model := self modelInitializedWith: anInitSelector.
	^ model supply / model demand
]

{ #category : 'running' }
FEBScenarioTest >> tearDown [

	self householdParameterSelectors
		with: householdParameters
		do: [ :selector :value |
			FEBHousehold perform: selector asMutator with: value ].
	FEBOutlet restockAmount: restockAmount.
	super tearDown
]

{ #category : 'tests' }
FEBScenarioTest >> testEveryScenarioHasAHundredHouseholdsEachWithAPreference [

	#( #initBaseline #initAbundantSupply #initScarceSupply
	   #initNearOutlets #initUnequalDistance #initFoodDesert ) do: [
			:each |
			| households |
			households := (self modelInitializedWith: each) households.
			self assert: households size equals: 100.
			self assert: (households allSatisfy: [ :household |
					 household foodPreference notNil ]) ]
]

{ #category : 'tests' }
FEBScenarioTest >> testInAFoodDesertAllOutletsAreInTheNorthWestCorner [

	| outlets |
	outlets := (self modelInitializedWith: #initFoodDesert) outlets.
	self assert: outlets size equals: 10.
	self assert: (outlets allSatisfy: [ :each |
			 each cell rowNumber <= 10 and: [ each cell columnNumber <= 10 ] ])
]

{ #category : 'tests' }
FEBScenarioTest >> testScarceSupplyIsBelowDemandAndAbundantSupplyFarAbove [

	self assert: (self supplyOverDemandWith: #initScarceSupply) < 0.8.
	self assert: (self supplyOverDemandWith: #initAbundantSupply) > 2
]

{ #category : 'tests' }
FEBScenarioTest >> testTheBaselineSuppliesSlightlyMoreFoodThanHouseholdsNeed [

	| ratio |
	ratio := self supplyOverDemandWith: #initBaseline.
	self assert: ratio > 1.
	self assert: ratio < 1.3
]

{ #category : 'tests' }
FEBScenarioTest >> testTheProximityScenariosSupplyAsMuchFoodAsTheBaseline [

	| supply |
	supply := (self modelInitializedWith: #initBaseline) supply.
	#( #initNearOutlets #initUnequalDistance #initFoodDesert ) do: [
		:each |
		self assert: (self modelInitializedWith: each) supply equals: supply ]
]

{ #category : 'tests' }
FEBScenarioTest >> testWithUnequalDistanceAllOutletsAreInTheWestHalf [

	| outlets |
	outlets := (self modelInitializedWith: #initUnequalDistance) outlets.
	self assert: outlets size equals: 40.
	self assert:
		(outlets allSatisfy: [ :each | each cell columnNumber <= 15 ])
]
