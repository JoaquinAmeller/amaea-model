Class {
	#name : 'FEBFoodInventory',
	#superclass : 'Object',
	#instVars : [
		'availableAmount',
		'pricePerUnit'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBFoodInventory >> availableAmount [

	^ availableAmount
]

{ #category : 'accessing' }
FEBFoodInventory >> availableAmount: anObject [

	availableAmount := anObject
]

{ #category : 'accessing' }
FEBFoodInventory >> pricePerUnit [

	^ pricePerUnit
]

{ #category : 'accessing' }
FEBFoodInventory >> pricePerUnit: anObject [

	pricePerUnit := anObject
]

{ #category : 'as yet unclassified' }
FEBFoodInventory >> takeUpTo: requestedAmount [

	| amount |
	amount := requestedAmount min: availableAmount.
	availableAmount := availableAmount - amount.
	^ amount
]
