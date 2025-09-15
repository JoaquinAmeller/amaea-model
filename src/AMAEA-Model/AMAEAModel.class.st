Class {
	#name : 'AMAEAModel',
	#superclass : 'CMAbstractModel',
	#category : 'AMAEA-Model',
	#package : 'AMAEA-Model'
}

{ #category : 'as yet unclassified' }
AMAEAModel >> initialEnvironment [
	<init>
	
	| land1 land2 land3 household1 household2 household3 |
	
	self
		createGridNumberOfRows: 10 
		numberOfColumns: 10 
		neighbourhood: 8 
		closed: true. 
		
	self createN: 3 randomlyLocatedAloneEntities: AMAEAHousehold.
	
	land1 := #(50 60 69 70) collect: [ :id | self cellAt: id ].
	land2 := #(84 85 86 94 95 96) collect: [ :id | self cellAt: id ].
	land3 := #(51 61 71) collect: [ :id | self cellAt: id ].
	
	household1 := (self @@ AMAEAHousehold) first.
	household2 := (self @@ AMAEAHousehold) second.
	household3 := (self @@ AMAEAHousehold) third.
	
	household1 land: land1.
	household2 land: land2.
	household3 land: land3.
	
	(self @@ AMAEAHousehold) do: [ :each | each moveTo: (self selectRandomlyFrom: each land) ]
]

{ #category : 'as yet unclassified' }
AMAEAModel >> step [
	<control>
	"do nothing"
]
