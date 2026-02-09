Class {
	#name : 'FEBHousehold',
	#superclass : 'CMAgent',
	#instVars : [
		'need',
		'satisfactionMemory',
		'hungerMemory',
		'outlets',
		'unvisitedOutlets',
		'availableTime',
		'availableMoneyPerStep',
		'remainingMoney',
		'householdSize',
		'preference'
	],
	#classInstVars : [
		'minHouseholdSize',
		'maxHouseholdSize'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'initialization' }
FEBHousehold class >> initializeParameters [

	super initializeParameters.
	minHouseholdSize := 2.
	maxHouseholdSize := 5
]

{ #category : 'accessing' }
FEBHousehold class >> maxHouseholdSize [

	^ maxHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold class >> maxHouseholdSize: anObject [

	maxHouseholdSize := anObject
]

{ #category : 'accessing' }
FEBHousehold class >> minHouseholdSize [

	^ minHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold class >> minHouseholdSize: anObject [

	minHouseholdSize := anObject
]

{ #category : 'accessing' }
FEBHousehold >> buyAmountOfFood: amount for: moneySpent [

	remainingMoney := remainingMoney - moneySpent.
	need := need - amount
]

{ #category : 'accessing' }
FEBHousehold >> buyFood [

	| outlet currentCell |
	unvisitedOutlets := outlets copy.
	currentCell := self cell.

	[ unvisitedOutlets isEmpty ] whileFalse: [
			outlet := self unvisitedOutletClosestTo: currentCell.
			currentCell := outlet cell.
			unvisitedOutlets remove: outlet.

			self buyFoodFrom: outlet.

			need > 0 ifFalse: [ "Household isnt hungry"
					hungerMemory := 0.
					"^self is implicit in Pharo, it marks the end/execution of the method, it means stop executing here"
					^ self ] ].

	"Household is hungry"
	hungerMemory := hungerMemory + 1.
]

{ #category : 'accessing' }
FEBHousehold >> buyFoodFrom: outlet [

	self doesPreferHealthy 
		ifTrue: [outlet sellHealthyFoodTo: self] 
		ifFalse: [ outlet sellConventionalFoodTo: self ]
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> doesPreferConventional [
"is a state: household prefers conventional food"
	"^ self satisfactionMemory < 3."
	
	^ preference = #preferConventional
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> doesPreferHealthy [

	"^ self satisfactionMemory >= 3."
	
	^ preference = #preferHealthy
	
]

{ #category : 'accessing' }
FEBHousehold >> initialize [

	super initialize.
	satisfactionMemory := 2.
	hungerMemory := 0.
	availableMoneyPerStep := 100.

	householdSize := self
		                 randomIntegerBetween: self class minHouseholdSize
		                 and: self class maxHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold >> need [

	^ need
]

{ #category : 'accessing' }
FEBHousehold >> outlets: aCollection [

	outlets := aCollection
]

{ #category : 'accessing' }
FEBHousehold >> pov [

	<pov>
	| color min max size |
	"color := self doesPreferConventional
		ifTrue: [ Color orange ]
		ifFalse: [ Color purple ]."
	self doesPreferConventional ifTrue: [ color := Color orange ].
	self doesPreferHealthy ifTrue: [ color := Color purple ].

	min := self class minHouseholdSize.
	max := self class maxHouseholdSize.
	size := 0.5 + (householdSize - min / (max - min) asFloat * 0.5).

	^ CMPointOfView color: color shape: #circle size: size
]

{ #category : 'as yet unclassified' }
FEBHousehold >> preferConventional [
"is a state: household prefers conventional food"
	"^ self satisfactionMemory < 3."
	
	preference := #preferConventional
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> preferHealthy [

	"^ self satisfactionMemory >= 3."
	
	preference := #preferHealthy
	
]

{ #category : 'accessing' }
FEBHousehold >> reconsiderPreference [

	self doesPreferHealthy ifTrue: [
		satisfactionMemory = 0 ifTrue: [ self preferConventional ] ].

	self doesPreferConventional ifTrue: [
		satisfactionMemory > 3 ifTrue: [ self preferHealthy ] ]
]

{ #category : 'accessing' }
FEBHousehold >> step [

	availableTime := 4 hours. "available for getting food"
	remainingMoney := availableMoneyPerStep.
	need := 3 * householdSize. "3 meals times the number of persons in the household"

	self buyFood.
	self updateSatisfactionMemory.
	self reconsiderPreference.

]

{ #category : 'as yet unclassified' }
FEBHousehold >> unvisitedOutletClosestTo: aCell [

	| sortedUnvisitedOutlets |
	
	sortedUnvisitedOutlets := unvisitedOutlets sorted: [ :a :b |
		(a cell distanceTo: aCell) < (b cell distanceTo: aCell) ].
	
	^ sortedUnvisitedOutlets first
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> updateSatisfactionMemory [

	need = 0
		ifTrue: [ "household is satisfied"
			remainingMoney >= (0.4 * availableMoneyPerStep) 
				ifTrue: [satisfactionMemory := satisfactionMemory + 1 ] 
				ifFalse: [satisfactionMemory := 0]]
		ifFalse: [ "Household isnt satisfied" satisfactionMemory := 0 ]
]
