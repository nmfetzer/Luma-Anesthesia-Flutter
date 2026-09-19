# Luma Anesthesia — Drug Library Audit
Generated 2026-09-19 · 791 total drugs

## Summary

| Metric | Value |
|---|---|
| Total drugs | 791 |
| Categories in use | 25 |
| Categories from canonical 32 not populated | 12 |
| Categories in use but not in canonical 32 | 5 |
| Duplicate groups (Type A — same category, near-identical) | 23 |
| Duplicate groups (Type B — cross-listed in multiple categories) | 36 |
| Drugs missing peds dose | 0 |
| Drugs missing sources | 0 |
| Drugs missing deep dive | 0 |

## 1. Field-Level Completeness

How many drugs have each field populated. 100% means every drug has it.

| Field | Filled | Empty | % |
|---|---:|---:|---:|
| `brand_name` | 791 | 0 | 100% |
| `class_short` | 789 | 2 | 100% |
| `classification` | 791 | 0 | 100% |
| `indications` | 791 | 0 | 100% |
| `mechanism` | 791 | 0 | 100% |
| `adult_dose` | 791 | 0 | 100% |
| `peds_dose` | 791 | 0 | 100% |
| `onset_duration` | 791 | 0 | 100% |
| `contraindications` | 791 | 0 | 100% |
| `side_effects` | 791 | 0 | 100% |
| `serious_effects` | 791 | 0 | 100% |
| `drug_interactions` | 791 | 0 | 100% |
| `administration_details` | 791 | 0 | 100% |
| `special_populations` | 791 | 0 | 100% |
| `pregnancy_lactation` | 791 | 0 | 100% |
| `warnings_precautions` | 791 | 0 | 100% |
| `pharmacokinetics` | 791 | 0 | 100% |
| `antidote_reversal` | 791 | 0 | 100% |
| `deep_dive_content` | 791 | 0 | 100% |
| `sources` | 791 | 0 | 100% |
| `dea_schedule` | 791 | 0 | 100% |
| `last_reviewed` | 791 | 0 | 100% |
| `clinical_reviewer` | 791 | 0 | 100% |
| `review_cycle_months` | 791 | 0 | 100% |
| `lasa_warning` | 773 | 18 | 98% |
| `duration_minutes` | 770 | 21 | 97% |
| `black_box_warning` | 767 | 24 | 97% |
| `onset_minutes` | 743 | 48 | 94% |
| `clinical_pearls` | 617 | 174 | 78% |
| `notes` | 492 | 299 | 62% |
| `special_considerations` | 461 | 330 | 58% |
| `monitoring_parameters` | 461 | 330 | 58% |
| `high_alert` | 368 | 423 | 47% |
| `dose_unit` | 289 | 502 | 37% |
| `is_infusion` | 67 | 724 | 8% |
| `dose_mg_per_kg_min` | 41 | 750 | 5% |
| `requires_dilution` | 29 | 762 | 4% |
| `dosage_forms` | 27 | 764 | 3% |
| `routes` | 27 | 764 | 3% |
| `interactions_critical` | 26 | 765 | 3% |
| `target_concentration` | 17 | 774 | 2% |
| `standard_recipe` | 17 | 774 | 2% |
| `diluent` | 17 | 774 | 2% |
| `stability_hours_room_temp` | 0 | 791 | 0% |
| `mixing_pearls` | 0 | 791 | 0% |

## 2. Category Organization

### Current categories (25)

| # | Category | Drug count | Status |
|---|---|---:|---|
| 1 | Pre-op Medication Considerations | 98 | ✅ canonical |
| 2 | Anticoagulation & Blood Products | 64 | ✅ canonical |
| 3 | Analgesics & Pain Control | 63 | ✅ canonical |
| 4 | Psychiatric Medications | 54 | ✅ canonical |
| 5 | Cardiac & Hemodynamics | 52 | ✅ canonical |
| 6 | Endocrine & Metabolic | 48 | ✅ canonical |
| 7 | Respiratory Medications | 48 | ✅ canonical |
| 8 | Antibiotics & Antimicrobials | 44 | ✅ canonical |
| 9 | Emergency & Reversal | 43 | ⚠️ not in canonical 32 |
| 10 | Neurologic | 40 | ✅ canonical |
| 11 | Antineoplastics / Chemotherapy | 32 | ✅ canonical |
| 12 | Antiemetics & GI | 29 | ✅ canonical |
| 13 | Diagnostics, Dyes & Contrast | 28 | ✅ canonical |
| 14 | OB & Women's Health | 20 | ✅ canonical |
| 15 | Crisis Management | 19 | ⚠️ not in canonical 32 |
| 16 | Pediatric Anesthesia | 16 | ⚠️ not in canonical 32 |
| 17 | Electrolytes & Fluids | 15 | ✅ canonical |
| 18 | Anesthetics — IV Induction | 13 | ⚠️ not in canonical 32 |
| 19 | Airway & Respiratory | 12 | ✅ canonical |
| 20 | Immunosuppressants & Transplant Medications | 12 | ✅ canonical |
| 21 | Sedatives & Hypnotics | 11 | ✅ canonical |
| 22 | Anesthetics — Local | 8 | ✅ canonical |
| 23 | Local & Regional Anesthesia | 8 | ✅ canonical |
| 24 | Anesthetics — Inhalational | 7 | ✅ canonical |
| 25 | Neuromuscular Blockade & Reversal | 7 | ⚠️ not in canonical 32 |

### Categories in use but NOT in your canonical 32-category schema

These live in the database but don't match your Base44 schema's allowed list. Likely need renaming to a canonical value.

| Non-canonical category in use | Count | Suggested canonical target |
|---|---:|---|
| Anesthetics — IV Induction | 13 | Induction & Hypnotics |
| Crisis Management | 19 | ICU / Critical Care or Emergency & Code Drugs |
| Emergency & Reversal | 43 | Emergency & Code Drugs or Reversal & Antidotes (split) |
| Neuromuscular Blockade & Reversal | 7 | Neuromuscular Blockade |
| Pediatric Anesthesia | 16 | Pediatrics |

### Canonical categories with zero drugs assigned

These are valid categories in your schema but currently empty. May be intentional or drugs may be mis-categorized.

- Cardiac Anesthesia
- Emergency & Code Drugs
- Genitourinary & Renal
- Hematology & Oncology
- ICU / Critical Care
- Induction & Hypnotics
- Migraine & Headache
- Neuroanesthesia
- Neuromuscular Blockade
- Obstetric Anesthesia
- Pediatrics
- Reversal & Antidotes

## 3. Duplicates (59 groups)

### Type A — Near-identical duplicates in the same category (23 groups)

These look like accidental re-adds with slightly different names. Recommended: keep the more complete version, delete the other.

| Normalized name | Count | Drugs | Category | Completeness |
|---|---:|---|---|---:|
| **racemic epinephrine** | 2 | Racemic Epinephrine | Airway & Respiratory | 33/44 |
|  |  | Racemic Epinephrine (Nebulized) — Post-Extubation Stridor / Croup | Airway & Respiratory | 35/44 |
| **sevoflurane** | 2 | Sevoflurane (Ultane / Sojourn) | Anesthetics — Inhalational | 33/44 |
|  |  | Sevoflurane (Ultane) | Anesthetics — Inhalational | 37/44 |
| **dexmedetomidine** | 2 | Dexmedetomidine (Low-Dose IV Bolus — 4–50 mcg) | Anesthetics — IV Induction | 33/44 |
|  |  | Dexmedetomidine (Precedex — ICU Sedation) | Anesthetics — IV Induction | 34/44 |
| **azathioprine** | 2 | Azathioprine | Immunosuppressants & Transplant Medications | 29/44 |
|  |  | Azathioprine (Imuran) — Purine Synthesis Inhibitor | Immunosuppressants & Transplant Medications | 36/44 |
| **cyclosporine** | 2 | Cyclosporine | Immunosuppressants & Transplant Medications | 29/44 |
|  |  | Cyclosporine (Neoral, Sandimmune, Gengraf) — Transplant Calcineurin Inhibitor | Immunosuppressants & Transplant Medications | 37/44 |
| **mycophenolate mofetil** | 2 | Mycophenolate Mofetil | Immunosuppressants & Transplant Medications | 29/44 |
|  |  | Mycophenolate Mofetil (CellCept, Myfortic) — Antimetabolite Immunosuppressant | Immunosuppressants & Transplant Medications | 37/44 |
| **tacrolimus** | 2 | Tacrolimus | Immunosuppressants & Transplant Medications | 29/44 |
|  |  | Tacrolimus (Prograf) — Transplant Calcineurin Inhibitor | Immunosuppressants & Transplant Medications | 37/44 |
| **carboprost** | 2 | Carboprost (Hemabate; 15-methyl PGF2α) — Postpartum Hemorrhage | OB & Women's Health | 34/44 |
|  |  | Carboprost (Hemabate) | OB & Women's Health | 29/44 |
| **methylergonovine** | 2 | Methylergonovine | OB & Women's Health | 29/44 |
|  |  | Methylergonovine (Methergine) — Postpartum Hemorrhage | OB & Women's Health | 34/44 |
| **misoprostol** | 2 | Misoprostol | OB & Women's Health | 29/44 |
|  |  | Misoprostol (Cytotec) — Obstetric Use | OB & Women's Health | 33/44 |
| **terbutaline** | 2 | Terbutaline (Brethine) — Obstetric Tocolysis | OB & Women's Health | 33/44 |
|  |  | Terbutaline (Tocolytic) | OB & Women's Health | 29/44 |
| **ace inhibitors** | 2 | ACE Inhibitors — Class (lisinopril, enalapril, ramipril, benazepril) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | ACE Inhibitors (lisinopril, enalapril, ramipril) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **beta blockers** | 2 | Beta Blockers (chronic) — Class (metoprolol, atenolol, carvedilol, bisoprolol, propranolol) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | Beta Blockers (metoprolol, atenolol, carvedilol, bisoprolol) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **calcium channel blockers** | 2 | Calcium Channel Blockers — Class (amlodipine, diltiazem, verapamil, nifedipine) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | Calcium Channel Blockers (amlodipine, diltiazem, verapamil) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **diuretics** | 2 | Diuretics — Class (furosemide, HCTZ, spironolactone, torsemide) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | Diuretics (furosemide, HCTZ, spironolactone) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **dpp4 inhibitors** | 2 | DPP-4 Inhibitors — Class (sitagliptin, linagliptin, saxagliptin, alogliptin) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | DPP-4 Inhibitors (sitagliptin, linagliptin, saxagliptin) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **enoxaparin lmwh** | 2 | Enoxaparin / LMWH (therapeutic dose) — Perioperative Management | Pre-op Medication Considerations | 34/44 |
|  |  | Enoxaparin / LMWH (therapeutic) — Perioperative Management | Pre-op Medication Considerations | 37/44 |
| **nitrates** | 2 | Nitrates (isosorbide mononitrate / dinitrate, nitroglycerin) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | Nitrates (isosorbide, nitroglycerin) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **pcsk9 inhibitors** | 2 | PCSK9 Inhibitors (evolocumab, alirocumab, inclisiran) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | PCSK9 Inhibitors (evolocumab, alirocumab) — Perioperative Management | Pre-op Medication Considerations | 32/44 |
| **sglt2 inhibitors** | 2 | SGLT-2 Inhibitors — Class (empagliflozin, dapagliflozin, canagliflozin, ertugliflozin) — Perioperative Management | Pre-op Medication Considerations | 34/44 |
|  |  | SGLT-2 Inhibitors (empagliflozin, dapagliflozin, canagliflozin) — Perioperative Management | Pre-op Medication Considerations | 34/44 |
| **statins** | 2 | Statins — Class (atorvastatin, rosuvastatin, simvastatin, pravastatin) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
|  |  | Statins (atorvastatin, rosuvastatin, simvastatin) — Perioperative Management | Pre-op Medication Considerations | 33/44 |
| **sulfonylureas** | 2 | Sulfonylureas — Class (glipizide, glyburide, glimepiride) — Perioperative Management | Pre-op Medication Considerations | 34/44 |
|  |  | Sulfonylureas (glipizide, glyburide, glimepiride) — Perioperative Management | Pre-op Medication Considerations | 34/44 |
| **unfractionated heparin** | 2 | Unfractionated Heparin (SubQ prophylaxis / IV therapeutic) — Perioperative Management | Pre-op Medication Considerations | 36/44 |
|  |  | Unfractionated Heparin (SubQ prophylaxis) — Perioperative Management | Pre-op Medication Considerations | 34/44 |

### Type B — Same drug cross-listed in multiple categories (36 groups)

These may be intentional (same drug used for different clinical purposes). Decision: keep as separate records, or consolidate into one with `secondary_categories`?

| Drug | Categories | Records | Completeness |
|---|---|---:|---|
| Albuterol | Airway & Respiratory, Respiratory Medications | 2 | 35/44 · 30/44 |
| Heliox | Airway & Respiratory, Respiratory Medications | 2 | 33/44 · 29/44 |
| Inhaled Nitric Oxide | Airway & Respiratory, Respiratory Medications | 2 | 34/44 · 30/44 |
| Aspirin | Analgesics & Pain Control, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 33/44 · 34/44 · 34/44 |
| Buprenorphine | Analgesics & Pain Control, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 34/44 · 34/44 · 35/44 |
| Clonidine | Analgesics & Pain Control, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 33/44 · 33/44 · 33/44 |
| Indomethacin | Analgesics & Pain Control, OB & Women's Health | 2 | 32/44 · 33/44 |
| Methadone | Analgesics & Pain Control, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 34/44 · 35/44 · 34/44 |
| Lidocaine | Anesthetics — Local, Cardiac & Hemodynamics | 2 | 34/44 · 32/44 |
| Cilostazol | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 33/44 · 34/44 |
| Clopidogrel | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 31/44 · 34/44 |
| Dabigatran | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 32/44 · 34/44 |
| Dipyridamole | Anticoagulation & Blood Products, Diagnostics, Dyes & Contrast | 2 | 33/44 · 33/44 |
| Edoxaban | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 32/44 · 34/44 |
| Fondaparinux | Anticoagulation & Blood Products, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 32/44 · 36/44 · 34/44 |
| Prasugrel | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 33/44 · 34/44 |
| Rivaroxaban | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 32/44 · 34/44 |
| Ticagrelor | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 31/44 · 34/44 |
| Warfarin | Anticoagulation & Blood Products, Pre-op Medication Considerations | 2 | 31/44 · 34/44 |
| Amiodarone | Cardiac & Hemodynamics, Pre-op Medication Considerations | 2 | 38/44 · 34/44 |
| Digoxin | Cardiac & Hemodynamics, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 31/44 · 34/44 · 34/44 |
| Diphenhydramine | Crisis Management, Emergency & Reversal, Neurologic, Respiratory Medications | 4 | 32/44 · 34/44 · 29/44 · 34/44 |
| Cosyntropin | Diagnostics, Dyes & Contrast, Endocrine & Metabolic | 2 | 32/44 · 29/44 |
| Hydrocortisone | Diagnostics, Dyes & Contrast, Respiratory Medications | 2 | 32/44 · 31/44 |
| Methylene Blue | Diagnostics, Dyes & Contrast, Emergency & Reversal | 2 | 33/44 · 35/44 |
| Methylprednisolone | Diagnostics, Dyes & Contrast, Endocrine & Metabolic | 2 | 32/44 · 29/44 |
| Magnesium Sulfate | Electrolytes & Fluids, OB & Women's Health | 2 | 34/44 · 36/44 |
| Betamethasone | Endocrine & Metabolic, OB & Women's Health | 2 | 29/44 · 33/44 |
| Denosumab | Endocrine & Metabolic, Pre-op Medication Considerations | 2 | 29/44 · 32/44 |
| Levothyroxine | Endocrine & Metabolic, Pre-op Medication Considerations | 2 | 28/44 · 33/44 |
| Metformin | Endocrine & Metabolic, Pre-op Medication Considerations | 2 | 28/44 · 33/44 |
| Oxytocin | Endocrine & Metabolic, OB & Women's Health | 2 | 30/44 · 36/44 |
| Hydralazine | OB & Women's Health, Pre-op Medication Considerations, Pre-op Medication Considerations | 3 | 30/44 · 33/44 · 32/44 |
| Methotrexate | OB & Women's Health, Pre-op Medication Considerations | 2 | 29/44 · 32/44 |
| Insulin | Pediatric Anesthesia, Pre-op Medication Considerations, Pre-op Medication Considerations, Pre-op Medication Considerations | 4 | 30/44 · 27/44 · 37/44 · 34/44 |
| Lithium — Perioperative Management | Pre-op Medication Considerations, Psychiatric Medications | 2 | 33/44 · 30/44 |

## 4. Thinnest Drugs (lowest completeness scores)

Top 30 drugs with the fewest fields populated. Note: minimum is quite high already — the "thinnest" still has 20+ fields.

| Drug | Category | Score |
|---|---|---:|
| Spironolactone | Cardiac & Hemodynamics | 27/44 |
| Total Parenteral Nutrition Compatibility | Electrolytes & Fluids | 27/44 |
| Empagliflozin (Jardiance) | Endocrine & Metabolic | 27/44 |
| Methimazole (Tapazole) | Endocrine & Metabolic | 27/44 |
| Propylthiouracil (PTU) | Endocrine & Metabolic | 27/44 |
| Donepezil (Aricept) | Neurologic | 27/44 |
| Lacosamide (Vimpat) | Neurologic | 27/44 |
| Memantine (Namenda) | Neurologic | 27/44 |
| Phenytoin / Fosphenytoin IV Compatibility | Neurologic | 27/44 |
| Rho(D) Immune Globulin (RhoGAM) | OB & Women's Health | 27/44 |
| Palivizumab (Synagis) — RSV Prophylaxis | Pediatric Anesthesia | 27/44 |
| GLP-1 Receptor Agonists — Class (semaglutide, liraglutide, tirzepatide, dulaglutide, exenatide) | Pre-op Medication Considerations | 27/44 |
| Insulin (long-acting home dose) | Pre-op Medication Considerations | 27/44 |
| Bosentan | Cardiac & Hemodynamics | 28/44 |
| Furosemide (Lasix) | Cardiac & Hemodynamics | 28/44 |
| Hydralazine PRN | Cardiac & Hemodynamics | 28/44 |
| Albumin 5% / 25% | Electrolytes & Fluids | 28/44 |
| Dextrose 5% in Water (D5W) | Electrolytes & Fluids | 28/44 |
| Lactated Ringer's Solution (LR) | Electrolytes & Fluids | 28/44 |
| PlasmaLyte / Normosol | Electrolytes & Fluids | 28/44 |
| Cabergoline (Dostinex) | Endocrine & Metabolic | 28/44 |
| Dulaglutide | Endocrine & Metabolic | 28/44 |
| Fludrocortisone (Florinef) | Endocrine & Metabolic | 28/44 |
| Glipizide (Glucotrol) | Endocrine & Metabolic | 28/44 |
| Levothyroxine (Synthroid) | Endocrine & Metabolic | 28/44 |
| Liothyronine (Cytomel) | Endocrine & Metabolic | 28/44 |
| Metformin (Glucophage) | Endocrine & Metabolic | 28/44 |
| Sitagliptin (Januvia) | Endocrine & Metabolic | 28/44 |
| Carbamazepine (Tegretol) | Neurologic | 28/44 |
| Levetiracetam | Neurologic | 28/44 |

## 5. Recommended Fix Order

1. **Duplicates Type A** — quick win. Merge/delete 14 pairs. ~30 minutes.
2. **Categories** — rename 5 categories to canonical, decide splits (e.g. Emergency & Reversal → split into two). ~15 minutes of decisions + bulk update.
3. **Duplicates Type B** — clinical decision: keep separate records vs. consolidate with secondary_categories. Per-group review needed.
4. **Field gaps** — mostly acceptable (all drugs have core clinical content). Optional cleanup pass for drugs missing peds_dose, mixing details, etc.