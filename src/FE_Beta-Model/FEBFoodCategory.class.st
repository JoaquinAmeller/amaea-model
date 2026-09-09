Class {
	#name : 'FEBFoodCategory',
	#superclass : 'Object',
	#instVars : [
		'name',
		'shelfLifeInFridge',
		'shelfLifeOutsideFridge',
		'kilocaloriesPerPortion',
		'proteinsPerPortion'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'as yet unclassified' }
FEBFoodCategory class >> named: aString shelfLifeInFridge: aNumber outsideFridge: anotherNumber [

	^ self new
		name: aString;
		shelfLifeInFridge: aNumber;
		shelfLifeOutsideFridge: anotherNumber;
		yourself
]

{ #category : 'accessing' }
FEBFoodCategory >> kilocaloriesPerPortion [

	^ kilocaloriesPerPortion
]

{ #category : 'accessing' }
FEBFoodCategory >> kilocaloriesPerPortion: anObject [

	kilocaloriesPerPortion := anObject
]

{ #category : 'accessing' }
FEBFoodCategory >> name [

	^ name
]

{ #category : 'accessing' }
FEBFoodCategory >> name: anObject [

	name := anObject
]

{ #category : 'printing' }
FEBFoodCategory >> printOn: aString [

	super printOn: aString.
	aString << ' (' << name << ')'
]

{ #category : 'accessing' }
FEBFoodCategory >> proteinsPerPortion [

	^ proteinsPerPortion
]

{ #category : 'accessing' }
FEBFoodCategory >> proteinsPerPortion: anObject [

	proteinsPerPortion := anObject
]

{ #category : 'as yet unclassified' }
FEBFoodCategory >> shelfLifeGivenFridge: aBoolean [

	^ aBoolean
		ifTrue: [ shelfLifeInFridge ]
		ifFalse: [ shelfLifeOutsideFridge ]
]

{ #category : 'accessing' }
FEBFoodCategory >> shelfLifeInFridge [

	^ shelfLifeInFridge
]

{ #category : 'accessing' }
FEBFoodCategory >> shelfLifeInFridge: anObject [

	shelfLifeInFridge := anObject
]

{ #category : 'accessing' }
FEBFoodCategory >> shelfLifeOutsideFridge [

	^ shelfLifeOutsideFridge
]

{ #category : 'accessing' }
FEBFoodCategory >> shelfLifeOutsideFridge: anObject [

	shelfLifeOutsideFridge := anObject
]

{ #category : 'asserting' }
FEBFoodCategory >> shouldBeStoredInFridge [

	^ shelfLifeOutsideFridge <= 2 and: [ shelfLifeInFridge > 2 ]
]
