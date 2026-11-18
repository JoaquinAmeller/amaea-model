Class {
	#name : 'FEBSimpleShoppingStrategy',
	#superclass : 'FEBShoppingStrategy',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBSimpleShoppingStrategy >> buy: aQuantity of: aCategory from: anOutlet for: aHousehold using: aShoppingList withMoneyUpTo: aMoneyAmount [

	| quantityBought |
		
	quantityBought := anOutlet
		sellCategory: aCategory
		quantityUpTo: aQuantity
		withMoneyUpTo: aMoneyAmount
		to: aHousehold.
		
	quantityBought > 0 ifTrue: [ 
		aShoppingList
			decreaseNeedOf: aCategory
			by: quantityBought ].
]

{ #category : 'accessing' }
FEBSimpleShoppingStrategy >> buyAt: anOutlet for: aHousehold using: aShoppingList [

	self buyEssentialAt: anOutlet for: aHousehold using: aShoppingList.
	self buyForStorageAt: anOutlet for: aHousehold using: aShoppingList 
]

{ #category : 'accessing' }
FEBSimpleShoppingStrategy >> buyEssentialAt: anOutlet for: aHousehold using: aShoppingList [
	
	aShoppingList essentialNeeds copy keysAndValuesDo: [ :category :quantity |
		self
			buy: quantity
			of: category
			from: anOutlet
			for: aHousehold
			using: aShoppingList
			withMoneyUpTo: aHousehold remainingMoney ].
]

{ #category : 'accessing' }
FEBSimpleShoppingStrategy >> buyForStorageAt: anOutlet for: aHousehold using: aShoppingList [

	| availableMoney |
	
	availableMoney := aHousehold availableMoneyForStorage.
	availableMoney <= 0 ifTrue: [ ^ self ].
	
	aShoppingList storageNeeds  copy keysAndValuesDo: [ :category :quantity |
		self
			buy: quantity
			of: category
			from: anOutlet
			for: aHousehold
			using: aShoppingList
			withMoneyUpTo: availableMoney.
			
		availableMoney := aHousehold availableMoneyForStorage.
		availableMoney <= 0 ifTrue: [ ^ self ] ].
]

{ #category : 'testing' }
FEBSimpleShoppingStrategy >> can: aHousehold travelFor: aTime with: aShoppingList [

	| remainingTime |
	remainingTime := aHousehold remainingTime.

	aShoppingList hasEssentialNeeds ifFalse: [
		"Don't use too much time if the essential needs are already fulfilled"
		remainingTime := remainingTime - (aHousehold availableTimePerStep * aHousehold timeThreshold) ].
	
	^ aTime <= remainingTime 
]

{ #category : 'shopping' }
FEBSimpleShoppingStrategy >> shopFor: aHousehold using: aShoppingList [
	"Walk from home to the closest outlet not visited yet, again and again, while there is something to buy and time to get there. Each walk is a leg of the trip, from home or the previous outlet to the next one"

	| outlet currentCell previousStop timeToTravel unvisitedOutlets |
	unvisitedOutlets := aHousehold outlets copy.
	currentCell := aHousehold cell.
	previousStop := aHousehold.

	[ unvisitedOutlets isNotEmpty and: [ aShoppingList hasAnyNeeds ] ]
		whileTrue: [
				outlet := self
					          unvisitedOutletClosestTo: currentCell
					          from: unvisitedOutlets.
				timeToTravel := currentCell timeToTravelTo: outlet cell.

				(self can: aHousehold travelFor: timeToTravel with: aShoppingList)
					ifFalse: [ ^ self ].

				aHousehold trip add: (aHousehold cormasModel
						 newEntity: FEBTripLeg
						 from: previousStop
						 to: outlet).
				previousStop := outlet.
				currentCell := outlet cell.
				unvisitedOutlets remove: outlet.
				aHousehold remainingTime: aHousehold remainingTime - timeToTravel.

				self buyAt: outlet for: aHousehold using: aShoppingList ]
]
