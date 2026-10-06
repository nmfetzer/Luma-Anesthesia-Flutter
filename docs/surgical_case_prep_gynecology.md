# Gynecology surgical case expansion

Source milestone: October 5, 2026. Twenty-five adult references are expanded or added, comprising 17 existing records and eight new records. The catalog now has 296 unique adult/OB references across the existing 22 specialties. Gynecology displays 27 references, including two unchanged related pregnancy/postpartum procedures.

## Scope and navigation

- **Coverage:** Framework and emergencies; uterine/cervical procedures; laparoscopic/adnexal surgery; fibroid surgery; hysterectomy; pelvic floor/vulvovaginal surgery; gynecologic oncology; related pregnancy/postpartum procedures.
- **Canonical routes:** Existing IDs retained, including the combined ovarian cystectomy/oophorectomy route. Eight new IDs add framework, diagnostic gynecologic laparoscopy, torsion, pelvic emergency reference, radical hysterectomy, endometriosis excision, sling and exenteration.
- **Preservation:** All 270 untargeted JSON records remain byte-equivalent when serialized individually against baseline `31231c933cc7646e20b2482b618544ae96cc992f`. The manual laparoscopic cholecystectomy record is unchanged.
- **Boundaries:** Cesarean delivery and postpartum hemorrhage remain in Obstetrics. Existing cerclage and postpartum tubal ligation content is unchanged. No pediatric expansion.

## Selected evidence safeguards

- **Hysteroscopy:** Distinguishes hypotonic-media hyponatremia from saline overload, labels the 2016 fluid thresholds and lower comorbidity limits, and explains that deficit does not equal intravascular absorption ([BSGE/ESGE guideline](https://www.esge.org/wp-content/uploads/2025/06/2016-ESGE-BSGE-Guideliens-on-distension-media.pdf)).
- **Myomectomy:** Local vasopressin can cause severe systemic toxicity; negative aspiration does not eliminate risk and an unreadable peripheral pressure does not automatically mean systemic hypotension. No universal safe dose is asserted ([case report](https://pmc.ncbi.nlm.nih.gov/articles/PMC4141394/)).
- **Uterotonics:** Methylergonovine hypertension contraindication is explicit; carboprost active pulmonary disease contraindication and asthma-history caution are distinguished ([FDA Methergine label](https://www.accessdata.fda.gov/drugsatfda_docs/label/2025/006035s080lbl.pdf), [Pfizer HEMABATE label](https://labeling.pfizer.com/showlabeling.aspx?id=598)).
- **Aspiration:** Early pregnancy alone is not treated as proof of delayed gastric emptying; active vomiting, pain/opioids, shock, gestational stage and fasting are considered together ([pregnancy anesthesia review](https://journals.lww.com/ejaintensivecare/Fulltext/2022/04000/General_anaesthesia_for_nonobstetric_surgery.2.aspx)).
- **Positioning:** Nerve and compartment precautions are retained with the historical consensus date and expired stated validity disclosed, rather than labeling the document a newly current guideline ([2020/2021 positioning consensus](https://europepmc.org/article/pmc/pmc8046520)).

## Evidence gap before clinical signoff

The [2026 ERAS gynecologic oncology update](https://www.sciencedirect.com/science/article/pii/S0090825826019992) was identified, but full-text recommendations could not be retrieved for verification. The app and review packet explicitly cite the accessible [2023 implementation update](https://www.gynecologiconcology-online.net/article/S0090-8258(23)00180-4/fulltext) and earlier labeled guidance. Reconcile the 2026 update before clinical signoff; this source merge does not claim that reconciliation is complete. Legacy endometrial-ablation labeling is an example of device-specific risks, not a current device operating instruction.

## Validation and release boundary

Targeted catalog/content/layout tests cover count, unique groups, canonical routes, critical wording, double-text layouts, search, access gates and deferred release. Technical results and preview checks are recorded in the accompanying QA packet.

All expanded records remain clinical drafts. This update does not approve clinical release, change Supabase, activate deferred app sections or build/upload/release a native app.
