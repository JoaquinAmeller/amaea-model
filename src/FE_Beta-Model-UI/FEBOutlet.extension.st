Extension { #name : 'FEBOutlet' }

{ #category : '*FE_Beta-Model-UI' }
FEBOutlet >> inspectionDashboard: aBuilder [

	<inspectorPresentationOrder: 0 title: 'Dashboard'>
	^ FEBOutletDashboard on: self
]

{ #category : '*FE_Beta-Model-UI' }
FEBOutlet >> inspectionDashboardContext: aContext [

	aContext withoutEvaluator
]
