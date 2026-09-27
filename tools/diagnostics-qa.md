# Diagnostics first-build QA

Scope: seven-category Flutter hub and 19 initial lab-reference cards. EKG is excluded from navigation and search keywords at Nicole's request. Prior EKG files remain unused. This is not the full Base44 migration or a clinical release.

## Coverage

- Hub: all seven categories; no EKG; desktop and 375-pixel mobile layout.
- Search: type to filter, multiword matching, clear and restore, unknown query, EKG query gives no diagnostic category.
- Labs: route opens, 19 cards, three groups, alias search, expansion/collapse, bulleted content, direct interval and interpretation sources.
- Sources: invoke actual source button and confirm destination URL; failure handler provides the URL instead of failing silently.
- Navigation: back from lab and unfinished category; Home returns to main tile dashboard.
- Release guard: default LabValuesScreen does not display clinical draft; preview explicitly opts in.
- Off-happy paths: no-result query, filters producing no results, long labels at narrow width.
- Visual pass: desktop hub, mobile hub, expanded lab card; verify no horizontal clipping and legible cream/navy styling.

## Boundaries

- No production Supabase mutation, subscription change, GitHub push, or clinical signoff.
- Initial labs use MedlinePlus example reference intervals. They are not institutional critical limits or perioperative treatment thresholds.
- Dedicated platelet page is used for platelet units; the general CBC page has an inconsistent platelet unit.
- ABG, PFT, Echo/TEE, imaging, POCUS and carotid content are explicitly in preparation.
- Next content work: anesthesia-facing lab interpretation, coagulation, blood gases and specialized tests, then the remaining Base44 diagnostic content.
