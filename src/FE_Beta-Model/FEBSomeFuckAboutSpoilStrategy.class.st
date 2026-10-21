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

{ #category : 'as yet unclassified' }
FEBSomeFuckAboutSpoilStrategy >> chooseBatchForNextMealFrom: aCollectionOfCandidates basedOn: aPreferenceDictionary [

	| sortedCandidates rankA rankB |
	
	sortedCandidates := aCollectionOfCandidates sorted: [ :a :b |
		rankA := self preferenceRankingOf: a category basedOn: aPreferenceDictionary.
		rankB := self preferenceRankingOf: a category basedOn: aPreferenceDictionary.
		
		rankA < rankB or: [ 
			rankA = rankB and: [ 
				a remainingDays < b remainingDays ] ] ].
	
	^ sortedCandidates first
]
