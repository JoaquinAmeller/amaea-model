Class {
	#name : 'FEBOutlet',
	#superclass : 'CMAgent',
	#instVars : [
		'conventionalFoodInventory',
		'healthyFoodInventory'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'initialization' }
FEBOutlet >> initialize [

	super initialize.

	healthyFoodInventory := FEBFoodInventory new.
	conventionalFoodInventory := FEBFoodInventory new.

	healthyFoodInventory pricePerUnit: 15.
	conventionalFoodInventory pricePerUnit: 5.

	self restock
]

{ #category : 'as yet unclassified' }
FEBOutlet >> pov [
	<pov>
	
	^ CMPointOfView
		color: Color gray
		shape: #square 
		size: 1.
		
		
		"borderColor: Color darkGray 
		borderWidth: 0.02."
	
]

{ #category : 'as yet unclassified' }
FEBOutlet >> restock [

	healthyFoodInventory availableAmount: 25.
	conventionalFoodInventory availableAmount: 25
]

{ #category : 'accessing' }
FEBOutlet >> sellConventionalFoodUpTo: aFoodAmount withMoneyUpTo: aMoneyAmount to: aHousehold [ 

	self sellFoodUpTo: aFoodAmount withMoneyUpTo: aMoneyAmount from: conventionalFoodInventory to: aHousehold 
]

{ #category : 'accessing' }
FEBOutlet >> sellFoodUpTo: aFoodAmount withMoneyUpTo: aMoneyAmount from: anInventory to: aHousehold [

	| amount moneySpent |
	
	amount := anInventory
		takeUpTo: aFoodAmount 
		withMoneyUpTo: aMoneyAmount .
		
	moneySpent := amount * anInventory pricePerUnit.
	aHousehold buyAmountOfFood: amount for: moneySpent
]

{ #category : 'accessing' }
FEBOutlet >> sellHealthyFoodUpTo: aFoodAmount withMoneyUpTo: aMoneyAmount to: aHousehold [ 

	self sellFoodUpTo: aFoodAmount withMoneyUpTo: aMoneyAmount from: healthyFoodInventory to: aHousehold 
]
