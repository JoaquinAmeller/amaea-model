"
I show one day of an outlet's history: its sales, and for each food category its price, what it restocked, sold and threw away, and what it holds at the end of the day.

## Responsibility:

- List the day's sales, one row per sale, with the revenue and the number of households served on the title line.
- List each food category with its price, restock, sales, spoiled food and stock in and out of the fridge and in its last day.
- Sum the stock, and the part in its last day, on the food table's title line.

## Collaborators:

- `FEBOutlet`: its prices and the model's food categories.
- `FEBOutletDay`: the day I show.
- `FEBDayPresenter`: my superclass, laying out titled sections.
- `FEBOutletDashboard`: creates me and tells me which day to show.

## Public API and Key Messages

- `FEBOutletDayPresenter on: anOutlet` creates me; `showDay:` shows one of its days.
- `day`, `salesTable`, `foodTable`, `salesText`, `soldOf:`, `restockedOf:`, `spoiledOf:`.

```smalltalk
| presenter |
presenter := FEBOutletDayPresenter on: anOutlet.
presenter showDay: anOutlet history lastDay.
presenter open
```

## Internal Representation

- `outlet`: the `FEBOutlet`, set before my presenters are created; `day`: the `FEBOutletDay` shown, nil until `showDay:`.
"
Class {
	#name : 'FEBOutletDayPresenter',
	#superclass : 'FEBDayPresenter',
	#instVars : [
		'outlet',
		'day',
		'salesTable',
		'salesLabel',
		'foodTable',
		'stockLabel'
	],
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'accessing' }
FEBOutletDayPresenter >> day [

	^ day
]

{ #category : 'layout' }
FEBOutletDayPresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 10;
		  add: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: (self title: 'Sales' with: salesLabel) expand: false;
				   add: salesTable;
				   yourself);
		  add: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: (self title: 'Food' with: stockLabel) expand: false;
				   add: foodTable;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> foodTable [

	^ foodTable
]

{ #category : 'initialization' }
FEBOutletDayPresenter >> initializePresenters [

	salesTable := self newTable.
	salesTable
		addColumn: (SpStringTableColumn
				 title: 'Household'
				 evaluated: [ :sale |
					 'Household ' , sale household id printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Food'
				 evaluated: [ :sale | sale category name ]);
		addColumn: (SpStringTableColumn
				 title: 'Quantity'
				 evaluated: [ :sale | sale quantity printString ]);
		addColumn: (SpStringTableColumn
				 title: 'In fridge'
				 evaluated: [ :sale | sale quantityInFridge printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Price'
				 evaluated: [ :sale | sale price printString ]).
	foodTable := self newTable.
	foodTable
		addColumn: (SpStringTableColumn
				 title: 'Food'
				 evaluated: [ :category | category name ]);
		addColumn: (SpStringTableColumn
				 title: 'Price'
				 evaluated: [ :category |
					 (outlet pricePerUnitFor: category) printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Restocked'
				 evaluated: [ :category |
					 (self restockedOf: category) printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Sold'
				 evaluated: [ :category | (self soldOf: category) printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Spoiled'
				 evaluated: [ :category | (self spoiledOf: category) printString ]);
		addColumn: (SpStringTableColumn
				 title: 'In fridge'
				 evaluated: [ :category |
					 (day stockOf: category) inFridge printString ]);
		addColumn: (SpStringTableColumn
				 title: 'Outside'
				 evaluated: [ :category |
					 (day stockOf: category) outsideFridge printString ]);
		addColumn: (SpStringTableColumn
				 title: 'In last day'
				 evaluated: [ :category |
					 (day stockOf: category) inLastDay printString ]).
	salesLabel := self newLabel.
	stockLabel := self newLabel
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> restockedOf: aCategory [

	^ day restock occurrencesOf: aCategory
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> salesTable [

	^ salesTable
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> salesText [
	"Revenue: 40 from 2 households"

	| households |
	households := (day sales collect: [ :each | each household ]) asSet
		              size.
	^ 'Revenue: {1} from {2} {3}' format: {
			  (day sales inject: 0 into: [ :sum :each | sum + each price ]).
			  households.
			  (households = 1
				   ifTrue: [ 'household' ]
				   ifFalse: [ 'households' ]) }
]

{ #category : 'initialization' }
FEBOutletDayPresenter >> setModelBeforeInitialization: anOutlet [

	outlet := anOutlet
]

{ #category : 'updating' }
FEBOutletDayPresenter >> showDay: aDay [

	day := aDay.
	salesTable items: day sales asArray.
	salesLabel label: self salesText.
	foodTable items: outlet cormasModel foodCategories asArray.
	stockLabel label: self stockText
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> soldOf: aCategory [

	^ day sales inject: 0 into: [ :sum :each |
			  each category = aCategory
				  ifTrue: [ sum + each quantity ]
				  ifFalse: [ sum ] ]
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> spoiledOf: aCategory [

	^ day spoiledFood occurrencesOf: aCategory
]

{ #category : 'accessing' }
FEBOutletDayPresenter >> stockText [
	"Stock: 1200 meals, 300 in their last day"

	^ 'Stock: {1} meals, {2} in their last day' format: {
			  (day stock inject: 0 into: [ :sum :each | sum + each total ]).
			  (day stock inject: 0 into: [ :sum :each | sum + each inLastDay ]) }
]
