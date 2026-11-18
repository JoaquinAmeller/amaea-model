Class {
	#name : 'FEBOutlet',
	#superclass : 'CMAgent',
	#instVars : [
		'inventory',
		'conventionalFoodInventory',
		'healthyFoodInventory',
		'prices',
		'history'
	],
	#classInstVars : [
		'restockAmount'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBOutlet class >> restockAmount [
	<parameterIntegerMin: 10 max: 10000 step: 10 default: 200>
	^ restockAmount
]

{ #category : 'accessing' }
FEBOutlet class >> restockAmount: anObject [

	restockAmount := anObject
]

{ #category : 'aspects' }
FEBOutlet >> aspectDefault: look [

	<aspect>
	look
		image: 'outlet';
		shape: #square;
		size: 0.8
]

{ #category : 'history' }
FEBOutlet >> history [

	^ history
]

{ #category : 'initialization' }
FEBOutlet >> initialize [

	super initialize.

	self initializePrices.

	history := FEBHistory new.
	inventory := FEBFoodInventory new.
	self restock
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
FEBOutlet >> pricePerUnitFor: aCategory [

	^ prices at: aCategory 
]

{ #category : 'as yet unclassified' }
FEBOutlet >> restock [

	| categories category batch |
	"The model's categories, in their fixed order, so that a random seed always picks the same ones"
	categories := cormasModel foodCategories.

	self flag: 'TODO'.

	10 timesRepeat: [ "Choose random category.
		Get random quantity of food of that category.
		Assume infinite fridge capacity"
			category := self selectRandomlyFrom: categories.

			batch := FEBFoodBatch
				         category: category
				         quantity: self restockAmount / 10
				         fridge: category shouldBeStoredInFridge.

			self today addRestock: batch.
			inventory addBatch: batch ]
]

{ #category : 'accessing' }
FEBOutlet >> restockAmount [
	"The class side method is a parameter defining a constant number. This method can be changed later to introduce some fancy restock logic"
	^ self class restockAmount
]

{ #category : 'accessing' }
FEBOutlet >> sellCategory: aCategory quantityUpTo: aFoodQuantity withMoneyUpTo: aMoneyAmount to: aHousehold [
	"Sell what can be sold and paid for. The sale is recorded, as one purchase, in today's records of the outlet and of the household. Answer the quantity sold."

	| batches quantity purchase |
	batches := self
		           take: aCategory
		           quantityUpTo: aFoodQuantity
		           withMoneyUpTo: aMoneyAmount.

	quantity := batches sum: [ :each | each quantity ] ifEmpty: [ 0 ].
	quantity = 0 ifTrue: [ ^ 0 ].

	purchase := FEBPurchase
		            household: aHousehold
		            outlet: self
		            category: aCategory
		            quantity: quantity
		            price: quantity * (self pricePerUnitFor: aCategory).
	aHousehold receive: batches for: purchase.
	self today addSale: purchase.
	^ quantity
]

{ #category : 'control' }
FEBOutlet >> step [

	inventory emptyTheTrashbin.
	self restock.
	inventory becomeOneDayOlder.
	self today recordEndOfDayOf: inventory
]

{ #category : 'as yet unclassified' }
FEBOutlet >> take: aCategory quantity: aNumber [

	| batches remainingQuantity sortedBatches sourceBatch soldBatch |
	batches := OrderedCollection new.
	remainingQuantity := aNumber.

	"We sell fresh food first, and never food in its last day"
	sortedBatches := (inventory batchesLeftTomorrowOfCategory: aCategory)
		                 sorted: [ :a :b |
		                 a remainingDays > b remainingDays ].

	[ remainingQuantity > 0 and: [ sortedBatches isNotEmpty ] ]
		whileTrue: [
				sourceBatch := sortedBatches first.
				soldBatch := sourceBatch extractQuantity:
					             (remainingQuantity min: sourceBatch quantity).

				batches add: soldBatch.
				remainingQuantity := remainingQuantity - soldBatch quantity.

				sourceBatch isEmpty ifTrue: [
						inventory removeBatch: sourceBatch.
						sortedBatches removeFirst ] ].

	^ batches
]

{ #category : 'as yet unclassified' }
FEBOutlet >> take: category quantityUpTo: requestedAmount withMoneyUpTo: availableMoney [
	"Households buy for the next day, so only food that will still be good tomorrow is for sale"

	| amount availableAmount affordableAmount pricePerUnit |
	availableAmount := inventory quantityLeftTomorrowInCategory: category.
	pricePerUnit := self pricePerUnitFor: category.

	amount := requestedAmount min: availableAmount.

	affordableAmount := (availableMoney / pricePerUnit) asInteger.
	amount := amount min: affordableAmount.

	^ self take: category quantity: amount
]

{ #category : 'history' }
FEBOutlet >> today [
	"Answer the record of the current time step, where everything the outlet does now is recorded"

	^ history
		  dayAt: self currentTimeStep
		  ifAbsentPut: [ FEBOutletDay step: self currentTimeStep ]
]
