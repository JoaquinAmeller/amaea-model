"
I am the food preference of a household that eats a lot of animal proteins and dairy.

## Responsibility:

- Give the share of each food category in `shares`.
- Show in red on a household.

## Collaborators:

- `FEBHousehold` takes me with its action `preferMeatAndDairy`.

## Public API and Key Messages

See `FEBFoodPreference`.

```
household preferMeatAndDairy
```
"
Class {
	#name : 'FEBMeatAndDairyPreference',
	#superclass : 'FEBFoodPreference',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBMeatAndDairyPreference >> color [

	^ CMColor tangerine
]

{ #category : 'accessing' }
FEBMeatAndDairyPreference >> shares [

	^ {
		  ('Animal proteins' -> 0.35).
		  ('Fruits and vegetables' -> 0.15).
		  ('Staple food' -> 0.15).
		  ('Dairy' -> 0.3).
		  ('Processed food' -> 0.05) }
]
