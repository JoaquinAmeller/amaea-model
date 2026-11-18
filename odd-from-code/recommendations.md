# AMAEA model — Recommendations

Companion to [`odd.md`](odd.md). Based on reading the code at commit `89bba54` and on a few **exploratory runs** made in the image (big‑grid scenario, 100 households, 40 outlets, 30 steps, averages over steps 11–30, **one random seed** — indicative only, not results).

> **Status at commit `3460a98` (2026‑11‑18).** Since these recommendations were written:
>
> - **Done:** each household now keeps its preference profile as an object (`foodPreference`, item 2.4 / checklist 11). Seven probes were added (missing meals, diet diversity, outlet stockouts, minutes to the first outlet, outlets visited, shopping minutes, share of budget spent), which covers money and time used and distance (part of item 1.5). Six named scenario inits set every parameter (part of item 1.4). Experiments with replicated seeds were run for availability and proximity: see [`scenarios.md`](scenarios.md), which also covers part of items 2.1–2.3 and 5.4.
> - **Confirmed by those experiments:** money per household (item 1.1) makes 5‑person households hungry in every scenario. Trips that go on with no money and a walk home that is free (item 1.2) make time almost no constraint.
> - **New:** `FEBHousehold>>initialize` now sets a default preference, which needs the model's food categories. The 16 tests of `FEBHouseholdConsumptionTest` fail because of it (checklist 15).
> - **Still open:** everything else, marked in the checklist of §8.

---

## 0. Summary

### The five things to do in the next 2 days

| # | Action | Why now | Effort |
|---|---|---|---|
| 1 | **Decide how money scales with household size** (per person or per household) and fix the default budget | With the defaults, money alone decides the outcome: 84 % of households are hungry, whatever else you change | 1–2 h |
| 2 | **Fix three small behaviour bugs**: trip continues with no money; household sizes not uniform; parameters overwritten by `initUnconstraintedScenario` | They bias every result and are one‑line fixes | 2 h |
| 3 | **Add the probes still missing** (outlet waste, healthy diet, meal reasons, per‑strategy and per‑profile means); money and time used and distances now have probes | You cannot analyse what you do not measure; today half of the interesting outputs are only in dashboards | 2 h |
| 4 | **Turn the experiment loop of `scenarios.md` into a batch‑run script** (seeds × parameters → CSV) and run a first one‑factor sweep | Turns the model from a demo into an experiment; gives you figures | 2–3 h |
| 5 | **Rename strategies and fill ODD §1 (purpose, patterns)** | Needed before showing the model to anyone outside the team | 1 h |

A detailed 2‑day plan is in §2.

---

## 1. What the exploratory runs show

| Setting (others default) | Satiety | Caloric score | Household waste | Outlet waste | Remark |
|---|---|---|---|---|---|
| money 100 (default) | 0.59 | 0.67 | ~11 meals/day | ~3 900 meals/day (≈ 49 % of restock) | 2 000 meals sold per day = 100 households × 100 / 5: **every household spends its whole budget** |
| money 200 | 0.93 | 1.02–1.08 | 58–145 | ~2 900 | |
| money 300 | 0.99 | 1.00–1.17 | 178–500 | ~2 350 | |
| money 500 | 0.99 | 0.97–1.23 | 400–990 | ~1 940 | |
| money 300, fridge 6 / 30 / 100 | 0.99 | ~1.0 | 4 / 3 / 7 % of bought | ≈ 30 % of restock | Fridge capacity has **little effect** |
| money 300, time 15 / 30 / 60 min | 0.82 / 0.95 / 0.98 | 0.88 / 0.99 / 1.00 | 4 % | 37 / 32 / 30 % | Time matters **below ~30 min** |
| Consumption strategy, money 300 | same satiety | 1.00 ("No spoil weirdo") vs 1.17 ("Some fuck about spoil") | 178 vs 500 meals/day | same | Eating last‑day food first cuts household waste by ~65 % but changes the diet |

Reading:

1. **The default scenario is budget‑bound.** Money is not scaled by household size (100 per household, 5 per meal → 20 meals; needs are 20–50). Only 2‑person households (≈ 1/6) are full. Every other mechanism (fridge, strategies, spatial access) is invisible in this regime.
2. **Outlets waste a lot** (30–50 % of what they restock): restock is random and ignores demand, outlets sell the freshest food first, and fruit & vegetables are on sale for one day only (see `odd.md` Appendix B.3).
3. **MoneySaver vs TimeSaver barely differ** in outcomes (satiety 0.61 vs 0.57 at money 100, ≈ equal above). The thresholds only affect *storage* purchases.
4. **"Healthy diet" depends on the consumption strategy** (68 vs 100 healthy households at money 300) — a sign that the indicator measures leftovers as much as diet.

---

## 2. Priority 1 — next 2 days

Each item: **What** · **Why** · **How** (where in the code) · **Done when**.

### Day 1 — make the model right and measurable

#### 1.1 Scale money with household size *(1–2 h)*

- **What**: make the budget per person (`availableMoneyPerPersonPerStep × householdSize`), or keep it per household but make it explicit in the ODD and choose a default that is not binding for everyone.
- **Why**: §1 — today the result is "big households are hungry", by construction.
- **How**: `FEBHousehold>>initialize` (`availableMoneyPerStep := …`). Add a parameter or a distribution (see 3.2 income heterogeneity). Update `testSpendsAllItsMoneyOnFoodForTheDayIfNeeded` & related if the meaning changes.
- **Done when**: with the default scenario, satiety varies between households for reasons other than size.

#### 1.2 Stop the trip when money is gone; count the walk home *(30 min)*

- **What**: in `FEBSimpleShoppingStrategy>>shopFor:using:` stop when `remainingMoney` cannot buy one meal; check `t_to_outlet + t_back_home ≤ budget` in `can:travelFor:with:`.
- **Why**: households now walk the full 2 h with an empty wallet (84 % of time used at money 100), which inflates "time spent" and hides the time trade‑off.
- **Done when**: a test "a household with no money left goes home" passes.

#### 1.3 Uniform household sizes *(15 min)*

- **What**: replace `randomIntegerBetween:and:` (which rounds a float: P = 1/6, 1/3, 1/3, 1/6) by `self selectRandomlyFrom: (min to: max)`, or better by an empirical distribution (see §4).
- **Done when**: a test over many households shows each size with ≈ equal frequency.

#### 1.4 Do not overwrite parameters in inits *(30 min)*

- **What**: `initUnconstraintedScenario` sets class parameters, so the Cormas parameter panel is silently ignored. Either move those values into named *scenarios* documented in the ODD, or keep one `initFromParameters` that reads everything from parameters (grid size too).
- **Done when**: changing a parameter in the UI changes the run, for every init.
- **Status (`3460a98`)**: `initCustomizable` no longer sets the restock. The six experiment inits (`initBaseline` …) are named scenarios that set *every* class parameter, documented in `odd.md` §5.2. `initUnconstraintedScenario` still overwrites four parameters and leaves the others to whatever the previous run set.

#### 1.5 Add probes *(2–3 h)*

Add `<probeNamed:>` methods on `FEBModel` for:

| Probe | Computation | Status (`3460a98`) |
|---|---|---|
| Outlet waste | Σ over outlets of `history lastDay spoiledFood size` | open |
| Food sold | Σ of today's sales quantities | open |
| Share of budget spent | mean over households that shopped of `moneySpent / moneyAvailable` | **done** (`averageShareOfBudgetSpent`) |
| Share of time spent | idem with time | as minutes: **done** (`averageShoppingMinutes`) |
| Households that went shopping | count `history lastDay wentShopping` | open (`householdsThatWentShopping` exists) |
| Number of people with a healthy diet | Σ size of `isHavingHealthyDiet` | open |
| Share of meals that are substitutes / leftovers / last‑day | from `history lastDay meals` reasons | open |
| Satiety of MoneySavers / TimeSavers | means per strategy | open |
| Satiety and adequacy per preference profile (A, B, C) | grouped by `foodPreference class` (see 2.4) | open, now possible |
| Mean walking time | mean `timeSpent` | **done** (`averageShoppingMinutes`) |

Also added, for the scenarios: missing meals, diet diversity, outlet stockouts, minutes to the first outlet, outlets visited (`odd.md` §8.1).

Keep them cheap (they run every step). **Done when**: one run's CSV export contains all of them.

#### 1.6 Unit and naming clean‑up *(1 h)*

- Rename strategies before any presentation: *No spoil weirdo* → **"Eat expiring food first"**; *Some fuck about spoil* → **"Ignore expiry dates"**; *Rich bastard* → **"Unconstrained shopper"**; *Desperate saver* → **"Money‑and‑time saver"**. Keep the class names consistent (`FEBEatExpiringFirstStrategy`, …).
- Remove dead state (`listOfOutlets`, `conventionalFoodInventory`, `healthyFoodInventory`, `FEBCell>>state`, `satisfactionMemory`) or mark it as planned in the ODD.
- Fix the "healthy diet" comment (it says fruits & vegetables, meat, staple; the code checks all 5 categories).

### Day 2 — run experiments and get first figures

#### 2.1 Batch‑run script *(2 h)*

A script in a Playground (or a class `FEBExperiment` in a non‑committed `FE_Beta-Model-Experiments` package) that runs replicates and writes one CSV row per (run, step). Class parameters set **after** `CMSimulation for:` and **before** `initializeSimulation` are kept (checked in the image):

```smalltalk
| rows |
rows := OrderedCollection new.
#(100 200 300 500) do: [ :money |
	1 to: 10 do: [ :seed |
		| sim model |
		sim := CMSimulation for: FEBModel new.
		FEBHousehold availableMoneyPerStep: money.
		sim
			activeInitSelector: #initBigGridScenario;
			activeControlSelector: #step;
			randomSeed: seed;
			hasFixedRandomSeed: true;
			initializeSimulation.
		model := sim cormasModel.
		1 to: 60 do: [ :step |
			sim runStep.
			rows add: {
				money. seed. step.
				model averageSatietyScore.
				model averageCaloricAdequacyScore.
				model averageProteinAdequacyScore.
				model amountOfSpoiledFoodInHouseholds.
				model totalSupply } ] ] ].
FEBHousehold availableMoneyPerStep: 100.
'amaea-money-sweep.csv' asFileReference writeStreamDo: [ :stream |
	stream nextPutAll: 'money,seed,step,satiety,caloric,protein,hhWaste,totalSupply'; lf.
	rows do: [ :row |
		stream nextPutAll: (',' join: (row collect: [ :each | each printString ])); lf ] ]
```

A 30‑step big‑grid run takes ≈ 6 s, so 4 values × 10 seeds × 60 steps ≈ 8 min.

**Status (`3460a98`)**: the first experiments were run with a loop of this kind, from a Playground, over six named scenarios × 10 seeds × 90 steps (`scenarios.md` §1, "Reproduce", and Figure 26). With the scenario inits, the parameters are set by the init itself, so the loop only chooses the init and the seed. Steps take ≈ 180 ms now on the 30 × 30 grid (17 s per 90‑step run, 25 s with 100 outlets). There is still no reusable script or class.

#### 2.2 First experiments *(2 h running, 2 h plots)*

1. **Warm‑up**: plot total supply and waste over 60 steps. Staple and processed food accumulate in outlets for 30 steps; **discard at least the first 30 steps** and use steps 31–60 (or longer) for outputs.
2. **Replicates**: compute the coefficient of variation of each output over seeds; increase seeds until the mean stabilises (often 10–30).
3. **One‑factor sweeps** around the default: money, time, fridge, restock, number of outlets, consumption strategy, MoneySaver share.
4. **Plots**: output vs parameter with mean ± 95 % interval over seeds.

#### 2.3 Write‑up *(1 h)*

One page: the question, the scenario, the 3–4 plots, what changes outcomes (money, time < 30 min, consumption strategy), what does not (fridge, money/time saver).

**Status (`3460a98`)**: [`scenarios.md`](scenarios.md) is a first write‑up of this kind for availability and proximity, with figures.

#### 2.4 Small model additions if time remains

- ~~Store the preference profile name on each household so outputs can be split by profile.~~ **Done**: each household keeps its profile as an object, `foodPreference` (a `FEBFoodPreference` subclass), set by the actions `preferMeatAndDairy`, `preferStapleAndProcessedFood` and `preferBalancedDiet`; outputs can be split by `foodPreference class`.
- Turn `availableMoneyPerStep` into a per‑household value drawn from a distribution (income heterogeneity).
- Make `storageHorizon` (5) and the MoneySaver share (0.5) parameters.

---

## 3. Priority 2 — improve the model (next weeks)

Ordered by expected impact on the research question "how does the food environment shape diets and waste".

### 3.1 Outlets

| Change | Why | Where |
|---|---|---|
| **Outlet types** (supermarket, convenience store, market, discounter) with different assortments, prices and sizes | The core of "food environment"; the unused `healthyFoodInventory` / `conventionalFoodInventory` suggest it was planned | `FEBOutlet`, new subclasses or a type object |
| **Differentiated prices** per category and outlet | All prices are 5: price never drives choice; cheap processed food vs expensive fresh food is a main mechanism in the literature | `FEBOutlet>>initializePrices` |
| **Demand‑driven restock** (replace what was sold, plus a margin) | Random restock makes 30–50 % waste and random shortages | `FEBOutlet>>restock` |
| **FIFO selling or markdowns** for food near expiry | Outlets sell freshest first, maximising their own waste | `FEBOutlet>>take:quantity:` |
| Restock after ageing, or restock before households shop | Today restocked food loses a day before it can be sold | `FEBOutlet>>step`, `FEBModel>>step` |

### 3.2 Households

| Change | Why |
|---|---|
| **Income heterogeneity** and money per person | Core driver (§1) |
| **Savings / weekly budget** instead of a daily budget that is lost | Real households shop weekly and store; today unspent money disappears |
| **Shopping frequency** (e.g. 1–3 trips per week) | Daily shopping is an assumption with strong effects on waste and time |
| **Outlet choice by utility** (distance, price, assortment, habit) rather than nearest first | Allows studying store loyalty and food deserts |
| **Partial knowledge** of outlets (only those within a radius, or visited before) | All households know all outlets |
| **Learning / adaptation**: use `hungerMemory` (exists, unused) to change strategy or preferences; implement `reconsiderPreference` | Gives dynamics beyond the first days |
| **Cooking time / meal preparation** for fresh vs processed food | Explains why time‑poor households buy processed food |
| **Per‑person needs** by age/sex instead of 10 meals, 2000 kcal, 60 g | More realistic adequacy |

### 3.3 Space

- Use a real map: Cormas can load rasters/shapefiles; place outlets from a register of shops (e.g. INSEE *Base permanente des équipements* in France) and households from census grids.
- Make `averageDistanceTo5ClosestOutlets` and `numberOfOutletsWithin30Min` (already written, still unused) **probes and household attributes** — they are standard food‑access metrics. The "Minutes to the first outlet" probe measures the walk to the outlet actually visited first, which is the nearest by construction.
- Walking speed / transport mode per household (car vs walking) as a parameter.
- **Outlets placed in a region** are now possible (`initializeAgentsWithOutletsOn:`), as used by the unequal‑distance and food‑desert scenarios. Households could get the same option, for neighbourhoods with different access.

### 3.4 Indicators

- **Healthy diet**: define per person and per day (e.g. ≥ X portions of fruits & vegetables per person per day), aligned with a recognised guideline, and report a continuous score, not only a boolean.
- Add a **diet diversity score** and the **share of processed food**. *A first diversity measure exists: the number of categories eaten per day (`FEBHousehold>>dietDiversity`, probe "Average diet diversity").*
- Add **economic indicators**: outlet revenue and waste value, household food spending share. *The spending share exists as the probe "Share of budget spent".*

---

## 4. Calibration

### 4.1 What to calibrate (from the code)

| Group | Parameters | Current source |
|---|---|---|
| Households | size distribution, money per person/household, time for shopping, fridge capacity, preference profiles and their shares | invented |
| Food | shelf lives, kcal and protein per portion, prices | partly plausible, prices invented |
| Outlets | number, location, restock amount and composition | invented |
| Behaviour | money/time thresholds, storage horizon, substitution chain, MoneySaver share | invented |

### 4.2 Data sources to look at

*(Check availability for your study area; the external documents are in French, so French sources are listed.)*

- **Household composition and income**: national census and household budget surveys (INSEE *Budget de famille*).
- **Food consumption by profile**: individual dietary surveys (ANSES *INCA 3*); can be clustered into preference profiles replacing A/B/C.
- **Nutrient content**: ANSES *Ciqual* table for kcal and protein per portion of each category.
- **Shelf lives and storage**: food‑safety guidance; household fridge sizes from appliance surveys.
- **Purchases and prices**: consumer panels (e.g. Kantar), retail price statistics.
- **Outlet locations**: INSEE *BPE*, OpenStreetMap.
- **Food waste**: national household and retail waste studies (to use as *validation* patterns, not inputs).

### 4.3 Method

1. **Direct calibration** first: set every parameter that has data (sizes, nutrients, shelf lives, outlet locations).
2. **Pattern‑oriented modelling** for the rest: choose 3–5 patterns the model must reproduce together, e.g.
   - share of household food waste in purchases (order of magnitude),
   - share of food spending in income by income group,
   - share of fruit & vegetables / processed food in the diet by income group,
   - average shopping trips per week and distance to the store used.
3. **Fit** the behavioural parameters (thresholds, storage horizon, restock rule) by grid search or **Approximate Bayesian Computation** on those patterns.
4. Document the result in ODD §1.2 (patterns) and a TRACE document.

---

## 5. Analysis

### 5.1 Verification (partly done)

- The test suite already covers conservation (sold = bought, food only changes hands) and determinism. Add: **"no household eats more than its need"**, **"no outlet sells food in its last day"** at model level, **"money spent never exceeds money available"** over a whole run.
- Add a **long‑run test** (e.g. 200 steps, no errors, inventories stay bounded).

### 5.2 Experimental design

1. **Warm‑up and run length**: discard ≥ 30 steps (staple shelf life); run ≥ 90 steps.
2. **Replicates**: choose by coefficient of variation; report means with confidence intervals.
3. **Global sensitivity**: Morris screening on ~10 parameters (money, time, fridge, restock, number of outlets, storage horizon, thresholds, MoneySaver share, consumption strategy), then Sobol indices on the important ones. Use R (`sensitivity` package) or Python (`SALib`) on the CSV from the batch script.
4. **Scenario experiments** (policy‑relevant):
   - *Food desert*: fewer outlets / clustered outlets far from part of the households. **Done** as `initUnequalDistance` and `initFoodDesert` (`scenarios.md`).
   - *Income shock*: −20 % budget for low‑income households.
   - *Fresh‑food subsidy*: lower price for fruits & vegetables (after 3.1).
   - *Anti‑waste rules*: FIFO and markdowns at outlets, "eat expiring food first" campaign.
   - *Time poverty*: less shopping time for some households.
5. **Heterogeneity analysis**: always split outputs by household size, income, strategy and profile; averages hide the mechanisms (as in §1).

### 5.3 Outputs to report

Satiety, caloric and protein adequacy (distribution, not only means), healthy‑diet share, household waste per person, outlet waste share, money and time spent, distance walked, share of substitutes / leftovers.

---

## 6. Presentation

### 6.1 Documents

- Finish this **ODD** (fill §1 and §4.1) and consider **ODD+D** (Müller et al. 2013), which adds the decision‑making part — the heart of this model.
- Use the diagrams in `img/` (class, schedule, consumption, shopping list, trip) in slides and paper.

### 6.2 Figures

1. **Map** of households coloured by satiety, outlets as icons (the Cormas perspective) — one before/after a scenario. *Examples: Figures 16–20 of `scenarios.md`, the last one with the day's shopping trips (`FEBTrip`) shown.*
2. **Time series** of average indicators with confidence bands (after warm‑up).
3. **Response curves**: satiety and waste vs money; vs shopping time (shows the 30‑min threshold).
4. **Stacked bars** of meal reasons (own share / substitute / leftover / last day) per scenario.
5. **Sankey** of food flows: restocked → sold / spoiled at outlet → eaten / spoiled at home.
6. **Sensitivity bar chart** (Morris μ*, σ or Sobol indices).

### 6.3 Live demo

The household and outlet dashboards are a strong demo: run the big grid for 10 steps, open a hungry 5‑person household, click a purchase to jump to the outlet, show the outlet's waste. Prepare a seed that gives a clear story.

The trips add a second one: in `initFoodDesert`, show `FEBTrip` with the eye in the Aspects panel, then use `highlightTrip` on a far household to show its path alone, in red, to the corner.

---

## 7. What can be learned from the model

Already, with the current code (to be confirmed with replicated runs):

1. **Budget is the first‑order constraint**; spatial access matters only once money is sufficient, and then only when shopping time is short (< ~30 min).
2. **Waste is mostly at outlets** under random, demand‑blind restocking and freshest‑first selling — supply‑side rules may matter more than household behaviour for total waste.
3. **Household eating rules trade waste against diet**: eating expiring food first cuts household waste strongly but changes what people eat.
4. **Fridge capacity has little effect** under daily shopping — it would matter with less frequent shopping.
5. **Money‑saving vs time‑saving strategies hardly matter** as implemented, because thresholds only apply to storage purchases.

The first replicated experiments (`scenarios.md`: 10 seeds, 90 steps, budget 200, 2 h) add:

6. **Availability matters strongly**: supply at 0.68 × demand lowers satiety from 0.91 to 0.68 and diversity by about one category; at 2.3 × demand, satiety only rises to 0.96, while household waste doubles.
7. **Spatial access matters only when outlets are concentrated**: more outlets for the same supply fragments stock without improving diets; with outlets in one half or one corner, distance becomes the main source of inequality (r ≈ −0.6), and the farthest households reach a satiety of 0.67.
8. **Household size still dominates** at a budget of 200 per household: 5‑person households are hungry even with abundant supply — which confirms point 1 and item 1.1.

After the Priority‑2 changes, the model could address: food deserts and swamps, effects of price policies on diet quality, the link between time poverty and processed food, and the relative contribution of households and retailers to food waste.

---

## 8. Code‑level checklist

| # | Item | Location | Priority | Status (`3460a98`) |
|---|---|---|---|---|
| 1 | Money per person | `FEBHousehold>>initialize` | P1 | open |
| 2 | Stop trip without money; count return | `FEBSimpleShoppingStrategy>>shopFor:using:`, `can:travelFor:with:` | P1 | open |
| 3 | Uniform sizes | `FEBHousehold>>initialize` | P1 | open |
| 4 | Inits must not overwrite parameters | `FEBModel>>initUnconstraintedScenario` | P1 | partly: `initCustomizable` fixed, scenario inits set every parameter |
| 5 | New probes | `FEBModel` | P1 | partly: 7 added (§1.5) |
| 6 | Rename strategies | strategy classes, parameter values | P1 | open |
| 7 | Remove or document dead state | `FEBModel`, `FEBOutlet`, `FEBCell`, `FEBHousehold` (also `shapeOfPovBasedOnStrategy`) | P1 | documented in `odd.md` Appendix C |
| 8 | `hasFoodForOneDay` should ignore last‑day food (consistency) | `FEBHousehold>>hasFoodForOneDay` | P2 | open |
| 9 | Fridge substitution should include essential perishables | `substitutePerishableFoodThatWontFitInFridge:` | P2 | open |
| 10 | Strategies given to `self households`, not `self agents` | `FEBModel>>initializeStrategies` | P2 | open |
| 11 | Profile name on households | `FEBModel>>initializePreferences` | P1–P2 | **done** (`foodPreference`) |
| 12 | Consumption strategy per household | `FEBHousehold class>>consumptionStrategy` | P2 | open |
| 13 | Prices, outlet types, restock rule, FIFO | `FEBOutlet` | P2 | open |
| 14 | Parameterise 10 meals, 2000 kcal, 60 g, 5‑day horizon, 5 min/cell | various | P2 | open |
| 15 | A household must be creatable without food categories, or tests must create them first: the default preference in `initialize` makes 16 tests of `FEBHouseholdConsumptionTest` fail | `FEBHousehold>>initialize`, `FEBHouseholdConsumptionTest>>setUp` | P1 | **new** |
| 16 | Stockouts per food category, not only in total | `FEBModel>>countStockouts` | P2 | **new** |
