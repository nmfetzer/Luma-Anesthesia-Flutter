import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

export default function ABAAdvancedCardiothoracicModule() {
  const [expandedSections, setExpandedSections] = useState({
    preop: false,
    cpb: false,
    valvular: false,
    ischemic: false,
    thoracic: false,
    vascular: false,
    circulatory: false,
    pulmonary: false,
    practice: false,
  });

  const toggleSection = (key) => {
    setExpandedSections((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  return (
    <div className="space-y-3">
      {/* 1. Preoperative Cardiac Assessment */}
      <div className="rounded-2xl border border-sky-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('preop')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-sky-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">📋</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">1. Preoperative Cardiac Assessment</p>
            <p className="text-xs text-muted-foreground mt-0.5">LV/RV function, valves, coronary anatomy, STS risk score</p>
          </div>
          {expandedSections.preop ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.preop && (
          <div className="border-t border-sky-100 p-4 bg-sky-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Key Elements</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• LV and RV function, valve lesions, coronary anatomy</li>
                <li>• Pulmonary artery pressures, prior interventions, end-organ function</li>
                <li>• STS risk score predicts mortality and major morbidity</li>
                <li>• EuroSCORE II also commonly used</li>
                <li>• Frailty, carotid disease screening (≥65 with bruits/TIA), renal function</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 2. Cardiopulmonary Bypass */}
      <div className="rounded-2xl border border-teal-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('cpb')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-teal-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🫀</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">2. Cardiopulmonary Bypass</p>
            <p className="text-xs text-muted-foreground mt-0.5">Anticoagulation, pump physiology, weaning</p>
          </div>
          {expandedSections.cpb ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.cpb && (
          <div className="border-t border-teal-100 p-4 bg-teal-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Anticoagulation</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Heparin 300–400 U/kg → ACT &gt;480 sec before CPB</li>
                <li>• Heparin resistance (ACT &lt;480 after 500 U/kg): antithrombin III or FFP</li>
                <li>• HIT II: bivalirudin or argatroban alternatives</li>
                <li>• Reversal: protamine 1 mg per 100 U heparin (risk of hypotension, pulmonary HTN, Type III reaction)</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Pump Physiology</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Non-pulsatile flow: CI 2.2–2.4 L/min/m²; MAP 50–80 mmHg (higher in HTN, CKD, CVD)</li>
                <li>• Hemodilution to Hct 18–22%; transfusion threshold individualized</li>
                <li>• Mild hypothermia (32–34°C) reduces metabolic demand</li>
                <li>• Deep hypothermic circulatory arrest (15–18°C) for aortic arch repair</li>
                <li>• Cardioplegia: cold blood/crystalloid, high K+, arrests heart in diastole</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Weaning from Bypass</p>
              <p className="text-xs text-muted-foreground">Checklist: rewarmed ≥36°C, sinus rhythm, electrolytes corrected, ventilation resumed, TEE assessment of ventricular function, de-airing complete. Difficult separation: ischemia, valve issue, RV dysfunction, vasoplegia, inadequate revascularization.</p>
            </div>
          </div>
        )}
      </div>

      {/* 3. Valvular Heart Disease */}
      <div className="rounded-2xl border border-purple-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('valvular')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-purple-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">💓</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">3. Valvular Heart Disease</p>
            <p className="text-xs text-muted-foreground mt-0.5">AS, AR, MS, MR, HOCM management</p>
          </div>
          {expandedSections.valvular ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.valvular && (
          <div className="border-t border-purple-100 p-4 bg-purple-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Aortic Stenosis</p>
              <p className="text-xs text-muted-foreground">Avoid hypotension, tachycardia; maintain preload, NSR, afterload. Slow induction; phenylephrine for hypotension.</p>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Aortic Regurgitation</p>
              <p className="text-xs text-muted-foreground">'Fast, full, forward' — slightly higher HR, full preload, decreased afterload (vasodilators useful).</p>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Mitral Stenosis</p>
              <p className="text-xs text-muted-foreground">Avoid tachycardia (impairs LA emptying), maintain NSR, preload, avoid pulmonary HTN triggers (hypoxia, hypercarbia, acidosis, N₂O).</p>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">Mitral Regurgitation</p>
              <p className="text-xs text-muted-foreground">'Fast, full, forward' — vasodilation to reduce regurgitant fraction.</p>
            </div>
            <div>
              <p className="font-bold text-purple-700 mb-1.5">HOCM</p>
              <p className="text-xs text-muted-foreground">Avoid tachycardia, low preload, low afterload, inotropy. β-blockers and phenylephrine first-line.</p>
            </div>
          </div>
        )}
      </div>

      {/* 4. Ischemic Heart Disease &amp; CABG */}
      <div className="rounded-2xl border border-red-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('ischemic')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-red-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🫀</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">4. Ischemic Heart Disease &amp; CABG</p>
            <p className="text-xs text-muted-foreground mt-0.5">Myocardial O₂ balance, perioperative medications, OPCAB</p>
          </div>
          {expandedSections.ischemic ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.ischemic && (
          <div className="border-t border-red-100 p-4 bg-red-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-red-700 mb-1.5">Core Strategy</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Maintain myocardial O₂ supply-demand balance</li>
                <li>• Avoid tachycardia, hypertension/hypotension, anemia, hypoxia</li>
                <li>• β-blockers continued perioperatively</li>
                <li>• Statins continued; aspirin usually continued</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-red-700 mb-1.5">Off-Pump CABG (OPCAB)</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Avoids CPB inflammatory response</li>
                <li>• Requires hemodynamic manipulation during distal anastomoses</li>
                <li>• Trendelenburg, fluid, vasopressors maintain CO</li>
                <li>• Cell salvage &amp; antifibrinolytics (TXA, ε-aminocaproic acid) reduce transfusion</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 5. Thoracic Anesthesia &amp; One-Lung Ventilation */}
      <div className="rounded-2xl border border-orange-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('thoracic')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-orange-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🫁</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">5. Thoracic Anesthesia &amp; One-Lung Ventilation</p>
            <p className="text-xs text-muted-foreground mt-0.5">DLT sizing, hypoxemia rescue, lung-protective ventilation</p>
          </div>
          {expandedSections.thoracic ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.thoracic && (
          <div className="border-t border-orange-100 p-4 bg-orange-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Lung Isolation</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• DLT sizes: 35–37 Fr women, 39–41 Fr men; left-sided preferred</li>
                <li>• Bronchial blockers (Arndt, Cohen) for difficult airway</li>
                <li>• Confirm placement with fiberoptic bronchoscopy</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Management of Hypoxemia on OLV</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Verify tube position with bronchoscopy</li>
                <li>• Increase FiO₂ to 1.0</li>
                <li>• CPAP 5–10 cmH₂O to nondependent lung</li>
                <li>• PEEP 5–10 cmH₂O to dependent lung</li>
                <li>• Recruitment maneuver; if refractory, brief two-lung ventilation</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Lung-Protective Ventilation During OLV</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Tidal volume 4–6 mL/kg IBW (of ventilated lung)</li>
                <li>• PEEP 5 cmH₂O</li>
                <li>• Plateau pressure &lt;25 cmH₂O</li>
                <li>• Permissive hypercapnia acceptable</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 6. Vascular Anesthesia */}
      <div className="rounded-2xl border border-pink-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('vascular')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-pink-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🛠️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">6. Vascular Anesthesia</p>
            <p className="text-xs text-muted-foreground mt-0.5">AAA, EVAR/TEVAR, carotid endarterectomy</p>
          </div>
          {expandedSections.vascular ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.vascular && (
          <div className="border-t border-pink-100 p-4 bg-pink-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Abdominal Aortic Aneurysm (AAA)</p>
              <p className="text-xs text-muted-foreground">Open repair: arterial line, central access, large IV, cell saver, possible TEE, epidural for postop analgesia. Hemodynamic swings at cross-clamp (above-clamp HTN, below-clamp ischemia) and unclamping (hypotension from vasodilation &amp; washout of acidic metabolites).</p>
            </div>
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Endovascular Aortic Repair (EVAR/TEVAR)</p>
              <p className="text-xs text-muted-foreground">Less hemodynamic instability; may be done under MAC, regional, or GA. Spinal cord ischemia concern in TEVAR — CSF drainage via lumbar drain may reduce paraplegia risk.</p>
            </div>
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Carotid Endarterectomy</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Awake (regional cervical plexus): direct neurologic assessment</li>
                <li>• GA: controlled physiology, easier surgery</li>
                <li>• Maintain MAP at/slightly above baseline during cross-clamp</li>
                <li>• Postop hypertension common; aggressive control reduces reperfusion injury</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 7. Mechanical Circulatory Support */}
      <div className="rounded-2xl border border-yellow-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('circulatory')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-yellow-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🔧</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">7. Mechanical Circulatory Support</p>
            <p className="text-xs text-muted-foreground mt-0.5">IABP, LVAD, VA-ECMO, VV-ECMO</p>
          </div>
          {expandedSections.circulatory ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.circulatory && (
          <div className="border-t border-yellow-100 p-4 bg-yellow-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">IABP</p>
              <p className="text-xs text-muted-foreground">Inflates in diastole (augments coronary perfusion); deflates in systole (afterload reduction). Contraindicated in severe AR. Timing errors reduce benefit.</p>
            </div>
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">LVAD</p>
              <p className="text-xs text-muted-foreground">HeartMate III, HeartWare: continuous flow; no palpable pulse (check MAP by Doppler). Avoid RV failure, dehydration, suction events. Anticoagulation always maintained.</p>
            </div>
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">VA-ECMO</p>
              <p className="text-xs text-muted-foreground">Cardiac &amp; pulmonary support; risks: differential hypoxia ('Harlequin syndrome'), LV distension, limb ischemia, bleeding.</p>
            </div>
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">VV-ECMO</p>
              <p className="text-xs text-muted-foreground">Respiratory support only; no hemodynamic support.</p>
            </div>
          </div>
        )}
      </div>

      {/* 8. Pulmonary Hypertension &amp; RV Failure */}
      <div className="rounded-2xl border border-green-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('pulmonary')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-green-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">⚠️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">8. Pulmonary Hypertension &amp; RV Failure</p>
            <p className="text-xs text-muted-foreground mt-0.5">Highest-risk condition | PVR reduction, RV support</p>
          </div>
          {expandedSections.pulmonary ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.pulmonary && (
          <div className="border-t border-green-100 p-4 bg-green-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-green-700 mb-1.5">Severe Pulmonary HTN Definition</p>
              <p className="text-xs text-muted-foreground">Mean PAP &gt;35 mmHg with RV dysfunction — one of highest-risk anesthetic conditions.</p>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Avoid Triggers</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Hypoxia, hypercarbia, acidosis, hypothermia, high airway pressures, N₂O — all worsen PVR</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Inhaled NO (10–40 ppm) or inhaled epoprostenol (50 ng/kg/min) selectively lower PVR</li>
                <li>• Maintain RV perfusion: vasopressin, norepinephrine</li>
                <li>• Inotropy: milrinone, dobutamine, epinephrine</li>
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
            <p className="text-xs text-muted-foreground mt-0.5">45 high-yield cardiothoracic &amp; vascular items</p>
          </div>
          {expandedSections.practice ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.practice && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Coverage Areas</p>
              <p className="text-muted-foreground">CPB anticoagulation &amp; ACT targets, protamine reversal, valvular disease hemodynamics, CABG management, one-lung ventilation hypoxemia rescue, carotid surgery neuromonitoring, IABP complications, LVAD monitoring, ECMO (Harlequin syndrome), vasoplegia management, coronary spasm treatment, heart transplant recipients, DLT placement confirmation, lung-protective ventilation settings, AAA declamping shock, torsades after cardiac surgery, cardioplegia composition, cell saver contraindications.</p>
            </div>
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Key High-Yield Topics</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• ACT &gt;480 sec target for full CPB anticoagulation</li>
                <li>• Protamine 1 mg reverses ~100 units heparin</li>
                <li>• Type III protamine reaction: pulmonary vasoconstriction &amp; RV failure</li>
                <li>• Aortic stenosis: maintain afterload &amp; coronary perfusion</li>
                <li>• Aortic regurgitation: 'fast, full, forward' hemodynamic strategy</li>
                <li>• CPAP to nondependent lung for OLV hypoxemia rescue</li>
                <li>• Stump pressure &lt;40 mmHg in carotid CEA: place shunt</li>
                <li>• Continuous-flow LVAD: non-pulsatile flow (use Doppler for MAP)</li>
                <li>• Declamping shock: vasodilation, metabolic acidosis, hyperkalemia</li>
                <li>• Methylene blue for refractory vasoplegia after CPB</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Study Tips */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200">
        <p className="text-xs font-bold text-emerald-700 mb-2">💡 Study Strategy</p>
        <ul className="space-y-1 text-xs text-muted-foreground">
          <li>• Understand hemodynamic goals for each valve lesion (slow/fast, full/dry, forward)</li>
          <li>• Master CPB physiology: ACT targets, protamine dosing, weaning checklist</li>
          <li>• Know one-lung ventilation troubleshooting (CPAP, PEEP, recruitment, clamping)</li>
          <li>• Recognize high-risk scenarios: severe PH, HOCM, complex valvular disease</li>
          <li>• Practice all 45 questions before ABA ADVANCED exam</li>
        </ul>
      </div>
    </div>
  );
}