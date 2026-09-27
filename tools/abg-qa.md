# ABG & Acid–Base preview QA

## Scope and boundaries

- Fourteen adult reference cards, grouped into Foundations, Primary disorders, Mixed disorders, Perioperative and Teaching cases.
- Four-pattern compensation panel, including acute versus chronic respiratory responses.
- Bullets and section-level direct source buttons; seven fetched clinical references.
- No patient-specific interpreter, ventilator settings, medication calculator or automatic diagnosis.
- No production Supabase changes, GitHub push, clinical approval, access-rule changes or purchase activation.
- Default app does not expose draft ABG content. The existing review-preview entry point opts in.

## QA inventory

- Hub: ABG opens the new section; its count is accurate; EKG remains excluded.
- Quick-reference panel: open and close; all four patterns and source buttons render.
- Search: incremental updates; aliases and Unicode-compatible matching; clear and restore.
- Group filters: selection and reset; combined search plus group produces the correct subset.
- Empty state: incompatible query/filter shows no-results message and usable reset.
- Cards: expand/collapse, bullet wrapping, source action and retained expansion after filtering.
- Source action: click a rendered source button and confirm exact destination.
- Navigation: back to Diagnostics; Home returns to the main tile dashboard.
- Mobile: 375 × 812, wrapped filters and long source labels, expanded clinical text without horizontal clipping.
- Desktop: 1280 × 900, readable reference column and visible search/quick-access controls.
- Exploratory: change filters with a card expanded, clear an unmatched query, open/close the quick panel after scrolling.
- Guard: default screen shows in-preparation notice and no clinical content.
- Teaching examples: confirm arithmetic and approximate Henderson–Hasselbalch consistency; explicitly synthetic.

## Automated checks completed

- Twenty-two targeted Flutter tests passed, including six new ABG tests.
- Static analysis of Diagnostics and both clinical-reference test files: no issues.
- Compensation constants are reused between the quick-reference panel and full topics to prevent divergence.
- Release-mode Flutter web build completed successfully.
- Synthetic case arithmetic checked independently: Winter ranges 22.5–26.5, 24–28 and 33–37 mmHg; rounded pH values 7.25, 7.40 and 7.10 are internally consistent.

## Rendered verification completed

- Desktop 1280 × 900 and mobile 375 × 812 screenshots reviewed: readable cream/navy styling, wrapped filters, bullet text and long source labels without horizontal clipping.
- Hub opens ABG; 14-card count verified; quick panel opens and closes.
- Primary disorders + Winter returns one metabolic acidosis card; the card expands.
- EtCO2 alias returns the capnography card; clear restores the list.
- Unmatched query plus filter produces an empty state; reset restores all 14 references.
- Expanded card/filter transitions and reopening the quick panel did not cause restoration errors.
- Clicked the rendered Merck compensation button and confirmed the exact destination URL.
- Back returned to Diagnostics; Home returned to the dashboard route.
- No browser page errors observed. The browser QA session was closed.
- The app's existing single cream/navy theme was preserved; no new dark-mode implementation was introduced.

## Clinical evidence

- Merck Manual acid–base disorders: https://www.merckmanuals.com/professional/nephrology/acid-base-regulation-and-disorders/acid-base-disorders
- Merck compensation table: https://www.merckmanuals.com/professional/multimedia/table/primary-changes-and-compensations-in-simple-acid-base-disorders
- Adult arterial/venous gas review (2025): https://pmc.ncbi.nlm.nih.gov/articles/PMC12387505/
- Preanalytical sampling review: https://pmc.ncbi.nlm.nih.gov/articles/PMC3900096/
- Blood gas context: https://medlineplus.gov/ency/article/003855.htm
- Capnography physiology: https://www.openanesthesia.org/wp-content/uploads/2024/10/08/ICU_one_pager_end_tidal_co2_v11.pdf
- Peri-intubation physiology: https://pmc.ncbi.nlm.nih.gov/articles/PMC4703154/

Only the relevant physiology and limitations were used from the older reviews. This does not assert that all recommendations in those articles remain current. Source checking and software testing do not constitute clinical signoff.
