# Diagnostics lab-expansion QA

Scope: seven-category Flutter hub and 30 adult lab-reference cards. All 19 initial cards now have source-linked interpretation sections; 11 new cards cover coagulation, additional electrolytes, lactate, and troponin. EKG remains excluded from navigation and hub search. Prior EKG files remain unused. This is not the full Base44 migration or a clinical release.

## Coverage

- Hub: all seven categories; no EKG; desktop and 375-pixel mobile layout.
- Search: type to filter, multiword matching, clear and restore, unknown query, EKG query gives no diagnostic category.
- Labs: route opens, 30 cards, five groups, alias and clinical-text search, expansion/collapse, bulleted content, direct interval and section-specific sources.
- Filters: six coagulation cards; combined Coagulation + Urgent findings shows fibrinogen; incompatible search gives an honest empty state; All restores other matching groups.
- Content structure: reference intervals are separate from clinical thresholds; five assay/context-only cards do not invent universal normal ranges.
- Every card has at least one clinical section with a nonempty source label and HTTPS URL. Guidance keys and card IDs match.
- Sources: fetched the guideline/reference content for the added clinical sections. The rendered ASRA source button was clicked and its exact PDF destination confirmed. Failure handler provides the URL instead of failing silently. This is not a claim that every external site will always load on every user's network.
- Navigation: back from lab and unfinished category; Home returns to main tile dashboard.
- Release guard: default LabValuesScreen does not display clinical draft; preview explicitly opts in.
- Off-happy paths: no-result query, filters producing no results, long labels at narrow width.
- Visual pass: desktop hub, mobile hub, expanded lab card; verify no horizontal clipping and legible cream/navy styling.

## Boundaries

- No production Supabase mutation, subscription change, GitHub push, or clinical signoff.
- Example intervals primarily use MedlinePlus; lab-specific intervals always take precedence. Critical-context sections are selected cautions, not an exhaustive institutional panic-value list or a patient-specific decision engine.
- SOAP's platelet threshold is limited to its specified obstetric context. ASRA warfarin needle-placement requirements are distinguished from catheter-removal guidance. PT/aPTT do not establish absence of DOAC effect.
- AABB thresholds are limited to stable adult populations; no automatic transfusion trigger or fixed hematocrit target is supplied. No replacement-dose calculator was added.
- Lactate guidance uses the retrieved 2026 Surviving Sepsis Campaign update, not the older 2021 recommendation.
- Dedicated platelet page is used for platelet units; the general CBC page has an inconsistent platelet unit.
- ABG, PFT, Echo/TEE, imaging, POCUS and carotid content are explicitly in preparation.
- Next content work: ABG & Acid–Base, then the remaining diagnostic categories.

## Verification results

- 16 targeted Flutter tests passed across diagnostics, home search, and home navigation.
- After formatting fixes, diagnostics tests passed again (7 tests).
- Static analysis of the modified diagnostics sources and test file: no issues.
- Release-mode Flutter web build completed.
- Desktop 1280 × 900: hub and lab screen, search for warfarin, expanded PT/INR, ASRA source button.
- Mobile 375 × 812: combined filters, expanded fibrinogen, readable bullet sections and wrapped source buttons without horizontal clipping.
- No browser page errors observed during the rendered checks.
- No production Supabase writes, GitHub push, or clinical signoff performed.
