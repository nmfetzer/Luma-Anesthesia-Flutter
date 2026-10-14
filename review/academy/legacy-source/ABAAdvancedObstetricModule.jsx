import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

export default function ABAAdvancedObstetricModule() {
  const [expandedSections, setExpandedSections] = useState({
    maternal: false,
    labor: false,
    cesarean: false,
    hemorrhage: false,
    preeclampsia: false,
    cardiac: false,
    afe: false,
    fhr: false,
    practice: false,
  });

  const toggleSection = (key) => {
    setExpandedSections((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  return (
    <div className="space-y-3">
      {/* 1. Maternal Physiologic Changes */}
      <div className="rounded-2xl border border-sky-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('maternal')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-sky-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">👶</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">1. Maternal Physiologic Changes</p>
            <p className="text-xs text-muted-foreground mt-0.5">CV, respiratory, GI, metabolic</p>
          </div>
          {expandedSections.maternal ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.maternal && (
          <div className="border-t border-sky-100 p-4 bg-sky-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Cardiovascular</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Plasma volume ↑ 45%, RBC mass ↑ 20% → physiologic anemia</li>
                <li>• CO ↑ 30–50% by 24 weeks; further ↑ 25% during labor, ~60–80% postpartum</li>
                <li>• SVR/PVR decrease; BP nadirs at mid-pregnancy</li>
                <li>• Aortocaval compression after 20 weeks — LUD mandatory</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Respiratory</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• MV ↑ 50% (mostly TV); PaCO₂ ~30, HCO₃ ~20 (compensated alkalosis)</li>
                <li>• FRC ↓ 20%; O₂ consumption ↑ 20% → rapid desaturation</li>
                <li>• Airway edema, weight gain → higher difficult intubation rate</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Gastrointestinal &amp; Other</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• LES tone decreases → full stomach ≥ 20 weeks</li>
                <li>• MAC ↓ ~30%; epidural local anesthetic requirement ↓ ~30%</li>
                <li>• Hypercoagulable: ↑ factors I, VII, VIII, IX, X, XII; ↓ protein S → VTE risk</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 2. Labor Analgesia */}
      <div className="rounded-2xl border border-teal-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('labor')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-teal-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">💊</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">2. Labor Analgesia</p>
            <p className="text-xs text-muted-foreground mt-0.5">Neuraxial, CSE, PIEB, anticoagulation</p>
          </div>
          {expandedSections.labor ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.labor && (
          <div className="border-t border-teal-100 p-4 bg-teal-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Neuraxial Techniques</p>
              <p className="text-xs text-muted-foreground mb-2">Epidural: bupivacaine 0.0625–0.125% + fentanyl 2 mcg/mL | CSE: fentanyl 15–25 mcg ± bupivacaine 1.25–2.5 mg | PIEB reduces consumption vs continuous infusion</p>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Contraindications</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Refusal, infection, uncorrected coagulopathy, frank hypovolemia, severe stenotic lesions</li>
                <li>• Platelets: ≥70k if stable; lower threshold with normal coagulation in stable preeclampsia</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Anticoagulation (ASRA 4th ed.)</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Prophylactic LMWH: wait 12 hours before neuraxial</li>
                <li>• Therapeutic LMWH: wait 24 hours</li>
                <li>• UFH 5k U BID: no delay; TID: delay 4–6 hr, verify normal aPTT</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 3. Anesthesia for Cesarean */}
      <div className="rounded-2xl border border-purple-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('cesarean')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-purple-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🏥</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">3. Anesthesia for Cesarean Delivery</p>
            <p className="text-xs text-muted-foreground mt-0.5">Spinal, epidural, general</p>
          </div>
          {expandedSections.cesarean ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.cesarean && (
          <div className="border-t border-purple-100 p-4 bg-purple-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Spinal Anesthesia</p>
              <p className="text-xs text-muted-foreground">Hyperbaric bupivacaine 0.75% 10.5–12 mg + fentanyl 15 mcg + morphine 100–200 mcg → 60–90 min surgical, 18–24 h analgesia. Target T4. Use phenylephrine infusion (25–50 mcg/min) for hypotension; ephedrine for bradycardia.</p>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">General Anesthesia</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Indications: emergent, contraindication to neuraxial, failed neuraxial, refusal</li>
                <li>• RSI: propofol/ketamine + succinylcholine/rocuronium</li>
                <li>• After delivery: ↓ sevoflurane to ≤1 MAC to minimize atony</li>
                <li>• Awareness rate ~1:670 (highest surgical population) — consider processed EEG</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 4. Obstetric Hemorrhage */}
      <div className="rounded-2xl border border-red-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('hemorrhage')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-red-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🚨</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">4. Obstetric Hemorrhage</p>
            <p className="text-xs text-muted-foreground mt-0.5">Leading maternal mortality cause | 4 T&apos;s: Tone, Trauma, Tissue, Thrombin</p>
          </div>
          {expandedSections.hemorrhage ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.hemorrhage && (
          <div className="border-t border-red-100 p-4 bg-red-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-red-700 mb-1.5">Etiologies</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Tone: uterine atony (70%)</li>
                <li>• Trauma: lacerations, uterine rupture</li>
                <li>• Tissue: retained placenta, accreta spectrum</li>
                <li>• Thrombin: coagulopathy</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-red-700 mb-1.5">Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• 1:1:1 ratio + early fibrinogen; target fibrinogen &gt;200 mg/dL</li>
                <li>• TXA 1 g within 3 hours of bleeding onset reduces mortality</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-red-700 mb-1.5">Uterotonics — Stepwise</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Oxytocin 1–3 IU IV slow bolus + infusion</li>
                <li>• Methylergonovine 0.2 mg IM (CI in HTN)</li>
                <li>• Carboprost 250 mcg IM (avoid in asthma)</li>
                <li>• Misoprostol 600–1000 mcg PR/buccal</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 5. Hypertensive Disorders of Pregnancy */}
      <div className="rounded-2xl border border-orange-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('preeclampsia')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-orange-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">⚠️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">5. Hypertensive Disorders of Pregnancy</p>
            <p className="text-xs text-muted-foreground mt-0.5">Preeclampsia, magnesium sulfate, seizure prophylaxis</p>
          </div>
          {expandedSections.preeclampsia ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.preeclampsia && (
          <div className="border-t border-orange-100 p-4 bg-orange-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Preeclampsia Definition</p>
              <p className="text-xs text-muted-foreground">New-onset HTN ≥140/90 after 20 weeks + proteinuria or end-organ dysfunction</p>
            </div>
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Severe Features</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• BP ≥160/110, platelets &lt;100k, transaminitis, renal insufficiency, pulmonary edema, headache, visual changes</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Magnesium sulfate: 4–6 g loading, then 1–2 g/h (seizure prophylaxis)</li>
                <li>• Neuraxial preferred if platelets ≥70k stable</li>
                <li>• BP control: labetalol, hydralazine, nicardipine, esmolol</li>
                <li>• Magnesium prolongs NMBs</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 6. Cardiac Disease in Pregnancy */}
      <div className="rounded-2xl border border-pink-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('cardiac')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-pink-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">❤️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">6. Cardiac Disease in Pregnancy</p>
            <p className="text-xs text-muted-foreground mt-0.5">mWHO IV, mitral/aortic stenosis, peripartum cardiomyopathy</p>
          </div>
          {expandedSections.cardiac ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.cardiac && (
          <div className="border-t border-pink-100 p-4 bg-pink-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Highest Risk (mWHO IV)</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Severe pulmonary HTN, severe symptomatic AS/MS, Marfan + aortic root &gt;45 mm, EF &lt;30%</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Anesthetic Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Avoid hypotension &amp; tachycardia in AS/MS</li>
                <li>• Early epidural with slow titration appropriate</li>
                <li>• Peripartum cardiomyopathy: LV-EF &lt;45%, last month pregnancy or 5 months postpartum</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 7. Amniotic Fluid Embolism */}
      <div className="rounded-2xl border border-yellow-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('afe')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-yellow-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">💔</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">7. Amniotic Fluid Embolism</p>
            <p className="text-xs text-muted-foreground mt-0.5">Rare, high mortality | Supportive care, ECMO, vasodilators</p>
          </div>
          {expandedSections.afe ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.afe && (
          <div className="border-t border-yellow-100 p-4 bg-yellow-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">Presentation</p>
              <p className="text-xs text-muted-foreground">Rare (1:40k), high mortality. Classic triad: CV collapse, respiratory failure, DIC (± seizures)</p>
            </div>
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">Treatment</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Supportive: ACLS, perimortem C-section by 4 min if arrest</li>
                <li>• Vasopressors, transfusion (1:1:1 + fibrinogen), TXA, ECMO if available</li>
                <li>• Pulmonary vasodilators: inhaled NO, epoprostenol for RV failure</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 8. Fetal Heart Rate Patterns */}
      <div className="rounded-2xl border border-green-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('fhr')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-green-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🫀</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">8. Fetal Heart Rate Patterns</p>
            <p className="text-xs text-muted-foreground mt-0.5">Category I/II/III, intrauterine resuscitation</p>
          </div>
          {expandedSections.fhr ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.fhr && (
          <div className="border-t border-green-100 p-4 bg-green-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-green-700 mb-1.5">Category I (Normal)</p>
              <p className="text-xs text-muted-foreground">Baseline 110–160, moderate variability, no late/variable decels, accelerations may/may not be present</p>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Category II (Indeterminate)</p>
              <p className="text-xs text-muted-foreground">Not Category I or III — most common</p>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Category III (Abnormal)</p>
              <p className="text-xs text-muted-foreground">Absent variability + recurrent late/variable decels or bradycardia, or sinusoidal pattern</p>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Intrauterine Resuscitation</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• LUD, oxygen, IVF, discontinue oxytocin, treat hypotension</li>
                <li>• Tocolysis (terbutaline 250 mcg SC)</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Practice Questions */}
      <div className="rounded-2xl border border-blue-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('practice')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-blue-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">📝</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">Practice Questions</p>
            <p className="text-xs text-muted-foreground mt-0.5">45 high-yield items with detailed rationales</p>
          </div>
          {expandedSections.practice ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.practice && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Coverage Areas</p>
              <p className="text-muted-foreground">Maternal physiology, labor analgesia, cesarean anesthesia techniques, hemorrhage management, hypertensive crises, cardiac disease, amniotic fluid embolism, fetal monitoring, cesarean complications, anticoagulation, difficult airway in pregnancy, local anesthetic toxicity, opioid tolerance, failed regional blocks, patient-specific considerations (obesity, cardiomyopathy, accreta)</p>
            </div>
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Key High-Yield Topics</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• LUD for aortocaval compression (always first line)</li>
                <li>• Platelet thresholds for neuraxial in preeclampsia (≥70k if stable)</li>
                <li>• Uterotonic stepwise approach (oxytocin → methylergonovine → carboprost → misoprostol)</li>
                <li>• Magnesium sulfate dosing and prolongation of NMBs</li>
                <li>• Perimortem C-section within 4 minutes if maternal arrest</li>
                <li>• Intrathecal morphine 100–150 mcg for 18–24 h analgesia</li>
                <li>• Spinal hypotension prevention (coloading + phenylephrine)</li>
                <li>• Category III FHR → intrauterine resuscitation (LUD, O₂, IVF, stop oxytocin)</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Study Tips */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200">
        <p className="text-xs font-bold text-emerald-700 mb-2">💡 Study Strategy</p>
        <ul className="space-y-1 text-xs text-muted-foreground">
          <li>• Master the 4 T&apos;s of PPH and uterotonic sequencing</li>
          <li>• Understand why spinal hypotension occurs and how to prevent it</li>
          <li>• Know the pathophysiology behind each maternal physiologic change</li>
          <li>• Practice drug calculations (dosing, infusions, weight-based)</li>
          <li>• Understand magnesium toxicity progression and treatment</li>
          <li>• Review all 45 practice questions before board exam</li>
        </ul>
      </div>
    </div>
  );
}