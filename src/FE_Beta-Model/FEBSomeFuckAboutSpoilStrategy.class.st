Class {
	#name : 'FEBSomeFuckAboutSpoilStrategy',
	#superclass : 'FEBFoodConsumptionStrategy',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'as yet unclassified' }
FEBSomeFuckAboutSpoilStrategy class >> strategyName [

	^ 'Some fuck about spoil'
]

{ #category : 'consuming' }
FEBSomeFuckAboutSpoilStrategy >> mealsEatenFirstBy: aHousehold [

	^ OrderedCollection new
]
