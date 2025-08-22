System / High-Level Prompt

You are an expert iOS engineer and product designer. Build an offline-first iOS app (Swift + SwiftUI) for PerkPoint: Amenity Machines to evaluate potential locations for amenity/vending machines. The app replaces a spreadsheet-based workflow and must compute the same metrics, scores, and decisions.

Goals
	•	Let users create and manage Locations (one record per site: apartment tower, office, hospital, school, townhomes).
	•	Gather inputs across structured sections and auto-calculate profitability and a weighted score.
	•	Show a one-page Overview with traffic-light Decision (Greenlight / Watchlist / Pass).
	•	Work 100% offline, with local persistence and export/import (CSV and PDF). No login or backend for v1.

Platform & Stack
	•	iOS 16+; SwiftUI UI; SwiftData or GRDB + SQLite for persistence (choose one and justify).
	•	Dependency-light. Add only what’s needed for PDF export and CSV import/export.
	•	Architecture: MVVM. Unit tests with XCTest.

Core Entities & Data Model

Location
	•	id (UUID), name (String), address (String)
	•	module (enum: office, hospital, school, residential)
	•	timestamps: createdAt, updatedAt
	•	relations: generalMetrics, moduleDetails, financials, scorecard (computed), photos [0..*]

GeneralMetrics
	•	footTrafficDaily (Int)  // single source of truth
	•	targetDemographicFit (String or enum), nearbyCompetition (String), hostCommissionPct (Double 0–1), visibilityNotes, parkingTransitNotes, securityNotes, amenitiesNotes

ModuleDetails (tagged union by module)
	•	Office: commonAreasAvailable (Bool/String), buildingHours (String), tenantAmenities (String), proximityToHub (String), brandingRestrictions (String), layoutType (enum: single, multi)
	•	Hospital: healthSafetyCompliance (String), distanceToPatientAreasMeters (Int), vendingZonesAvailable (Bool), fmCoordination (String), sanitationExtras (String)
	•	School: placementHotspots (String), scheduleAlignment (String), productMixNotes (String), adminApprovalStatus (String), studentSafetyNotes (String)
	•	Residential: totalUnits (Int), occupancyRatePct (Double), demographic18to45Pct (Double), avgLeaseMonths (Int), amenityUsageRatePct (Double), access24x7 (Bool), installVisibility (String), powerConnectivityNotes (String), servicePathNotes (String), securityMeasures (String), onsiteAlternatives (String), walkTimeToStoreMin (Int), hoaRules (String), commissionOrAmenityFee (String), eventsPerYear (Int)

Financials
	•	avgVendPrice (Double, default 3.00)
	•	expectedTxPerDay (Int)           // can be derived from capture % but is user-entered
	•	daysOpenPerMonth (Int, default 30)
	•	cogsPerVend (Double, default 1.20)
	•	varOpPerVend (Double, default 0.20)
	•	routeCostPerVisit (Double, default 15.00)
	•	routeVisitsPerMonth (Int)
	•	hostCommissionPct (Double 0–1)

Derived / Computations (immutable view model properties)
	•	grossMonthly = avgVendPrice * expectedTxPerDay * daysOpenPerMonth
	•	productCostsMonthly = (cogsPerVend + varOpPerVend) * expectedTxPerDay * daysOpenPerMonth
	•	routeCostsMonthly = routeCostPerVisit * routeVisitsPerMonth
	•	commissionMonthly = hostCommissionPct * grossMonthly
	•	netMonthly = grossMonthly − productCostsMonthly − routeCostsMonthly − commissionMonthly

Scorecard (computed + partially user-scored)
	•	Dimensions with weights:
	•	footTrafficAndDwell (0.20) → auto-scored from General.footTrafficDaily:
	•	scoreFootTraffic = 5 if ≥1000, 4 if 600–999, 3 if 300–599, 2 if 150–299, 1 if 1–149, else blank.
	•	demographicFit (0.10) → manual 1–5
	•	competitiveGap (0.10) → manual 1–5
	•	logisticsInfrastructure (0.15) → manual 1–5
	•	moduleSpecificFactors (0.25) → average of selected ModuleDetails “Your Value” items (map fields to 1–5 sliders)
	•	financialTermsAndROI (0.20) → manual 1–5 or derived from netMonthly vs. threshold (see below; implement as manual with helper suggestion)
	•	weightedTotal = Σ(weight * score)/Σ(weights) (normalize to 0–1 or keep 0–5 and divide by 5—choose one and keep consistent)
	•	Decision:
	•	Greenlight if weightedTotal ≥ 0.75
	•	Watchlist if 0.60–0.74
	•	Pass if < 0.60

UX Flows

1) Create Location
	•	Screen: “New Location” → fields: Name, Address (Apple Maps lookup optional), Module selector.
	•	After save, navigate to a tabbed detail view: Overview | General | Module | Financials | Scorecard | Photos.

2) General
	•	Form with helper text and examples.
	•	Foot Traffic is numeric; show a helper button “How to count” with quick tips.

3) Module
	•	Render fields specific to chosen module.
	•	Use segmented controls, toggles, and 1–5 sliders for “Your Value” metrics when they represent quality; text fields where appropriate.

4) Financials
	•	Inputs on top; Calculated section below showing Gross, Net (read-only).
	•	Inline validation: percentages as 0–100 shown, but stored 0–1.

5) Scorecard
	•	Auto-populate Foot Traffic score (read-only).
	•	1–5 pickers for other dimensions with inline tooltips.
	•	Show the weighted breakdown and the final score bar.

6) Overview
	•	One-pager with: Module, Foot Traffic (raw), Weighted Score, Net $/mo, Decision badge (green/yellow/red).
	•	Buttons: Export PDF, Export CSV, Duplicate Location.

7) Photos
	•	Add photos (camera or library) for install zone, power outlet, loading path. Store locally.

CSV / PDF
	•	CSV Export: one file per Location with sections flattened. Column names prefixed: general.footTrafficDaily, financials.avgVendPrice, etc.
	•	CSV Import: allow importing a single location CSV to prefill a new Location.
	•	PDF Export: render the Overview plus key tables (General highlights, Module highlights, Financials summary, Scorecard breakdown). Fit on one A4/Letter page with PerkPoint header.

Validation Rules
	•	Percent inputs accept 0–100 in UI, convert to 0–1 internally.
	•	Required: name, module, footTrafficDaily, expectedTxPerDay, routeVisitsPerMonth.
	•	Numbers must be ≥ 0; show inline errors beneath fields.

Seeding & Hints
	•	Provide a “Create Sample Location” action that fills realistic dummy data for each module to demo calculations.
	•	In Scorecard, show a non-blocking hint “Given your Net $/mo (netMonthly), we suggest Financial terms score of X” where X maps to tiers (e.g., ≥$250 → 5, $150–249 → 4, $75–149 → 3, $1–74 → 2, ≤$0 → 1). User can override.

Accessibility & Polish
	•	Dynamic Type support.
	•	Labels + helper text for every field.
	•	Color choices must meet WCAG AA; Decision colors also include text labels.
	•	Haptics on save/export.

Non-Functional
	•	Offline-first; all data stored locally.
	•	No tracking, no analytics, no network calls.
	•	Launch time < 1.5s on iPhone 12-class hardware.

Deliverables
	1.	Xcode project with SwiftUI views, models, and persistence layer.
	2.	Unit tests for:
	•	financial calculations
	•	score calculation and decision thresholds
	•	CSV round-trip (export then import equals original)
	3.	UI tests for:
	•	create new location → overview updates correctly
	•	module switch updates module section and score
	•	PDF export produces a non-empty file
	4.	README with:
	•	data model diagram
	•	how to run, build, and test
	•	CSV column spec
	•	mapping from spreadsheet sheets to app sections

Acceptance Tests (must pass)
	•	Enter: avgVendPrice=3.0, expectedTxPerDay=25, days=30, cogs=1.2, varOp=0.2, routeCostPerVisit=15, visits=6, commission=0.10 →
gross=32530=2250; productCosts=(1.2+0.2)2530=1050; route=156=90; commission=0.12250=225; net=2250−1050−90−225=885.
The Overview shows Net $/mo ≈ $885.00.
	•	With footTrafficDaily=650 → scoreFootTraffic=4.
If other dimension scores are (4,4,4,4,4) with weights (0.20,0.10,0.10,0.15,0.25,0.20), weightedTotal ≥ 0.75 and Decision shows Greenlight.
	•	Switching module from Office to Residential changes the Module screen fields and recomputes moduleSpecificFactors average.

Nice-to-Have (if time allows)
	•	Quick calc for capture rate (Tx/day ≈ footTrafficDaily × capture%) with presets by module (Office 1–3%, Residential 3–6%, Hospital 4–7%).
	•	MapKit pin for address with walking-distance helper to nearest convenience store (manual entry for v1; true search deferred).
