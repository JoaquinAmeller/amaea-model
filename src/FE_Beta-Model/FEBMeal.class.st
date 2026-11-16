"
I represent one meal a household ate: a portion of a food category, and why it was that food.

## Responsibility:

- Know the food category eaten.
- Know why it was eaten: `#ownShare` (the category's share of the daily need), `#substitute` (in place of a category that was missing, following the substitution list), `#leftover` (any food left when shares and substitutes were not enough) or `#lastDay` (food in its last day, eaten first by the ""No spoil weirdo"" strategy).
- Be a value: two meals of the same category eaten for the same reason are equal, so that a day can count them instead of keeping each one.

## Collaborators:

- `FEBHousehold`: creates me when it eats, and answers me from `consumeFood`.
- `FEBHouseholdDay`: keeps me among the meals of a day.
- `FEBFoodCategory`: the food I am a portion of.

## Public API and Key Messages

- `category` and `reason`.
- Create me with `FEBMeal category: aCategory reason: #ownShare`.

```smalltalk
| dairy meal |
dairy := FEBFoodCategory named: 'Dairy' shelfLifeInFridge: 6 outsideFridge: 2.
meal := FEBMeal category: dairy reason: #substitute.
meal reason ""#substitute""
```

## Internal Representation

- `category`: a `FEBFoodCategory`.
- `reason`: one of the Symbols `#ownShare`, `#substitute`, `#leftover`, `#lastDay`.
"
Class {
	#name : 'FEBMeal',
	#superclass : 'Object',
	#instVars : [
		'category',
		'reason'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'instance creation' }
FEBMeal class >> category: aCategory reason: aSymbol [

	^ self new
		  initializeCategory: aCategory reason: aSymbol;
		  yourself
]

{ #category : 'comparing' }
FEBMeal >> = anObject [
	"Two meals of the same category, eaten for the same reason, are the same meal"

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ category = anObject category and: [ reason = anObject reason ]
]

{ #category : 'accessing' }
FEBMeal >> category [

	^ category
]

{ #category : 'comparing' }
FEBMeal >> hash [

	^ category hash bitXor: reason hash
]

{ #category : 'initialization' }
FEBMeal >> initializeCategory: aCategory reason: aSymbol [

	category := aCategory.
	reason := aSymbol
]

{ #category : 'printing' }
FEBMeal >> printOn: aStream [

	super printOn: aStream.
	aStream << ' (' << category name << ', ' << reason << ')'
]

{ #category : 'accessing' }
FEBMeal >> reason [

	^ reason
]
