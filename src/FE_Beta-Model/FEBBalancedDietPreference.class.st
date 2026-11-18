"
I am the food preference of a household that has a balanced diet.

## Responsibility:

- Give the share of each food category in `shares`.
- Show in green on a household.

## Collaborators:

- `FEBHousehold` takes me with its action `preferBalancedDiet`.

## Public API and Key Messages

See `FEBFoodPreference`.

```
household preferBalancedDiet
```
"
Class {
	#name : 'FEBBalancedDietPreference',
	#superclass : 'FEBFoodPreference',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBBalancedDietPreference >> color [

	^ CMColor azure
]

{ #category : 'accessing' }
FEBBalancedDietPreference >> shares [

	^ {
		  ('Animal proteins' -> 0.2).
		  ('Fruits and vegetables' -> 0.3).
		  ('Staple food' -> 0.25).
		  ('Dairy' -> 0.15).
		  ('Processed food' -> 0.1) }
]
