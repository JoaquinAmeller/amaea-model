Class {
	#name : 'FEBOutlet',
	#superclass : 'CMAgent',
	#instVars : [
		'availableHealthyFood',
		'availableConventionalFood'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBOutlet >> availableConventionalFood [

	^ availableConventionalFood
]

{ #category : 'accessing' }
FEBOutlet >> availableHealthyFood [

	^ availableHealthyFood
]

{ #category : 'initialization' }
FEBOutlet >> initialize [

	super initialize.
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
FEBOutlet >> priceOfConventionalFoodPerUnit [

	^ 1
]

{ #category : 'as yet unclassified' }
FEBOutlet >> priceOfHealthyFoodPerUnit [

	^ 50
]

{ #category : 'as yet unclassified' }
FEBOutlet >> restock [

	availableHealthyFood := 37.
	availableConventionalFood := 37
]

{ #category : 'accessing' }
FEBOutlet >> sellConventionalFood: amount [
availableConventionalFood := availableConventionalFood - amount.
]

{ #category : 'accessing' }
FEBOutlet >> sellHealthyFood: amount [
availableHealthyFood := availableHealthyFood - amount.
]
