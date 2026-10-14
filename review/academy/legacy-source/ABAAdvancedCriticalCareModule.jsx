import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

export default function ABAAdvancedCriticalCareModule() {
  const [open, setOpen] = useState({
    shock: false, sepsis: false, ards: false, vent: false,
    aki: false, transfusion: false, endocrine: false, sedation: false,
    brain: false, practice: false,
  });
  const toggle = (k) => setOpen((p) => ({ ...p, [k]: !p[k] }));

  return (
    <div className="space-y-3">

      {/* 1. Shock */}
      <div className="rounded-2xl border border-red-200 bg-card overflow-hidden">
        <button onClick={() => toggle('shock')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-red-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🚨</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">1. Shock &amp; Hemodynamic Resuscitation</p>
            <p className="text-xs text-muted-foreground mt-0.5">Shock types, resuscitation markers, dynamic indices</p>
          </div>
          {open.shock ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.shock && (
          <div className="border-t border-red-100 p-4 bg-red-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-red-700 mb-1.5">Shock Classification</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• <span className="font-semibold">Hypovolemic:</span> Low preload, high SVR, low CO → volume + source control</li>
                <li>• <span className="font-semibold">Cardiogenic:</span> Low CO, high SVR, congested → inotropes, afterload reduction, IABP/VAD/ECMO</li>
                <li>• <span className="font-semibold">Distributive</span> (septic, anaphylactic, neurogenic): Low SVR, high/normal CO → volume + vasopressors</li>
                <li>• <span className="font-semibold">Obstructive</span> (PE, tamponade, tension PTX): Address obstruction</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-red-700 mb-1.5">Resuscitation Markers</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• MAP ≥65 mmHg; urine output ≥0.5 mL/kg/h</li>
                <li>• Lactate clearance: &gt;10% drop over 2 hours predicts survival</li>
                <li>• ScvO₂ goal-directed therapy did not improve outcomes (ProCESS, ARISE, PROMISE)</li>
                <li>• Dynamic indices (PPV, SVV): valid only in mechanically ventilated, NSR, TV ≥8 mL/kg, no spontaneous breathing, closed chest; &gt;12–13% predicts fluid responsiveness</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 2. Sepsis */}
      <div className="rounded-2xl border border-orange-200 bg-card overflow-hidden">
        <button onClick={() => toggle('sepsis')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-orange-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🦠</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">2. Sepsis &amp; Septic Shock</p>
            <p className="text-xs text-muted-foreground mt-0.5">Surviving Sepsis 2021 bundle, vasopressor ladder</p>
          </div>
          {open.sepsis ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.sepsis && (
          <div className="border-t border-orange-100 p-4 bg-orange-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Surviving Sepsis 2021 Bundle</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Measure lactate; obtain blood cultures</li>
                <li>• Broad-spectrum antibiotics within 1 hour</li>
                <li>• Balanced crystalloid 30 mL/kg over 3 hours for hypotension or lactate ≥4</li>
                <li>• Vasopressors to MAP ≥65 if hypotension persists</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Vasopressor Ladder</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Norepinephrine: first-line</li>
                <li>• Vasopressin 0.03 U/min: second-line (norepinephrine-sparing)</li>
                <li>• Epinephrine: added if MAP not maintained</li>
                <li>• Dobutamine: for myocardial dysfunction (low CO)</li>
                <li>• Hydrocortisone 200 mg/day: refractory shock requiring NE ≥0.25 mcg/kg/min</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 3. ARDS */}
      <div className="rounded-2xl border border-sky-200 bg-card overflow-hidden">
        <button onClick={() => toggle('ards')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-sky-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🫁</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">3. ARDS &amp; Lung-Protective Ventilation</p>
            <p className="text-xs text-muted-foreground mt-0.5">Berlin definition, ARDSnet, prone positioning</p>
          </div>
          {open.ards ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.ards && (
          <div className="border-t border-sky-100 p-4 bg-sky-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Berlin Definition</p>
              <p className="text-xs text-muted-foreground">Acute onset (&lt;1 week), bilateral infiltrates, not fully explained by cardiac failure or volume overload, PaO₂/FiO₂ ≤300 with PEEP ≥5. Severity: mild 200–300, moderate 100–200, severe ≤100.</p>
            </div>
            <div>
              <p className="font-bold text-sky-700 mb-1.5">ARDSnet Strategy</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Tidal volume 6 mL/kg predicted body weight</li>
                <li>• Plateau pressure ≤30 cmH₂O; driving pressure (plateau − PEEP) ≤15 cmH₂O</li>
                <li>• PEEP titrated by FiO₂/PEEP table or esophageal pressure</li>
                <li>• Permissive hypercapnia acceptable (pH ≥7.20)</li>
                <li>• Prone positioning ≥16 h/day reduces mortality in severe ARDS (P/F ≤150) — PROSEVA</li>
                <li>• NMB selective use in severe ARDS; conservative fluid after resuscitation (FACTT)</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 4. Mechanical Ventilation */}
      <div className="rounded-2xl border border-teal-200 bg-card overflow-hidden">
        <button onClick={() => toggle('vent')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-teal-50 active:scale-[0.99] transition-all">
          <span className="text-xl">⚙️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">4. Mechanical Ventilation &amp; Weaning</p>
            <p className="text-xs text-muted-foreground mt-0.5">Modes, SAT/SBT, RSBI, extubation readiness</p>
          </div>
          {open.vent ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.vent && (
          <div className="border-t border-teal-100 p-4 bg-teal-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Modes</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• <span className="font-semibold">Volume control:</span> Set TV, RR, PEEP, FiO₂; pressure varies with compliance</li>
                <li>• <span className="font-semibold">Pressure control:</span> Set insp. pressure, RR, PEEP; volume varies with compliance</li>
                <li>• <span className="font-semibold">Pressure support:</span> Patient triggers; pressure assists each breath</li>
                <li>• <span className="font-semibold">SIMV:</span> Discouraged — dyssynchrony</li>
                <li>• <span className="font-semibold">APRV:</span> High CPAP with brief release; refractory hypoxemia</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Weaning</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Daily SAT (spontaneous awakening trial) + SBT (spontaneous breathing trial) — ABC trial: mortality reduction</li>
                <li>• RSBI (RR/Vt) &lt;105 predicts successful extubation</li>
                <li>• Cuff leak test if airway edema concern</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 5. AKI */}
      <div className="rounded-2xl border border-yellow-200 bg-card overflow-hidden">
        <button onClick={() => toggle('aki')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-yellow-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🫘</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">5. Acute Kidney Injury</p>
            <p className="text-xs text-muted-foreground mt-0.5">KDIGO criteria, RRT indications, fluid choice</p>
          </div>
          {open.aki ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.aki && (
          <div className="border-t border-yellow-100 p-4 bg-yellow-50 space-y-3 text-sm">
            <ul className="space-y-1 text-muted-foreground text-xs">
              <li>• KDIGO: Cr ≥0.3 mg/dL in 48 h, or ≥1.5× baseline, or UO &lt;0.5 mL/kg/h ×6 h</li>
              <li>• Etiology: pre-renal (hypoperfusion), intrinsic (ATN, interstitial nephritis), post-renal (obstruction)</li>
              <li>• Avoid nephrotoxins: NSAIDs, aminoglycosides, IV contrast in high-risk</li>
              <li>• RRT indications (AEIOU): refractory Acidosis, Electrolyte abnormalities (hyperkalemia), Intoxications, Overload, Uremia</li>
              <li>• Balanced crystalloids (LR, Plasmalyte) preferred over 0.9% saline (SMART, SALT-ED)</li>
            </ul>
          </div>
        )}
      </div>

      {/* 6. Transfusion */}
      <div className="rounded-2xl border border-rose-200 bg-card overflow-hidden">
        <button onClick={() => toggle('transfusion')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-rose-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🩸</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">6. Transfusion Medicine &amp; Massive Hemorrhage</p>
            <p className="text-xs text-muted-foreground mt-0.5">MTP ratios, TXA, transfusion reactions, Hgb thresholds</p>
          </div>
          {open.transfusion ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.transfusion && (
          <div className="border-t border-rose-100 p-4 bg-rose-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-rose-700 mb-1.5">Massive Transfusion</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Defined as &gt;10 units PRBC in 24 h or rapid blood volume replacement</li>
                <li>• 1:1:1 ratio (PRBC:FFP:platelets) — PROPPR trial</li>
                <li>• TXA 1 g IV within 3 hours of trauma (CRASH-2)</li>
                <li>• Goals: Hgb &gt;7, fibrinogen &gt;150–200, platelets &gt;50, INR &lt;1.5, Ca++ normal, temp &gt;36°C</li>
                <li>• Viscoelastic testing (TEG/ROTEM) for targeted component therapy</li>
                <li>• Transfusion thresholds: Hgb &lt;7 general; Hgb &lt;8 in active coronary disease (TRICC, TRISS)</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-rose-700 mb-1.5">Transfusion Reactions</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• <span className="font-semibold">Acute hemolytic:</span> ABO incompatibility, fever, back pain, hemoglobinuria, DIC → stop, supportive</li>
                <li>• <span className="font-semibold">TRALI:</span> New ARDS &lt;6 h after transfusion → supportive; no diuretics</li>
                <li>• <span className="font-semibold">TACO:</span> Volume overload → diurese</li>
                <li>• <span className="font-semibold">Anaphylactic:</span> IgA deficiency → stop, treat anaphylaxis</li>
                <li>• <span className="font-semibold">Febrile non-hemolytic:</span> Most common → symptomatic</li>
                <li>• <span className="font-semibold">Bacterial contamination:</span> Most common in platelets → fever, sepsis</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 7. Endocrine Emergencies */}
      <div className="rounded-2xl border border-purple-200 bg-card overflow-hidden">
        <button onClick={() => toggle('endocrine')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-purple-50 active:scale-[0.99] transition-all">
          <span className="text-xl">⚡</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">7. Endocrine Emergencies</p>
            <p className="text-xs text-muted-foreground mt-0.5">DKA, thyroid storm, adrenal crisis, stress dosing</p>
          </div>
          {open.endocrine ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.endocrine && (
          <div className="border-t border-purple-100 p-4 bg-purple-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-purple-700 mb-1.5">DKA</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Hyperglycemia, anion gap acidosis, ketosis</li>
                <li>• Isotonic fluids, insulin 0.1 U/kg/h, K+ replacement (replace if K+ &lt;3.3 BEFORE insulin)</li>
                <li>• Monitor anion gap closure; bicarb only if pH &lt;6.9</li>
                <li>• ICU glucose target 140–180 mg/dL (NICE-SUGAR)</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Thyroid Storm</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Tachycardia, fever, AMS, GI symptoms</li>
                <li>• Treat: β-blocker (propranolol) → PTU/methimazole → iodine (≥1 h after PTU) → steroids → cooling</li>
                <li>• Steroids prevent T4 → T3 conversion</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Adrenal Crisis &amp; Stress Dosing</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Hypotension, shock, hypoglycemia, hyponatremia, hyperkalemia</li>
                <li>• Hydrocortisone 100 mg IV q8h</li>
                <li>• Stress dosing for patients on chronic steroids (&gt;5 mg/day &gt;3 weeks) undergoing major surgery: hydrocortisone 100 mg at induction, 50–100 mg q8h ×24 h</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 8. Sedation & Delirium */}
      <div className="rounded-2xl border border-green-200 bg-card overflow-hidden">
        <button onClick={() => toggle('sedation')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-green-50 active:scale-[0.99] transition-all">
          <span className="text-xl">💤</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">8. ICU Sedation &amp; Delirium</p>
            <p className="text-xs text-muted-foreground mt-0.5">ABCDEF bundle, RASS targets, CAM-ICU</p>
          </div>
          {open.sedation ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.sedation && (
          <div className="border-t border-green-100 p-4 bg-green-50 space-y-3 text-sm">
            <ul className="space-y-1 text-muted-foreground text-xs">
              <li>• Light sedation (RASS −1 to 0) preferred; daily interruption</li>
              <li>• Dexmedetomidine &amp; propofol cause less delirium than benzodiazepines (MIDEX, PRODEX, SPICE III)</li>
              <li>• CAM-ICU for delirium screening</li>
              <li>• ABCDEF bundle: Assess/treat pain, Both SAT &amp; SBT, Choice of sedation, Delirium monitoring, Early mobility, Family engagement</li>
            </ul>
          </div>
        )}
      </div>

      {/* 9. Brain Death */}
      <div className="rounded-2xl border border-indigo-200 bg-card overflow-hidden">
        <button onClick={() => toggle('brain')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-indigo-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🧠</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">9. Brain Death &amp; Organ Donation</p>
            <p className="text-xs text-muted-foreground mt-0.5">Prerequisites, clinical exam, apnea test, donor management</p>
          </div>
          {open.brain ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.brain && (
          <div className="border-t border-indigo-100 p-4 bg-indigo-50 space-y-3 text-sm">
            <ul className="space-y-1 text-muted-foreground text-xs">
              <li>• Prerequisites: known cause; exclude confounders (hypothermia, drugs, metabolic)</li>
              <li>• Clinical exam: absent brainstem reflexes (pupillary, corneal, oculocephalic, oculovestibular, gag/cough), no motor response</li>
              <li>• Apnea test: PaCO₂ rise ≥20 mmHg above baseline (or &gt;60 mmHg) without respiratory effort</li>
              <li>• Ancillary tests (if apnea test not possible): EEG, angiography, transcranial Doppler, nuclear flow study</li>
              <li>• Donor management: MAP ≥65, maintain CO &amp; oxygenation, treat DI, hypothermia, electrolyte abnormalities</li>
            </ul>
          </div>
        )}
      </div>

      {/* Practice Questions */}
      <div className="rounded-2xl border border-blue-200 bg-card overflow-hidden">
        <button onClick={() => toggle('practice')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-blue-50 active:scale-[0.99] transition-all">
          <span className="text-xl">📝</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">Practice Questions</p>
            <p className="text-xs text-muted-foreground mt-0.5">45 high-yield critical care &amp; perioperative medicine items</p>
          </div>
          {open.practice ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.practice && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Key High-Yield Topics</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• Norepinephrine: first-line in septic shock; vasopressin 0.03 U/min second-line</li>
                <li>• ARDSnet: 6 mL/kg PBW, plateau ≤30, driving pressure ≤15 cmH₂O</li>
                <li>• Prone positioning ≥16 h/day: mortality benefit in severe ARDS (P/F ≤150) — PROSEVA</li>
                <li>• PPV fluid responsiveness: requires MV + sinus rhythm + TV ≥8 mL/kg + no spontaneous breaths</li>
                <li>• Sepsis bundle: cultures, antibiotics within 1 h, 30 mL/kg balanced crystalloid</li>
                <li>• Hydrocortisone 200 mg/day: refractory shock with NE ≥0.25 mcg/kg/min</li>
                <li>• KDIGO AKI: Cr ≥0.3 in 48 h or ≥1.5× baseline or UO &lt;0.5 mL/kg/h ×6 h</li>
                <li>• MTP 1:1:1 PRBC:FFP:platelets (PROPPR); TXA within 3 h (CRASH-2)</li>
                <li>• TRALI: new ARDS &lt;6 h post-transfusion — supportive, no diuretics</li>
                <li>• DKA: Replace K+ before insulin if K+ &lt;3.3; bicarb only if pH &lt;6.9</li>
                <li>• Thyroid storm: β-blocker → PTU → iodine (1 h after PTU) → steroids</li>
                <li>• ICU glucose target: 140–180 mg/dL (NICE-SUGAR showed harm with tight control)</li>
                <li>• Daily SAT+SBT; RSBI &lt;105 predicts extubation success</li>
                <li>• Apnea test: PaCO₂ rise ≥20 mmHg without respiratory effort</li>
                <li>• Light sedation RASS −1 to 0; avoid benzodiazepines (delirium risk)</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Study Tips */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200">
        <p className="text-xs font-bold text-emerald-700 mb-2">💡 Study Strategy</p>
        <ul className="space-y-1 text-xs text-muted-foreground">
          <li>• Master the Surviving Sepsis 1-hour bundle cold</li>
          <li>• Know ARDSnet parameters and when to prone (P/F ≤150)</li>
          <li>• Memorize DKA insulin/K+ sequencing and bicarb threshold</li>
          <li>• Distinguish TRALI (no diuretics) from TACO (diurese)</li>
          <li>• Practice all 45 questions before the ABA ADVANCED exam</li>
        </ul>
      </div>
    </div>
  );
}