Class {
	#name : 'FEBHousehold',
	#superclass : 'CMAgent',
	#instVars : [
		'income',
		'need',
		'satisfactionMemory',
		'hungerMemory',
		'preference',
		'statePref',
		'outlets'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBHousehold >> buyFood [

	self outletsSortedByDistance do: [ :outlet |
			self buyFoodFrom: outlet.
			
			need > 0 ifFalse: [ 
				hungerMemory := 0.
				^ self ]. "^self is implicit in Pharo, it marks the end/execution of the method, it means stop executing here"

			 ].
		
	hungerMemory := hungerMemory+1.
]

{ #category : 'accessing' }
FEBHousehold >> buyFoodFrom: outlet [

	| amount |
	self doesPreferHealthy ifTrue: [
			amount := need min: outlet availableHealthyFood.
			outlet sellHealthyFood: amount.
			need := need - amount ].

	amount := need min: outlet availableConventionalFood.
	outlet sellConventionalFood: amount.
	need := need - amount.
]

{ #category : 'as yet unclassified' }
FEBHousehold >> doesPreferConventional [
"is a state: household prefers conventional food"
	"^ self satisfactionMemory < 3."
	
	^ statePref = #preferConventional
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> doesPreferHealthy [

	"^ self satisfactionMemory >= 3."
	
	^ statePref = #preferHealthy
	
]

{ #category : 'accessing' }
FEBHousehold >> initialize [

	super initialize.
	hungerMemory := 0.
	
]

{ #category : 'accessing' }
FEBHousehold >> outlets: aCollection [

	outlets := aCollection
]

{ #category : 'as yet unclassified' }
FEBHousehold >> outletsSortedByDistance [

^ outlets sorted: [ :a :b | (self cell distanceTo: a cell) < (self cell distanceTo: b cell) ]
]

{ #category : 'accessing' }
FEBHousehold >> pov [

	<pov>
		
	statePref = #preferConventional 
							ifTrue: [ ^ CMPointOfView  color: Color orange
																shape: #circle
																size: 0.9 ].
															
	statePref = #preferHealthy 
							ifTrue: [ ^ CMPointOfView  color: Color purple
																shape: #circle
																size: 0.9 ].
]

{ #category : 'as yet unclassified' }
FEBHousehold >> preferConventional [
"is a state: household prefers conventional food"
	"^ self satisfactionMemory < 3."
	
	statePref := #preferConventional
	
]

{ #category : 'as yet unclassified' }
FEBHousehold >> preferHealthy [

	"^ self satisfactionMemory >= 3."
	
	statePref := #preferHealthy
	
]

{ #category : 'accessing' }
FEBHousehold >> reconsiderPreference [

	self doesPreferHealthy ifTrue: [
		hungerMemory > 0 ifTrue: [ self preferConventional ] ]
]

{ #category : 'accessing' }
FEBHousehold >> step [

	need := 5.
	self buyFood.
	self reconsiderPreference .
]
