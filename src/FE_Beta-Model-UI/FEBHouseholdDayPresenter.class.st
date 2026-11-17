"
I show one day of a household's history: its meals, its indicators, its purchases, the food that spoiled and its stock at the end of the day.

## Responsibility:

- List, for each category, the household's preference and what it ate, as meals and as a share of the daily need, with the difference, and colour in red the categories it ate less of than it prefers.
- List the day's indicators with their score and level, coloured like the model's perspectives.
- List the purchases with the money and time spent, the spoiled food, and the stock with the fridge's use.

Double-clicking a purchase, or choosing it in its context menu, opens its outlet's dashboard on the same step. In the inspector only the menu works (backlog entry 14).

## Collaborators:

- `FEBHousehold`: computes shares, indicators, levels and colours for any of its days.
- `FEBHouseholdDay`: the day I show.
- `FEBIndicatorReading`: each row of my indicators table.
- `FEBDayPresenter`: my superclass, laying out titled sections.
- `FEBHouseholdDashboard`: creates me and tells me which day to show.

## Public API and Key Messages

- `FEBHouseholdDayPresenter on: aHousehold` creates me; `showDay:` shows one of its days.
- `day`, and my tables: `mealsTable`, `indicatorsTable`, `purchasesTable`, `spoiledTable`, `stockTable`.
- `preferenceTextOf:`, `eatenTextOf:`, `differenceTextOf:` and `colorOfPreferenceOf:` give what the meals table shows for a category, for example `3 (30%)`, `0 (0%)`, `-30%` and red.

```smalltalk
| presenter |
presenter := FEBHouseholdDayPresenter on: aHousehold.
presenter showDay: aHousehold history lastDay.
presenter open
```

## Internal Representation

- `household`: the `FEBHousehold`, set before my presenters are created; `day`: the `FEBHouseholdDay` shown, nil until `showDay:`.
"
Class {
	#name : 'FEBHouseholdDayPresenter',
	#superclass : 'FEBDayPresenter',
	#instVars : [
		'household',
		'day',
		'mealsTable',
		'mealsTotalLabel',
		'indicatorsTable',
		'purchasesTable',
		'shoppingLabel',
		'spoiledTable',
		'stockTable',
		'fridgeLabel'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'private' }
FEBHouseholdDayPresenter >> categoriesOfTheDay [
	"The preferred categories, most preferred first, then any other category eaten that day"

	| categories |
	categories := household foodPreferenceProportions keys
		              asOrderedCollection.
	day meals do: [ :each |
			(categories includes: each category) ifFalse: [
				categories add: each category ] ].
	^ categories asArray
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> colorOfPreferenceOf: aCategory [
	"Answer the colour of a category the household ate less of than it prefers that day, or nil to keep the usual colour"

	(household isPreferenceFor: aCategory fulfilledOn: day) ifTrue: [
		^ nil ].
	^ household colorOfLevel: #hungry
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> connectPresenters [
	"Double-clicking a purchase, or choosing it in its menu, opens its outlet's dashboard on the same step. The menu also works in the inspector, where double-clicks are lost (backlog entry 14)"

	purchasesTable
		whenActivatedDo: [ :selection |
			self openOutletDashboardOf: selection selectedItem ];
		contextMenu: [ self purchaseMenu ]
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> day [

	^ day
]

{ #category : 'layout' }
FEBHouseholdDayPresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 10;
		  add: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: (self title: 'Meals' with: mealsTotalLabel) expand: false;
				   add: mealsTable;
				   add: 'Indicators' expand: false;
				   add: indicatorsTable;
				   yourself);
		  add: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: (self title: 'Purchases' with: shoppingLabel)
				   expand: false;
				   add: purchasesTable;
				   add: 'Spoiled food' expand: false;
				   add: spoiledTable;
				   add:
					   (self title: 'Stock at the end of the day' with: fridgeLabel)
				   expand: false;
				   add: stockTable;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> differenceTextOf: aCategory [
	"The share eaten less the preference, with its sign: +30%, -30%, or nothing when they are equal"

	| difference |
	difference := household preferenceDifferenceOf: aCategory on: day.
	difference = 0 ifTrue: [ ^ '' ].
	^ (difference > 0
		   ifTrue: [ '+' ]
		   ifFalse: [ '' ]) , (self percentTextOf: difference)
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> eatenTextOf: aCategory [
	"The meals eaten of the category, and their share of the daily need: 8 (80%)"

	| meals |
	meals := day numberOfMealsOf: aCategory.
	^ '{1} ({2})' format: {
			  meals.
			  (self percentTextOf: meals / household dailyNeed) }
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> fridgeText [
	"How much of the fridge the stock fills at the end of the day: Fridge: 6 of 6 meals (100% full)"

	| inFridge capacity |
	inFridge := day stock sum: [ :each | each inFridge ] ifEmpty: [ 0 ].
	capacity := household inventory fridgeCapacity.
	capacity = 0 ifTrue: [ ^ 'No fridge' ].
	^ 'Fridge: {1} of {2} meals ({3} full)' format: {
			  inFridge.
			  capacity.
			  (self percentTextOf: inFridge / capacity) }
]

{ #category : 'private' }
FEBHouseholdDayPresenter >> indicatorReadings [

	| healthy |
	healthy := household isHavingHealthyDietOn: day.
	^ {
		  (self
			   reading: 'Satiety'
			   score: (household satietyScoreOn: day)
			   level: (household satietyLevelOn: day)).
		  (self
			   reading: 'Caloric adequacy'
			   score: (household caloricAdequacyScoreOn: day)
			   level: (household caloricAdequacyLevelOn: day)).
		  (self
			   reading: 'Protein adequacy'
			   score: (household proteinAdequacyScoreOn: day)
			   level: (household proteinAdequacyLevelOn: day)).
		  (FEBIndicatorReading
			   name: 'Healthy diet (last 7 days)'
			   score: nil
			   level: (healthy
					    ifTrue: [ #healthy ]
					    ifFalse: [ #notHealthy ])
			   color: (household colorOfLevel: (healthy
						     ifTrue: [ #full ]
						     ifFalse: [ #hungry ]))) }
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> indicatorsTable [

	^ indicatorsTable
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> initializeIndicatorsTable [

	indicatorsTable := self newTable.
	indicatorsTable
		addColumn: (SpStringTableColumn
				 title: 'Indicator'
				 evaluated: [ :reading | reading name ]);
		addColumn: (SpStringTableColumn
				 title: 'Score'
				 evaluated: [ :reading | reading scoreText ]);
		addColumn: ((SpStringTableColumn
				  title: 'Level'
				  evaluated: [ :reading | reading levelText ])
				 displayColor: [ :reading | reading color ];
				 yourself)
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> initializeMealsTable [

	| colored |
	colored := [ :title :block |
		           (SpStringTableColumn title: title evaluated: block)
			           displayColor: [ :category |
				           self colorOfPreferenceOf: category ];
			           yourself ].
	mealsTable := self newTable.
	mealsTable
		addColumn:
			(colored value: 'Food' value: [ :category | category name ]);
		addColumn: (colored
				 value: 'Preference'
				 value: [ :category | self preferenceTextOf: category ]);
		addColumn: (colored
				 value: 'Eaten'
				 value: [ :category | self eatenTextOf: category ]);
		addColumn: (colored
				 value: 'Difference'
				 value: [ :category | self differenceTextOf: category ]);
		addColumn: (colored
				 value: 'Substitutes'
				 value: [ :category |
					 (day numberOfSubstitutesOf: category) printString ])
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> initializePresenters [

	self initializeMealsTable.
	self initializeIndicatorsTable.
	self initializePurchasesTable.
	self initializeSpoiledTable.
	self initializeStockTable.
	mealsTotalLabel := self newLabel.
	shoppingLabel := self newLabel.
	fridgeLabel := self newLabel
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> initializePurchasesTable [

	purchasesTable := self newTable.
	purchasesTable
		addColumn: (SpStringTableColumn
				 title: 'Outlet'
				 evaluated: [ :purchase |
					 'Outlet ' , purchase outlet id printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Food'
				 evaluated: [ :purchase | purchase category name ]);
		addColumn: (SpStringTableColumn
				 title: 'Quantity'
				 evaluated: [ :purchase | purchase quantity printString ]);
		addColumn: (SpStringTableColumn
				 title: 'In fridge'
				 evaluated: [ :purchase | purchase quantityInFridge printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Price'
				 evaluated: [ :purchase | purchase price printString ])
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> initializeSpoiledTable [

	spoiledTable := self newTable.
	spoiledTable
		addColumn: (SpStringTableColumn
				 title: 'Food'
				 evaluated: [ :category | category name ]);
		addColumn: (SpStringTableColumn
				 title: 'Spoiled'
				 evaluated: [ :category |
					 (day spoiledFood occurrencesOf: category) printString ])
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> initializeStockTable [

	stockTable := self newTable.
	stockTable
		addColumn: (SpStringTableColumn
				 title: 'Food'
				 evaluated: [ :level | level category name ]);
		addColumn: (SpStringTableColumn
				 title: 'In fridge'
				 evaluated: [ :level | level inFridge printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Outside'
				 evaluated: [ :level | level outsideFridge printString ]);
		addColumn: (SpStringTableColumn
				 title: 'In last day'
				 evaluated: [ :level | level inLastDay printString ])
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> mealsEatenOf: aCategory [

	^ day numberOfMealsOf: aCategory
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> mealsTable [

	^ mealsTable
]

{ #category : 'opening' }
FEBHouseholdDayPresenter >> openOutletDashboardOf: aPurchase [

	^ FEBOutletDashboard openOn: aPurchase outlet atStep: day step
]

{ #category : 'private' }
FEBHouseholdDayPresenter >> percentTextOf: aFraction [
	"A fraction as a percentage, whole when it is, else to one decimal: 3/10 is 30%, 1/30 is 3.3%"

	| percent |
	percent := aFraction * 100.
	^ (percent isInteger
		   ifTrue: [ percent printString ]
		   ifFalse: [ percent asFloat printShowingDecimalPlaces: 1 ]) , '%'
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> preferenceTextOf: aCategory [
	"The meals of the category's share of the daily need, and the preference: 3 (30%)"

	^ '{1} ({2})' format: {
			  ((household mealsPerCategoryFor: household dailyNeed)
				   at: aCategory
				   ifAbsent: [ 0 ]).
			  (self percentTextOf: (household preferenceOf: aCategory)) }
]

{ #category : 'menus' }
FEBHouseholdDayPresenter >> purchaseMenu [
	"A menu opening the dashboard of the selected purchase's outlet, empty when no purchase is selected"

	| menu purchase |
	menu := self newMenu.
	purchase := purchasesTable selectedItem ifNil: [ ^ menu ].
	menu addItem: [ :item |
			item
				name:
					'Open the dashboard of Outlet ' , purchase outlet id printString;
				action: [ self openOutletDashboardOf: purchase ] ].
	^ menu
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> purchasesTable [

	^ purchasesTable
]

{ #category : 'private' }
FEBHouseholdDayPresenter >> reading: aName score: aScore level: aLevel [

	^ FEBIndicatorReading
		  name: aName
		  score: aScore
		  level: aLevel
		  color: (household colorOfLevel: aLevel)
]

{ #category : 'initialization' }
FEBHouseholdDayPresenter >> setModelBeforeInitialization: aHousehold [

	household := aHousehold
]

{ #category : 'private' }
FEBHouseholdDayPresenter >> shoppingText [

	day wentShopping ifFalse: [ ^ 'Did not go shopping' ].
	^ 'Spent {1} of {2}, walked {3} of {4} minutes' format: {
			  day moneySpent.
			  day moneyAvailable.
			  day timeSpent asMinutes rounded.
			  day timeAvailable asMinutes rounded }
]

{ #category : 'updating' }
FEBHouseholdDayPresenter >> showDay: aDay [

	day := aDay.
	mealsTable items: self categoriesOfTheDay.
	mealsTotalLabel label: ('Total: {1} of {2} meals' format: {
				 day meals size.
				 household dailyNeed }).
	indicatorsTable items: self indicatorReadings.
	purchasesTable items: day purchases asArray.
	shoppingLabel label: self shoppingText.
	spoiledTable items: day spoiledFood asSet asArray.
	stockTable items: day stock asArray.
	fridgeLabel label: self fridgeText
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> spoiledTable [

	^ spoiledTable
]

{ #category : 'accessing' }
FEBHouseholdDayPresenter >> stockTable [

	^ stockTable
]
