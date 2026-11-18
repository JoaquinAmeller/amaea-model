"
I am the food preference of a household: the share of its daily need it prefers to eat of each food category.

## Responsibility:

- Know the share of each food category, by its name.
- Answer those shares for the food categories of a model.
- Know the color that shows me on a household.

## Collaborators:

- `FEBHousehold` keeps me, and gets its preference proportions from me with its actions `preferMeatAndDairy`, `preferStapleAndProcessedFood` and `preferBalancedDiet`.
- `FEBModel` shares its households equally among my subclasses in `initializePreferences`.

## Public API and Key Messages

- `sharesIn: aModel`: a `Dictionary` from the food categories of aModel to their shares.
- `color`: shown by the aspect `aspectFoodPreference:` of a household.

I am abstract. Each subclass is one preference:

```
household preferBalancedDiet.
household foodPreference color
```
"
Class {
	#name : 'FEBFoodPreference',
	#superclass : 'Object',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBFoodPreference >> color [
	"Answer the color that shows me on a household"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
FEBFoodPreference >> shares [
	"Answer the share of the daily need for each food category, by its name"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
FEBFoodPreference >> sharesIn: aModel [
	"Answer the share of the daily need that a household with me prefers to eat of each food category of aModel"

	^ (self shares collect: [ :each |
		   (aModel foodCategoryNamed: each key) -> each value ])
		  asDictionary
]
