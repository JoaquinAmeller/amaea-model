Class {
	#name : 'BaselineOfAmaeaModel',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfAmaeaModel',
	#package : 'BaselineOfAmaeaModel'
}

{ #category : 'baselines' }
BaselineOfAmaeaModel >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'FE_Beta-Model';
		
			package: 'FE_Beta-Model-Tests'
			with: [ spec requires: #('FE_Beta-Model') ] ]
]
