Class {
	#name : 'FEBNoSpoilWeirdoStrategy',
	#superclass : 'FEBFoodConsumptionStrategy',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'as yet unclassified' }
FEBNoSpoilWeirdoStrategy class >> strategyName [

	^ 'No spoil weirdo'
]

{ #category : 'consuming' }
FEBNoSpoilWeirdoStrategy >> mealsEatenFirstBy: aHousehold [

	^ aHousehold eatFoodInItsLastDay
]
