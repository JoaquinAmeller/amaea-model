"
I am one leg of the shopping trip that a household made today: the walk from its home, or from the outlet it has just left, to the next outlet where it shops.

## Responsibility:

- I go from the household or an outlet to the outlet visited next, and belong to the trip of that household, a `FEBTrip`.
- I am never drawn on my own: my trip draws the path along its legs.
- I last one day: the model deletes all legs at the start of each step.

## Collaborators:

- `FEBSimpleShoppingStrategy` creates me each time a household walks to an outlet, and adds me to its trip.
- `FEBModel` deletes the legs of yesterday at the start of a step.

## Public API and Key Messages

- `from`, `to`: where the walk started and the outlet it reached.

```
household trip links
```
"
Class {
	#name : 'FEBTripLeg',
	#superclass : 'CMLink',
	#category : 'FE_Beta-Model',
	#package : 'FE_Beta-Model'
}

{ #category : 'aspects' }
FEBTripLeg >> aspectDefault: look [
	"A leg is never drawn on its own: its trip draws the whole path"

	<aspect>
	look beInvisible
]
