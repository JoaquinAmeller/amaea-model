"
I test the shopping trips of a `FEBHousehold`, and its days of eating and shopping next to an outlet: whether it goes shopping, where, what it can afford, and whether it then eats as it should.

## Responsibility:

- Check that a household shops when it lacks its preferred food for the day, buys exactly what it needs, today's food first, and never more than it can pay.
- Check how it chooses outlets: closest first, on to the next when one runs out, never further than its time allows, with less time spent when it only stocks up.
- Check that living next to a well-stocked outlet keeps it full, eating its preferred share of each food.

## Collaborators:

- `FEBModel`: gives the 30 by 30 grid, the food categories and the substitution list.
- `FEBOutlet`: the outlets the household knows, stocked with known food.
- `FEBHousehold`: the shopper, a person needing 10 meals a day, at the corner cell.

## Public API and Key Messages

- `outletAt:at:stocking:of:` puts an outlet on the grid with only that food, and tells the household about it.
- `give:of:` puts food in the household's inventory, and `giveMoney:` sets its money per day.
- `livePreferringStaplesFruitsAndProteinsFor:nextTo:` lives several days next to an outlet restocked every morning.

```smalltalk
FEBShoppingTripTest run: #testShopsAtTheClosestOutletFirst
```

## Internal Representation

- An outlet's inventory has no accessor, so `inventoryOf:` reads it with `instVarNamed:`.
"
Class {
	#name : 'FEBShoppingTripTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'household',
		'stapleFood',
		'animalProteins',
		'processedFood'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBShoppingTripTest >> foodBoughtToStockUpBy: aStrategySelector [
	"Answer how much food a household with today's food, 100 to spend and an outlet next door buys with that strategy"

	household perform: aStrategySelector.
	household outlets removeAll.
	household inventory batches removeAll.
	self giveMoney: 100.
	self give: 10 of: stapleFood.
	self
		outletAt: 1
		at: 3
		stocking: 1000
		of: stapleFood.
	household goShopping.
	^ household inventory totalQuantity - 10
]

{ #category : 'helpers' }
FEBShoppingTripTest >> give: aQuantity of: aCategory [

	household inventory addBatch:
		(FEBFoodBatch category: aCategory quantity: aQuantity fridge: false)
]

{ #category : 'helpers' }
FEBShoppingTripTest >> giveMoney: anAmount [

	household instVarNamed: #availableMoneyPerStep put: anAmount
]

{ #category : 'helpers' }
FEBShoppingTripTest >> inventoryOf: anOutlet [

	^ anOutlet instVarNamed: #inventory
]

{ #category : 'helpers' }
FEBShoppingTripTest >> livePreferringStaplesFruitsAndProteinsFor: aNumberOfDays nextTo: anOutlet [
	"Live aNumberOfDays, one time step each: each morning the outlet has plenty of every preferred food, and the household eats, shops and its food ages. Answer the food categories eaten each day."

	| fruitsAndVegetables |
	fruitsAndVegetables := model foodCategoryNamed:
		                       'Fruits and vegetables'.
	household foodPreferenceProportions: {
			(stapleFood -> 0.5).
			(fruitsAndVegetables -> 0.3).
			(animalProteins -> 0.2) } asDictionary.
	household inventory batches removeAll.
	1 to: aNumberOfDays do: [ :day |
			model simulationContext currentTimeStep: day.
			(self inventoryOf: anOutlet) batches removeAll.
			{
				stapleFood.
				fruitsAndVegetables.
				animalProteins } do: [ :each |
					(self inventoryOf: anOutlet) addBatch: (FEBFoodBatch
							 category: each
							 quantity: 100
							 fridge: each shouldBeStoredInFridge) ].
			household step ].
	^ household history days collect: [ :each |
		  each meals collect: [ :meal | meal category ] ]
]

{ #category : 'helpers' }
FEBShoppingTripTest >> neighbourAt: aRow at: aColumn [
	"Another person like the household, with no food, knowing the same outlets"

	| neighbour |
	neighbour := model
		             newEntity: FEBHousehold
		             locatedAt: (model cellAt: aRow at: aColumn).
	neighbour instVarNamed: #householdSize put: 1.
	neighbour instVarNamed: #dailyNeed put: 10.
	neighbour instVarNamed: #availableMoneyPerStep put: 1000.
	neighbour foodPreferenceProportions:
		{ (stapleFood -> 1.0) } asDictionary.
	neighbour substitutionList:
		(household instVarNamed: #substitutionList).
	neighbour inventory batches removeAll.
	neighbour outlets: household outlets.
	^ neighbour
]

{ #category : 'helpers' }
FEBShoppingTripTest >> outletAt: aRow at: aColumn stocking: aQuantity of: aCategory [

	| outlet |
	outlet := model
		          newEntity: FEBOutlet
		          locatedAt: (model cellAt: aRow at: aColumn).
	(self inventoryOf: outlet) batches removeAll.
	(self inventoryOf: outlet) addBatch: (FEBFoodBatch
			 category: aCategory
			 quantity: aQuantity
			 fridge: aCategory shouldBeStoredInFridge).
	household outlets add: outlet.
	^ outlet
]

{ #category : 'running' }
FEBShoppingTripTest >> setUp [
	"A person needing 10 meals a day, preferring only staple food, at the corner of a 30 by 30 grid, with no food and no outlet yet"

	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	model
		createGridNumberOfRows: 30
		numberOfColumns: 30
		neighbourhood: 8
		closed: true.
	stapleFood := model foodCategoryNamed: 'Staple food'.
	animalProteins := model foodCategoryNamed: 'Animal proteins'.
	processedFood := model foodCategoryNamed: 'Processed food'.

	household := model
		             newEntity: FEBHousehold
		             locatedAt: (model cellAt: 1 at: 1).
	household instVarNamed: #householdSize put: 1.
	household instVarNamed: #dailyNeed put: 10.
	household foodPreferenceProportions:
		{ (stapleFood -> 1.0) } asDictionary.
	model initializeSubstitutionList.
	household inventory batches removeAll.
	household outlets: OrderedCollection new
]

{ #category : 'tests' }
FEBShoppingTripTest >> testADesperateSaverSpendsLessMoneyOnStorageThanARichBastard [

	self assert: (self foodBoughtToStockUpBy: #beDesperateSaver)
		< (self foodBoughtToStockUpBy: #beRichBastard)
]

{ #category : 'tests' }
FEBShoppingTripTest >> testADesperateSaverSpendsLessTimeStockingUpThanARichBastard [
	"With the 2 hours a household has, an outlet 60 minutes away is within reach of a household keeping back little of its time, and out of reach of one keeping back a lot"

	self assert: (self walksAnHourToStockUpWith: #beRichBastard).
	self deny: (self walksAnHourToStockUpWith: #beDesperateSaver)
]

{ #category : 'tests' }
FEBShoppingTripTest >> testAHouseholdGoesElsewhereWhenANeighbourEmptiedTheClosestOutlet [

	| neighbour |
	self giveMoney: 1000.
	self
		outletAt: 1
		at: 3
		stocking: 60
		of: stapleFood.
	self
		outletAt: 1
		at: 6
		stocking: 100
		of: stapleFood.
	neighbour := self neighbourAt: 2 at: 1.

	household goShopping.
	neighbour goShopping.

	self assert: household inventory totalQuantity equals: 60.
	self assert: neighbour inventory totalQuantity equals: 60
]

{ #category : 'tests' }
FEBShoppingTripTest >> testAMoneySaverSpendsLessMoneyOnStorageThanATimeSaver [

	self assert: (self foodBoughtToStockUpBy: #beMoneySaver)
		< (self foodBoughtToStockUpBy: #beTimeSaver)
]

{ #category : 'tests' }
FEBShoppingTripTest >> testATimeSaverSpendsLessTimeStockingUpThanAMoneySaver [
	"With the 2 hours a household has, an outlet 60 minutes away is within reach of a household keeping back little of its time, and out of reach of one keeping back a lot"

	self assert: (self walksAnHourToStockUpWith: #beMoneySaver).
	self deny: (self walksAnHourToStockUpWith: #beTimeSaver)
]

{ #category : 'tests' }
FEBShoppingTripTest >> testBuysExactlyWhatItNeedsWhenItCanAffordIt [
	"10 meals for today and 5 days of storage"

	self giveMoney: 1000.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 60
]

{ #category : 'tests' }
FEBShoppingTripTest >> testBuysFoodForTodayBeforeFoodForStorage [
	"60 pays for today's 10 meals and leaves 10, less than the reserve of a money saver"

	self giveMoney: 60.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 10.
	self assert: household remainingMoney equals: 10
]

{ #category : 'tests' }
FEBShoppingTripTest >> testDoesNotGoFurtherThanItsTimeAllows [
	"The outlet is 29 cells away, 145 minutes of walking, and the household has 2 hours"

	self
		outletAt: 30
		at: 30
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 0
]

{ #category : 'tests' }
FEBShoppingTripTest >> testDoesNotPayForFoodThatWillSpoilBeforeItCanBeEaten [
	"Households shop after eating, for the next day. The outlet only has staple food in its last day, which will be spoiled tomorrow."

	| outlet |
	self giveMoney: 100.
	outlet := self
		          outletAt: 1
		          at: 3
		          stocking: 1
		          of: stapleFood.
	(self inventoryOf: outlet) batches removeAll.
	(self inventoryOf: outlet) addBatch: (FEBFoodBatch
			 category: stapleFood
			 quantity: 100
			 fridge: false
			 remainingDays: 1).

	household goShopping.

	self assert: household inventory totalQuantity equals: 0.
	self assert: household remainingMoney equals: 100
]

{ #category : 'tests' }
FEBShoppingTripTest >> testFoodBoughtByOneHouseholdIsGoneForTheNext [

	| neighbour outlet |
	self giveMoney: 1000.
	outlet := self
		          outletAt: 1
		          at: 3
		          stocking: 15
		          of: stapleFood.
	neighbour := self neighbourAt: 3 at: 1.

	household goShopping.
	neighbour goShopping.

	self assert: household inventory totalQuantity equals: 15.
	self assert: neighbour inventory totalQuantity equals: 0.
	self assert: (self inventoryOf: outlet) totalQuantity equals: 0
]

{ #category : 'tests' }
FEBShoppingTripTest >> testFoodThatDoesNotFitInTheFridgeIsKeptOutside [
	"It buys 10 meals of animal proteins for today and 6 for storage, and its fridge holds 6"

	| inventory |
	household foodPreferenceProportions:
		{ (animalProteins -> 1.0) } asDictionary.
	household inventory batches removeAll.
	self giveMoney: 1000.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: animalProteins.

	household goShopping.

	inventory := household inventory.
	self
		assert: (inventory quantityInCategory: animalProteins)
		equals: 16.
	self assert: inventory quantityInFridge equals: 6
]

{ #category : 'tests' }
FEBShoppingTripTest >> testGoesOnToTheNextOutletWhenTheClosestRunsOut [

	| near next |
	self giveMoney: 1000.
	near := self
		        outletAt: 1
		        at: 3
		        stocking: 4
		        of: stapleFood.
	next := self
		        outletAt: 1
		        at: 5
		        stocking: 100
		        of: stapleFood.

	household goShopping.

	self assert: (self inventoryOf: near) totalQuantity equals: 0.
	self assert: (self inventoryOf: next) totalQuantity equals: 44.
	self assert: household inventory totalQuantity equals: 60
]

{ #category : 'tests' }
FEBShoppingTripTest >> testGoesShoppingWhenItHasNoFood [

	self assert: household shouldGoShopping
]

{ #category : 'tests' }
FEBShoppingTripTest >> testGoesShoppingWhenItLacksItsPreferredFood [

	self give: 10 of: processedFood.

	self assert: household shouldGoShopping
]

{ #category : 'tests' }
FEBShoppingTripTest >> testKeepsAMoneyReserveWhenBuyingForStorage [
	"It has today's food, so it only buys for storage, and keeps the share of its 100 that its strategy holds back"

	self giveMoney: 100.
	self give: 10 of: stapleFood.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity > 10.
	self assert:
		household remainingMoney >= (100 * household moneyThreshold)
]

{ #category : 'tests' }
FEBShoppingTripTest >> testNeverSpendsMoreThanItHas [

	self giveMoney: 23.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.
	self
		outletAt: 2
		at: 4
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household remainingMoney >= 0.
	self assert: household inventory totalQuantity * 5 <= 23
]

{ #category : 'tests' }
FEBShoppingTripTest >> testNextToAWellStockedOutletAHouseholdEatsItsPreferredShareOfEachFoodEveryDay [
	"With all the money it needs, and the strategy that keeps to the preferences rather than eating food in its last day first"

	| days fruitsAndVegetables previousStrategy |
	fruitsAndVegetables := model foodCategoryNamed:
		                       'Fruits and vegetables'.
	previousStrategy := FEBHousehold consumptionStrategySymbol.
	FEBHousehold consumptionStrategySymbol: #'Some fuck about spoil'.
	[
		self giveMoney: 1000.
		days := self
			        livePreferringStaplesFruitsAndProteinsFor: 10
			        nextTo: (self
					         outletAt: 1
					         at: 3
					         stocking: 1
					         of: stapleFood) ] ensure: [
		FEBHousehold consumptionStrategySymbol: previousStrategy ].

	days allButFirst doWithIndex: [ :meals :day |
			self
				assert: {
						(meals count: [ :each | each = stapleFood ]).
						(meals count: [ :each | each = fruitsAndVegetables ]).
						(meals count: [ :each | each = animalProteins ]) }
				equals: #( 5 3 2 ) ]
]

{ #category : 'tests' }
FEBShoppingTripTest >> testNextToAWellStockedOutletAHouseholdIsFullEveryDayAfterTheFirst [
	"It starts with no food, so the first day it cannot eat"

	| days |
	self giveMoney: 100.
	days := self
		        livePreferringStaplesFruitsAndProteinsFor: 10
		        nextTo: (self
				         outletAt: 1
				         at: 3
				         stocking: 1
				         of: stapleFood).

	self assert: days first isEmpty.
	(days allButFirst collect: [ :each | each size ]) do: [ :meals |
		self assert: meals equals: 10 ]
]

{ #category : 'tests' }
FEBShoppingTripTest >> testShoppingNeverOverfillsTheFridge [
	"Animal proteins keep only 2 days outside, so they go in the fridge, which holds 6 meals"

	household foodPreferenceProportions:
		{ (animalProteins -> 1.0) } asDictionary.
	household inventory batches removeAll.
	self giveMoney: 1000.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: animalProteins.

	household goShopping.

	self assert: household inventory quantityInFridge
		<= household inventory fridgeCapacity
]

{ #category : 'tests' }
FEBShoppingTripTest >> testShopsAtTheClosestOutletFirst [

	| near far |
	far := self
		       outletAt: 5
		       at: 5
		       stocking: 100
		       of: stapleFood.
	near := self
		        outletAt: 1
		        at: 3
		        stocking: 100
		        of: stapleFood.

	household goShopping.

	self assert: (self inventoryOf: near) totalQuantity < 100.
	self assert: (self inventoryOf: far) totalQuantity equals: 100
]

{ #category : 'tests' }
FEBShoppingTripTest >> testSpendsAllItsMoneyOnFoodForTheDayIfNeeded [
	"30 pays for 6 of the 10 meals it needs today, at 5 each"

	self giveMoney: 30.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 6.
	self assert: household remainingMoney equals: 0
]

{ #category : 'tests' }
FEBShoppingTripTest >> testStaysHomeWhenItHasItsPreferredFoodForTheDay [

	self give: 10 of: stapleFood.

	self deny: household shouldGoShopping
]

{ #category : 'tests' }
FEBShoppingTripTest >> testStopsShoppingOnceItHasEverythingItNeeds [

	| far |
	self giveMoney: 1000.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.
	far := self
		       outletAt: 1
		       at: 6
		       stocking: 100
		       of: stapleFood.

	household goShopping.

	self assert: (self inventoryOf: far) totalQuantity equals: 100
]

{ #category : 'tests' }
FEBShoppingTripTest >> testUnspentMoneyIsNotSavedForTheNextDay [
	"With no outlet in reach, the first day's money is not spent. The next day it still only has one day's money: 100, which pays for 20 meals"

	self giveMoney: 100.
	self
		outletAt: 30
		at: 30
		stocking: 100
		of: stapleFood.
	household goShopping.

	self
		outletAt: 1
		at: 3
		stocking: 100
		of: stapleFood.
	household goShopping.

	self assert: household inventory totalQuantity <= 20
]

{ #category : 'tests' }
FEBShoppingTripTest >> testWalkingTimeAddsUpFromOutletToOutlet [
	"The first outlet is 60 minutes away and has little food. The second is 120 minutes from home, but another 120 from the first outlet, which is more than the 60 minutes left"

	self giveMoney: 1000.
	self
		outletAt: 1
		at: 13
		stocking: 4
		of: stapleFood.
	self
		outletAt: 25
		at: 1
		stocking: 100
		of: stapleFood.

	household goShopping.

	self assert: household inventory totalQuantity equals: 4
]

{ #category : 'tests' }
FEBShoppingTripTest >> testWalksFurtherForFoodForTodayThanForStorage [
	"The outlet is 110 minutes away, within the 2 hours a household has, but further than it walks only to stock up, whatever share of its time its strategy keeps back"

	| outlet |
	self giveMoney: 1000.
	outlet := self
		          outletAt: 1
		          at: 23
		          stocking: 100
		          of: stapleFood.

	self give: 10 of: stapleFood.
	household goShopping.
	self assert: (self inventoryOf: outlet) totalQuantity equals: 100.

	household inventory batches removeAll.
	household goShopping.
	self assert: (self inventoryOf: outlet) totalQuantity < 100
]

{ #category : 'tests' }
FEBShoppingTripTest >> testWhenMoneyIsShortItBuysItsMostPreferredFoodFirst [
	"25 pays for 5 of today's 10 meals: 5 staple food, its most preferred"

	| fruitsAndVegetables |
	fruitsAndVegetables := model foodCategoryNamed:
		                       'Fruits and vegetables'.
	household foodPreferenceProportions: {
			(stapleFood -> 0.5).
			(fruitsAndVegetables -> 0.3).
			(animalProteins -> 0.2) } asDictionary.
	household inventory batches removeAll.
	self giveMoney: 25.
	self
		outletAt: 1
		at: 3
		stocking: 100
		of: animalProteins.
	(self inventoryOf: household outlets first) addBatch: (FEBFoodBatch
			 category: fruitsAndVegetables
			 quantity: 100
			 fridge: false).
	(self inventoryOf: household outlets first) addBatch:
		(FEBFoodBatch category: stapleFood quantity: 100 fridge: false).

	household goShopping.

	self
		assert: (household inventory quantityInCategory: stapleFood)
		equals: 5.
	self assert: household inventory totalQuantity equals: 5
]

{ #category : 'helpers' }
FEBShoppingTripTest >> walksAnHourToStockUpWith: aStrategySelector [
	"Answer whether a household with today's food goes to an outlet 60 minutes away with that strategy"

	| outlet |
	household perform: aStrategySelector.
	household outlets removeAll.
	household inventory batches removeAll.
	self giveMoney: 1000.
	self give: 10 of: stapleFood.
	outlet := self
		          outletAt: 1
		          at: 13
		          stocking: 100
		          of: stapleFood.
	household goShopping.
	^ (self inventoryOf: outlet) totalQuantity < 100
]
