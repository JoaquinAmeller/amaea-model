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

{ #category : 'as yet unclassified' }
FEBNoSpoilWeirdoStrategy >> chooseBatchForNextMealFrom: aCollectionOfCandidates basedOn: aPreferenceDictionary [

	| sortedCandidates rankA rankB |
	
	sortedCandidates := aCollectionOfCandidates sorted: [ :a :b |
		a remainingDays < b remainingDays or: [ 
			a remainingDays = b remainingDays and: [ 
				rankA := self preferenceRankingOf: a category basedOn: aPreferenceDictionary.
				rankB := self preferenceRankingOf: a category basedOn: aPreferenceDictionary.
				rankA < rankB ] ] ].
	
	^ sortedCandidates first
]
