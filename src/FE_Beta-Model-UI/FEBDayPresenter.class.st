"
I am the ""Day"" tab of an entity's dashboard. My subclasses show the day of a household and of an outlet.

## Responsibility:

- Lay out titled sections whose summary sits at the right of the title's line.
- Define what my subclasses answer: `showDay:` to show a day of the entity's history.
- Keep the look of both dashboards' ""Day"" tabs the same.

## Collaborators:

- `FEBEntityDashboard`: tells me which day to show.
- `FEBHouseholdDayPresenter` and `FEBOutletDayPresenter`: my subclasses.

## Public API and Key Messages

- `title:with:` answers a layout with a title at the left and a summary label at the right.
- Subclasses implement `showDay:`.

```smalltalk
(FEBHouseholdDayPresenter on: aHousehold) showDay: aHousehold history lastDay; open
```
"
Class {
	#name : 'FEBDayPresenter',
	#superclass : 'SpPresenter',
	#category : 'FE_Beta-Model-UI',
	#package : 'FE_Beta-Model-UI'
}

{ #category : 'layout' }
FEBDayPresenter >> showDay: aDay [
	"Show aDay of the entity's history"

	^ self subclassResponsibility
]

{ #category : 'layout' }
FEBDayPresenter >> title: aString with: aSummaryLabel [
	"A section's title at the left of the line, and its summary at the right"

	^ SpBoxLayout newLeftToRight
		  add: aString expand: false;
		  addLast: aSummaryLabel expand: false;
		  yourself
]
