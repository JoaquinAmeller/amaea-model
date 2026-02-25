Class {
	#name : 'FEBHousehold',
	#superclass : 'CMAgent',
	#instVars : [
		'foodStorage',
		'satisfactionMemory',
		'hungerMemory',
		'outlets',
		'unvisitedOutlets',
		'availableMoneyPerStep',
		'remainingMoney',
		'householdSize',
		'preference',
		'availableTimePerStep',
		'remainingTime',
		'strategy',
		'dailyNeed'
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

{ #category : 'as yet unclassified' }
FEBHousehold >> availableMoney [

	^ remainingMoney 
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beDesperateSaver [
	<action>
	strategy := FEBDesperateSaverStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beMoneySaver [
	<action>
	strategy := FEBMoneySaverStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beRichBastard [
	<action>
	strategy := FEBRichBastardStrategy new
]

{ #category : 'as yet unclassified' }
FEBHousehold >> beTimeSaver [
	<action>
	strategy := FEBTimeSaverStrategy new
]

{ #category : 'accessing' }
FEBHousehold >> buyAmountOfFood: amount for: moneySpent [

	remainingMoney := remainingMoney - moneySpent.
	foodStorage := foodStorage + amount.
]

{ #category : 'accessing' }
FEBHousehold >> buyFood [

	| outlet currentCell timeToTravel |
	unvisitedOutlets := outlets copy.
	currentCell := self cell.

	[ unvisitedOutlets isEmpty ] whileFalse: [
			outlet := self unvisitedOutletClosestTo: currentCell.
			timeToTravel := currentCell timeToTravelTo: outlet cell.
			
			timeToTravel > remainingTime ifTrue: [ "Household is out of time"
				hungerMemory := hungerMemory + 1.
				"^self is implicit in Pharo, it marks the end/execution of the method, it means stop executing here"
				^ self ].
			
			currentCell := outlet cell.
			unvisitedOutlets remove: outlet.
			remainingTime := remainingTime - timeToTravel.
			
			self buyFoodFrom: outlet ].
]

{ #category : 'accessing' }
FEBHousehold >> buyFoodFrom: outlet [ 

	self doesPreferHealthy 
		ifTrue: [outlet sellHealthyFoodTo: self] 
		ifFalse: [ outlet sellConventionalFoodTo: self ]
		
	
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> consumeFood [

	foodStorage >= dailyNeed
		ifTrue: [
			"If hh has enough food to satisfy daily need so no hunger"
			foodStorage := foodStorage - dailyNeed . 
			hungerMemory := 0 ] 
		ifFalse: [
			"Hh has not enough food to satisfy daily need so eats what it has and there is hunger"
			foodStorage := 0 .
			hungerMemory := hungerMemory + 1 ].
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

{ #category : 'asserting' }
FEBHousehold >> goShopping [
<action> 
	self resetRemainingTimeAndMoney.
	self buyFood.
	self updateSatisfactionMemory.
	self reconsiderPreference.
]

{ #category : 'accessing' }
FEBHousehold >> householdSize [

	^ householdSize
]

{ #category : 'accessing' }
FEBHousehold >> initialize [

	super initialize.
	
	householdSize := self
		                 randomIntegerBetween: self class minHouseholdSize
		                 and: self class maxHouseholdSize.
		
	satisfactionMemory := 2.
	hungerMemory := 0.
	
	"3 meals times the number of persons in the household"
	dailyNeed := 3 * householdSize. 
	"Since HH consume food before buying it and then buy food for next day, they must be created with enough food for one day (the first food consumption)."
	foodStorage := dailyNeed . 

	
	"available for getting food"
	availableMoneyPerStep := 100.
	availableTimePerStep := 2 hours.
	
	"We need to do this to make sure that everyone is satisfied at init -> for the probe to work"
	self resetRemainingTimeAndMoney.
	
	"by default households prefer conventional just to avoid it to be nil.
	Init in the model will assign the proportions of preferences"
	self preferConventional.
	
	"by default households prefers to save money just to avoid it to be nil.
	Init in the model will assign the proportions of preferences"
	self beMoneySaver.
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isDesperateSaver [

	^ strategy isDesperateSaver
]

{ #category : 'testing' }
FEBHousehold >> isHungry [
^ hungerMemory > 0
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isMoneySaver [

	^ strategy isMoneySaver
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isRichBastard [

	^ strategy isRichBastard
]

{ #category : 'testing' }
FEBHousehold >> isSatisfied [

	^ self isHungry not
		and: [ remainingMoney >= (availableMoneyPerStep * self moneyThreshold)
			and: [ remainingTime >= (availableTimePerStep * self timeThreshold) ] ]
]

{ #category : 'as yet unclassified' }
FEBHousehold >> isTimeSaver [

	^ strategy isTimeSaver
]

{ #category : 'as yet unclassified' }
FEBHousehold >> moneyThreshold [

	^ strategy moneyThreshold
]

{ #category : 'accessing' }
FEBHousehold >> outlets [

	^ outlets
]

{ #category : 'accessing' }
FEBHousehold >> outlets: aCollection [

	outlets := aCollection
]

{ #category : 'accessing' }
FEBHousehold >> pov [

	<pov>
	| color |

	self doesPreferConventional ifTrue: [ color := Color orange ].
	self doesPreferHealthy ifTrue: [ color := Color purple ].

	^ CMPointOfView
		color: color
		shape: self shapeOfPovBasedOnStrategy
		size: self sizeOfPovBasedOnHouseholdSize
]

{ #category : 'accessing' }
FEBHousehold >> povSatisfaction [

	<pov>
	| color |

	self isSatisfied
		ifTrue: [ color := CMColor green ]
		ifFalse: [ color := CMColor red ].

	^ CMPointOfView
		color: color
		shape: self shapeOfPovBasedOnStrategy
		size: self sizeOfPovBasedOnHouseholdSize
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
FEBHousehold >> resetRemainingTimeAndMoney [

	remainingTime := availableTimePerStep.
	remainingMoney := availableMoneyPerStep.
]

{ #category : 'accessing' }
FEBHousehold >> shapeOfPovBasedOnStrategy [

	^ strategy shapeOfPov
]

{ #category : 'asserting' }
FEBHousehold >> shouldGoShopping [

^ true"foodStorage < (1 * dailyNeed )"
]

{ #category : 'accessing' }
FEBHousehold >> sizeOfPovBasedOnHouseholdSize [

	| min max |
	min := self class minHouseholdSize.
	max := self class maxHouseholdSize.
	^ 0.5 + (householdSize - min / (max - min) asFloat * 0.5)
]

{ #category : 'accessing' }
FEBHousehold >> step [

	"Households eat in the morning and then they consider buying food for the next day"
	self consumeFood.
	
	self shouldGoShopping ifTrue: [ 
		self goShopping ]

]

{ #category : 'as yet unclassified' }
FEBHousehold >> timeThreshold [

	^ strategy timeThreshold
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

	self isSatisfied
		ifTrue: [ satisfactionMemory := satisfactionMemory + 1 ] 
		ifFalse: [ satisfactionMemory := 0 ]
]
