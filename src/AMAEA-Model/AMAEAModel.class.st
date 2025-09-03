Class {
	#name : 'AMAEAModel',
	#superclass : 'CMAbstractModel',
	#instVars : [
		'landPlots'
	],
	#category : 'AMAEA-Model',
	#package : 'AMAEA-Model'
}

{ #category : 'as yet unclassified' }
AMAEAModel >> initialEnvironment [
	<init>
	self createGridNumberOfRows:100  numberOfColumns:100  neighbourhood:8  closed:true 
]

{ #category : 'as yet unclassified' }
AMAEAModel >> initialize [
	super initialize.
	landPlots := OrderedCollection new
]

{ #category : 'as yet unclassified' }
AMAEAModel >> landPlots [
	<getterFor: #AMAEALandPlot >
	^landPlots
	
]

{ #category : 'as yet unclassified' }
AMAEAModel >> step [
	<control>
]
