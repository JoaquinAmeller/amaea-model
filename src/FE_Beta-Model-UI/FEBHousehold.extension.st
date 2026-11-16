Extension { #name : 'FEBHousehold' }

{ #category : '*FE_Beta-Model-UI' }
FEBHousehold >> inspectionDashboard: aBuilder [

	<inspectorPresentationOrder: 0 title: 'Dashboard'>
	^ FEBHouseholdDashboard on: self
]
