"
I test the perspectives of `FEBModel`: how households and outlets look in each of them, and which perspective each init method opens with.

## Responsibility:

- Check that each perspective draws households with the indicator it is named after, as the matching old point of view did.
- Check that the outlet image perspective draws outlets with the `#outlet` tile of `FEBTileset`.
- Check that every init method opens the simulation with a perspective the model defines.

## Collaborators:

- `FEBModel`: defines the perspectives and the init methods.
- `CMObserver`: fills the look of an entity under a perspective, as a view does.
- `FEBHousehold` and `FEBOutlet`: the entities whose looks are checked.

## Public API and Key Messages

- `lookOf:in:` answers the look of an entity in one of the model's perspectives.

```smalltalk
FEBPerspectiveTest run: #testSatietyPerspectiveShowsHowFullHouseholdsAre
```

## Internal Representation

- `household` has eaten once, so its indicators have a value rather than the gray of an empty history.
"
Class {
	#name : 'FEBPerspectiveTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'household',
		'outlet',
		'observer'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBPerspectiveTest >> assertHouseholdLook: aLook hasColor: aColor [

	self assert: aLook color equals: aColor.
	self assert: aLook shape equals: household shapeOfPovBasedOnStrategy.
	self
		assert: aLook size
		equals: household sizeOfPovBasedOnHouseholdSize
]

{ #category : 'helpers' }
FEBPerspectiveTest >> lookOf: anEntity in: aPerspectiveSelector [

	observer perspective: (model perspectiveNamed: aPerspectiveSelector).
	^ observer lookOf: anEntity
]

{ #category : 'running' }
FEBPerspectiveTest >> setUp [

	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	household := model newEntity: FEBHousehold.
	household foodPreferenceProportions:
		(model foodCategories collect: [ :each | each -> 0.2 ]) asDictionary.
	household substitutionList: Dictionary new.
	household consumeFood.
	outlet := model newEntity: FEBOutlet.
	observer := CMObserver new
]

{ #category : 'tests' }
FEBPerspectiveTest >> testCaloricAdequacyPerspectiveShowsTheCaloriesHouseholdsGet [

	self
		assertHouseholdLook:
		(self lookOf: household in: #perspectiveCaloricAdequacy)
		hasColor: household caloricAdequacyColor
]

{ #category : 'tests' }
FEBPerspectiveTest >> testEveryInitOpensWithAPerspectiveOfTheModel [

	| initMethods |
	initMethods := FEBModel methods select: [ :each |
		               each hasPragmaNamed: #init ].
	self denyEmpty: initMethods.
	initMethods do: [ :each |
			self
				assert: (each hasPragmaNamed: #perspective:)
				description: each selector , ' names no perspective'.
			self
				shouldnt: [
					model perspectiveNamed:
						(each pragmaAt: #perspective:) arguments first ]
				raise: Error ]
]

{ #category : 'tests' }
FEBPerspectiveTest >> testHealthyDietPerspectiveShowsWhetherHouseholdsEatHealthily [

	self
		assertHouseholdLook:
		(self lookOf: household in: #perspectiveHealthyDiet)
		hasColor: (household isHavingHealthyDiet
				 ifTrue: [ CMColor green ]
				 ifFalse: [ CMColor red ])
]

{ #category : 'tests' }
FEBPerspectiveTest >> testProteinAdequacyPerspectiveShowsTheProteinsHouseholdsGet [

	self
		assertHouseholdLook:
		(self lookOf: household in: #perspectiveProteinAdequacy)
		hasColor: household proteinAdequacyColor
]

{ #category : 'tests' }
FEBPerspectiveTest >> testSatietyAndOutletImagesPerspectiveDrawsOutletsWithTheirTile [

	| look |
	look := self lookOf: outlet in: #perspectiveSatietyAndOutletImages.
	self
		assert: (CMTileset tileNamed: look tile)
		identicalTo: FEBTileset outlet.
	self
		assertHouseholdLook:
		(self lookOf: household in: #perspectiveSatietyAndOutletImages)
		hasColor: household satietyIndicatorColor
]

{ #category : 'tests' }
FEBPerspectiveTest >> testSatietyPerspectiveDrawsOutletsAsGraySquares [

	| look |
	look := self lookOf: outlet in: #perspectiveSatiety.
	self assert: look color equals: Color gray.
	self assert: look shape equals: #square.
	self deny: look hasTile
]

{ #category : 'tests' }
FEBPerspectiveTest >> testSatietyPerspectiveShowsHowFullHouseholdsAre [

	self
		assertHouseholdLook:
		(self lookOf: household in: #perspectiveSatiety)
		hasColor: household satietyIndicatorColor
]
