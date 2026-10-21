Class {
	#name : 'FEBFoodConsumptionStrategy',
	#superclass : 'Object',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'as yet unclassified' }
FEBFoodConsumptionStrategy class >> strategyName [

	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
FEBFoodConsumptionStrategy >> chooseBatchForNextMealFrom: aCollectionOfCandidates basedOn: aPreferenceDictionary [

	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
FEBFoodConsumptionStrategy >> preferenceRankingOf: aCategory basedOn: aPreferenceDictionary [

	^ aPreferenceDictionary orderedKeys 
		indexOf: aCategory
		ifAbsent: [ self error: 'All categories must appear in the preference list' ]
]
