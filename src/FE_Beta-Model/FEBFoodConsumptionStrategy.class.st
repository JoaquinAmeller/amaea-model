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

{ #category : 'consuming' }
FEBFoodConsumptionStrategy >> mealsEatenFirstBy: aHousehold [
	"Make aHousehold eat the meals that come before its daily need is split by its preferences. Answer the categories of those meals, in an OrderedCollection."

	^ self subclassResponsibility
]
