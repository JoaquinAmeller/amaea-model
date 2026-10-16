Class {
	#name : 'FEBOutlet',
	#superclass : 'CMAgent',
	#instVars : [
		'inventory',
		'conventionalFoodInventory',
		'healthyFoodInventory',
		'prices'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'initialization' }
FEBOutlet >> initialize [

	super initialize.
	
	self initializePrices.
	
	inventory := FEBFoodInventory new.
	self restock.
]

{ #category : 'initialization' }
FEBOutlet >> initializePrices [

	| categories |
	categories := cormasModel foodCategories.
	
	self flag: 'TODO'.
	prices := (categories collect: [ :category |
		category -> 5 ]) asDictionary
]

{ #category : 'as yet unclassified' }
FEBOutlet >> inventorySize [

	^ inventory totalQuantity 
]

{ #category : 'as yet unclassified' }
FEBOutlet >> pov [
	<pov>
	
	^ CMPointOfView
		color: Color gray
		shape: #square 
		size: 1
]

{ #category : 'as yet unclassified' }
FEBOutlet >> pricePerUnitFor: aCategory [

	^ prices at: aCategory 
]

{ #category : 'as yet unclassified' }
FEBOutlet >> restock [

	| categories category batch |
	categories := prices keys.
	
	self flag: 'TODO'.
	
	10 timesRepeat: [ 
		"Choose random category.
		Get random quantity of food of that category.
		Assume infinite fridge capacity"
		category := self selectRandomlyFrom: categories.
		
		batch := FEBFoodBatch
			category: category
			quantity: (self randomIntegerBetween: 1 and: 20)
			fridge: category shouldBeStoredInFridge.
			
		inventory addBatch: batch ]
]

{ #category : 'accessing' }
FEBOutlet >> sellCategory: aCategory quantityUpTo: aFoodQuantity withMoneyUpTo: aMoneyAmount to: aHousehold [

	| batches quantity price |
	
	batches := self
		take: aCategory
		quantityUpTo: aFoodQuantity
		withMoneyUpTo: aMoneyAmount.
	
	quantity := batches sum: #quantity.
	price := quantity * (self pricePerUnitFor: aCategory).
	
	aHousehold buyFoodBatches: batches for: price.
	^ quantity
]

{ #category : 'control' }
FEBOutlet >> step [

	self restock.
	inventory becomeOneDayOlder
]

{ #category : 'as yet unclassified' }
FEBOutlet >> take: aCategory quantity: aNumber [

	| batches remainingQuantity sortedBatches sourceBatch soldBatch |
	
	batches := OrderedCollection new.
	remainingQuantity := aNumber.
	
	"We sell fresh food first"
	sortedBatches := (inventory batchesOfCategory: aCategory)
		sorted: [ :a :b | a remainingDays > b remainingDays ].
	
	[ remainingQuantity > 0 and: [ sortedBatches isNotEmpty ] ] whileTrue: [ 
		sourceBatch := sortedBatches first.
		soldBatch := sourceBatch extractQuantity: (remainingQuantity min: sourceBatch quantity).
		
		batches add: soldBatch.
		remainingQuantity := remainingQuantity - soldBatch quantity.
		
		sourceBatch isEmpty ifTrue: [ 
			inventory removeBatch: sourceBatch.
			sortedBatches removeFirst ] ].
	
	^ batches 
]

{ #category : 'as yet unclassified' }
FEBOutlet >> take: category quantityUpTo: requestedAmount withMoneyUpTo: availableMoney [

	| amount availableAmount affordableAmount pricePerUnit |
	
	availableAmount := inventory quantityInCategory: category.
	pricePerUnit := self pricePerUnitFor: category.
	
	amount := requestedAmount min: availableAmount.
	
	affordableAmount := (availableMoney / pricePerUnit) asInteger.
	amount := amount min: affordableAmount.
	
	^ self take: category quantity: amount
]
