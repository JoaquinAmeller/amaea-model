Class {
	#name : 'FEBShoppingList',
	#superclass : 'Object',
	#instVars : [
		'essentialNeeds',
		'storageNeeds'
	],
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'adding' }
FEBShoppingList >> addEssentialNeedOf: aCategory quantity: anInteger [

	essentialNeeds
		at: aCategory
		put: ((essentialNeeds at: aCategory ifAbsent: [ 0 ]) + anInteger)
]

{ #category : 'adding' }
FEBShoppingList >> addStorageNeedOf: aCategory quantity: anInteger [

	storageNeeds 
		at: aCategory
		put: ((storageNeeds at: aCategory ifAbsent: [ 0 ]) + anInteger)
]

{ #category : 'as yet unclassified' }
FEBShoppingList >> decreaseNeedOf: aCategory by: anInteger [

	| essential storage remaining taken |
	
	essential := self essentialNeedOf: aCategory.
	storage := self storageNeedOf: aCategory.
	
	remaining := anInteger.
	
	"Fulfill the essential need first"
	taken := remaining min: essential.
	remaining := remaining - taken.
	essential := essential - taken.
	
	essential = 0
		ifTrue: [ essentialNeeds removeKey: aCategory ifAbsent: [ "do nothing" ] ]
		ifFalse: [ essentialNeeds at: aCategory put: essential ].
		
	"Then storage"
	taken := remaining min: storage.
	storage := storage - taken.
	
	storage = 0
		ifTrue: [ storageNeeds removeKey: aCategory ifAbsent: [ "do nothing" ] ]
		ifFalse: [ storageNeeds at: aCategory put: storage ]
]

{ #category : 'as yet unclassified' }
FEBShoppingList >> decreaseStorageNeedOf: aCategory by: anInteger [

	| diff |
	diff := (storageNeeds at: aCategory) - anInteger.
	
	diff < 0 ifTrue: [ self error: 'Trying to decrease more than we have!' ].
	diff = 0 ifTrue: [ storageNeeds removeKey: aCategory ].
	diff > 0 ifTrue: [ storageNeeds at: aCategory put: diff ]
]

{ #category : 'as yet unclassified' }
FEBShoppingList >> essentialNeedOf: aCategory [ 
	
	^ essentialNeeds at: aCategory ifAbsent: [ 0 ]
]

{ #category : 'accessing' }
FEBShoppingList >> essentialNeeds [

	^ essentialNeeds
]

{ #category : 'accessing' }
FEBShoppingList >> hasAnyNeeds [

	^ self hasEssentialNeeds or: [ self hasStorageNeeds ]
]

{ #category : 'accessing' }
FEBShoppingList >> hasEssentialNeeds [

	^ essentialNeeds values anySatisfy: [ :each | each > 0 ]
]

{ #category : 'accessing' }
FEBShoppingList >> hasStorageNeeds [

	^ storageNeeds values anySatisfy: [ :each | each > 0 ]
]

{ #category : 'initialization' }
FEBShoppingList >> initialize [

	super initialize.
	essentialNeeds := Dictionary new.
	storageNeeds := Dictionary new
]

{ #category : 'as yet unclassified' }
FEBShoppingList >> storageNeedOf: aCategory [ 
	
	^ storageNeeds at: aCategory ifAbsent: [ 0 ]
]

{ #category : 'accessing' }
FEBShoppingList >> storageNeeds [

	^ storageNeeds 
]
