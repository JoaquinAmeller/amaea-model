"
I test the history a `FEBHousehold` keeps: one record per time step, and its indicators computed for any day of it.

## Responsibility:

- Check that each time step has its own record of the meals eaten, and that everything done in a step goes to that step's record.
- Check that satiety, calories, proteins and healthy diet can be computed for any recorded day, not only the latest.
- Check that a household that has not eaten yet counts as full.

## Collaborators:

- `FEBHousehold`: the household under test, a person needing 10 meals a day.
- `FEBModel`: its simulation context gives the time step, which the tests move forward by hand.

## Public API and Key Messages

- `onDay:eat:` moves the clock to a day, gives the household exactly that food, and lets it eat.

```smalltalk
FEBHouseholdHistoryTest run: #testEachDayRecordsTheMealsEatenThatDay
```
"
Class {
	#name : 'FEBHouseholdHistoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'household',
		'stapleFood',
		'fruitsAndVegetables',
		'animalProteins'
	],
	#category : 'FE_Beta-Model-Tests',
	#package : 'FE_Beta-Model-Tests'
}

{ #category : 'helpers' }
FEBHouseholdHistoryTest >> dayAt: aStep [

	^ household history dayAt: aStep
]

{ #category : 'helpers' }
FEBHouseholdHistoryTest >> eatAWeekFrom: aStep withFruitsAndVegetables: aBoolean [

	aStep to: aStep + 6 do: [ :day |
			self onDay: day eat: (aBoolean
					 ifTrue: [
							 {
								 (stapleFood -> 5).
								 (fruitsAndVegetables -> 3).
								 (animalProteins -> 2) } ]
					 ifFalse: [
							 {
								 (stapleFood -> 8).
								 (animalProteins -> 2) } ]) ]
]

{ #category : 'helpers' }
FEBHouseholdHistoryTest >> onDay: aStep eat: anArrayOfAssociations [
	"Move the clock to aStep, give the household exactly this food, category -> quantity, and let it eat"

	model simulationContext currentTimeStep: aStep.
	household inventory batches removeAll.
	anArrayOfAssociations do: [ :each |
			household inventory addBatch:
				(FEBFoodBatch
					 category: each key
					 quantity: each value
					 fridge: false) ].
	household consumeFood
]

{ #category : 'running' }
FEBHouseholdHistoryTest >> setUp [
	"A person needing 10 meals a day, preferring 5 staple food, 3 fruits and vegetables and 2 animal proteins, with no food"

	super setUp.
	model := FEBModel new.
	model initializeFoodCategories.
	stapleFood := model foodCategoryNamed: 'Staple food'.
	fruitsAndVegetables := model foodCategoryNamed:
		                       'Fruits and vegetables'.
	animalProteins := model foodCategoryNamed: 'Animal proteins'.

	household := model newEntity: FEBHousehold.
	household instVarNamed: #householdSize put: 1.
	household instVarNamed: #dailyNeed put: 10.
	household foodPreferenceProportions: {
			(stapleFood -> 0.5).
			(fruitsAndVegetables -> 0.3).
			(animalProteins -> 0.2) } asDictionary.
	model initializeSubstitutionList.
	household inventory batches removeAll
]

{ #category : 'tests' }
FEBHouseholdHistoryTest >> testAHouseholdThatHasNotEatenYetCountsAsFull [

	self assert: household satietyScore equals: 1.
	self assert: household isFull
]

{ #category : 'tests' }
FEBHouseholdHistoryTest >> testCaloriesAndProteinsCanBeComputedForAnyDay [
	"8 meals of staple food are 2080 kilocalories, 2 meals of animal proteins are 74 grams of protein"

	self onDay: 1 eat: { (stapleFood -> 8) }.
	self onDay: 2 eat: { (animalProteins -> 2) }.

	self
		assert: (household caloricAdequacyScoreOn: (self dayAt: 1))
		equals: 2080 / 2000.
	self
		assert: (household proteinAdequacyScoreOn: (self dayAt: 2))
		equals: 74 / 60
]

{ #category : 'tests' }
FEBHouseholdHistoryTest >> testEachDayRecordsTheMealsEatenThatDay [

	self onDay: 1 eat: { (stapleFood -> 10) }.
	self onDay: 2 eat: { (stapleFood -> 3) }.

	self assert: (self dayAt: 1) meals size equals: 10.
	self assert: (self dayAt: 2) meals size equals: 3
]

{ #category : 'tests' }
FEBHouseholdHistoryTest >> testEverythingEatenInATimeStepGoesToThatStepsRecord [

	self onDay: 1 eat: { (stapleFood -> 4) }.
	self onDay: 1 eat: { (stapleFood -> 4) }.

	self assert: household history days size equals: 1.
	self assert: (self dayAt: 1) meals size equals: 8
]

{ #category : 'tests' }
FEBHouseholdHistoryTest >> testHealthyDietLooksAtTheWeekUpToTheDay [

	self eatAWeekFrom: 1 withFruitsAndVegetables: true.
	self eatAWeekFrom: 8 withFruitsAndVegetables: false.

	self assert: (household isHavingHealthyDietOn: (self dayAt: 7)).
	self deny: (household isHavingHealthyDietOn: (self dayAt: 14)).
	self deny: household isHavingHealthyDiet
]

{ #category : 'tests' }
FEBHouseholdHistoryTest >> testSatietyCanBeComputedForAnyDay [

	self onDay: 1 eat: { (stapleFood -> 10) }.
	self onDay: 2 eat: { (stapleFood -> 3) }.

	self assert: (household satietyScoreOn: (self dayAt: 1)) equals: 1.
	self
		assert: (household satietyScoreOn: (self dayAt: 2))
		equals: 3 / 10.
	self assert: household satietyScore equals: 3 / 10
]
