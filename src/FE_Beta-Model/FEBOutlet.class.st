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
		size: 1.6.
		
		
		"borderColor: Color darkGray 
		borderWidth: 0.02."
	
]

{ #category : 'as yet unclassified' }
FEBOutlet >> restock [

	healthyFoodInventory availableAmount: 37000.
	conventionalFoodInventory availableAmount: 37000
]

{ #category : 'accessing' }
FEBOutlet >> sellConventionalFoodTo: household [

	self sellFoodFrom: conventionalFoodInventory to: household
]

{ #category : 'accessing' }
FEBOutlet >> sellFoodFrom: inventory to: household [

	| amount moneySpent |
	
	amount := inventory
		takeUpTo: household need
		withMoneyUpTo: household availableMoney.
		
	moneySpent := amount * inventory pricePerUnit.
	household buyAmountOfFood: amount for: moneySpent
]

{ #category : 'accessing' }
FEBOutlet >> sellHealthyFoodTo: household [

	self sellFoodFrom: healthyFoodInventory to: household 
]
