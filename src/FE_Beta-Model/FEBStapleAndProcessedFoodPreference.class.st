"
I am the food preference of a household that eats a lot of staple and processed food.

## Responsibility:

- Give the share of each food category in `shares`.
- Show in brown on a household.

## Collaborators:

- `FEBHousehold` takes me with its action `preferStapleAndProcessedFood`.

## Public API and Key Messages

See `FEBFoodPreference`.

```
household preferStapleAndProcessedFood
```
"
Class {
	#name : 'FEBStapleAndProcessedFoodPreference',
	#superclass : 'FEBFoodPreference',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'accessing' }
FEBStapleAndProcessedFoodPreference >> color [

	^ CMColor pink
]

{ #category : 'accessing' }
FEBStapleAndProcessedFoodPreference >> shares [

	^ {
		  ('Animal proteins' -> 0.1).
		  ('Fruits and vegetables' -> 0.1).
		  ('Staple food' -> 0.4).
		  ('Dairy' -> 0.1).
		  ('Processed food' -> 0.3) }
]
