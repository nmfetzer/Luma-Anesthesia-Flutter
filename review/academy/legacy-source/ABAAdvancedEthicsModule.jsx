import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

export default function ABAAdvancedEthicsModule() {
  const [open, setOpen] = useState({
    principles: false, consent: false, dnr: false, eol: false,
    hipaa: false, error: false, safety: false, medsafety: false,
    wrongsite: false, sud: false, practice: false,
  });
  const toggle = (k) => setOpen((p) => ({ ...p, [k]: !p[k] }));

  return (
    <div className="space-y-3">

      {/* 1. Foundational Ethical Principles */}
      <div className="rounded-2xl border border-purple-200 bg-card overflow-hidden">
        <button onClick={() => toggle('principles')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-purple-50 active:scale-[0.99] transition-all">
          <span className="text-xl">⚖️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">1. Foundational Ethical Principles</p>
            <p className="text-xs text-muted-foreground mt-0.5">Autonomy, beneficence, non-maleficence, justice, fidelity</p>
          </div>
          {open.principles ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.principles && (
          <div className="border-t border-purple-100 p-4 bg-purple-50 space-y-1 text-xs">
            <ul className="space-y-1.5 text-muted-foreground">
              <li>• <span className="font-semibold text-purple-700">Autonomy:</span> Patient's right to self-determination. Requires capacity, voluntariness, and adequate information.</li>
              <li>• <span className="font-semibold text-purple-700">Beneficence:</span> Obligation to act in the patient's best interest.</li>
              <li>• <span className="font-semibold text-purple-700">Non-maleficence:</span> 'Primum non nocere' — first, do no harm. Balance with beneficence in shared decision-making.</li>
              <li>• <span className="font-semibold text-purple-700">Justice:</span> Fair allocation of resources; equal treatment of equals.</li>
              <li>• <span className="font-semibold text-purple-700">Fidelity / Veracity:</span> Truth-telling and keeping promises.</li>
              <li>• <span className="font-semibold text-purple-700">Confidentiality:</span> Honoring trust by protecting patient information.</li>
            </ul>
          </div>
        )}
      </div>

      {/* 2. Informed Consent and Capacity */}
      <div className="rounded-2xl border border-blue-200 bg-card overflow-hidden">
        <button onClick={() => toggle('consent')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-blue-50 active:scale-[0.99] transition-all">
          <span className="text-xl">📋</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">2. Informed Consent &amp; Capacity</p>
            <p className="text-xs text-muted-foreground mt-0.5">Capacity vs competency, surrogate hierarchy, special situations</p>
          </div>
          {open.consent ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.consent && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div>
              <p className="font-bold text-blue-700 mb-1.5">Valid Informed Consent Requires</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>1. Capacity — understand, appreciate, reason, communicate a choice</li>
                <li>2. Voluntariness — free of coercion</li>
                <li>3. Adequate disclosure — diagnosis, intervention, risks/benefits, alternatives, expected outcomes</li>
                <li>4. Understanding</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-blue-700 mb-1.5">Capacity Assessment</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• Capacity is decision-specific (not global); determined clinically. Competency is a legal determination.</li>
                <li>• MacArthur Tool: understanding, appreciation, reasoning, choice</li>
                <li>• Surrogate hierarchy: written directive → court guardian → healthcare proxy/POA → spouse → adult children → parents → adult siblings</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-blue-700 mb-1.5">Special Situations</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• Emergency: implied consent when capacity absent and no surrogate available</li>
                <li>• Pediatric: children &lt;18 cannot consent (except emancipated minors); obtain assent when developmentally appropriate</li>
                <li>• Jehovah's Witnesses: adults may refuse blood — document, use blood conservation strategies. For minors, ethics committee and judicial review.</li>
                <li>• Pregnancy: maternal autonomy respected; ethics committee in complex cases</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 3. DNR in the Perioperative Setting */}
      <div className="rounded-2xl border border-red-200 bg-card overflow-hidden">
        <button onClick={() => toggle('dnr')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-red-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🚫</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">3. DNR in the Perioperative Setting</p>
            <p className="text-xs text-muted-foreground mt-0.5">Required reconsideration, 3 options, documentation</p>
          </div>
          {open.dnr ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.dnr && (
          <div className="border-t border-red-100 p-4 bg-red-50 space-y-2 text-xs">
            <p className="text-muted-foreground">ASA, ACS, and AORN endorse 'Required Reconsideration': DNR orders should NOT be automatically suspended for surgery.</p>
            <p className="font-bold text-red-700">Three Options After Discussion</p>
            <ul className="space-y-1 text-muted-foreground">
              <li>1. Full attempt at resuscitation</li>
              <li>2. Limited attempt — define specific procedures (e.g., no chest compressions, no defibrillation, no intubation)</li>
              <li>3. Limited attempt with respect to goals — anesthesiologist uses clinical judgment within stated goals</li>
            </ul>
          </div>
        )}
      </div>

      {/* 4. End-of-Life and Futility */}
      <div className="rounded-2xl border border-orange-200 bg-card overflow-hidden">
        <button onClick={() => toggle('eol')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-orange-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🕊️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">4. End-of-Life &amp; Futility</p>
            <p className="text-xs text-muted-foreground mt-0.5">Withholding vs withdrawing, palliative sedation, organ donation</p>
          </div>
          {open.eol ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.eol && (
          <div className="border-t border-orange-100 p-4 bg-orange-50 space-y-1 text-xs">
            <ul className="space-y-1.5 text-muted-foreground">
              <li>• Withholding and withdrawing life-sustaining treatment are ethically and legally equivalent</li>
              <li>• Futility is contested; involve palliative care and ethics consultation for disputes</li>
              <li>• Palliative sedation for refractory symptoms is permissible (doctrine of double effect — intent matters)</li>
              <li>• Physician-assisted dying is legal in select jurisdictions with specific safeguards</li>
              <li>• Organ donation after circulatory death: separate care teams, family discussion, protocol adherence</li>
            </ul>
          </div>
        )}
      </div>

      {/* 5. Confidentiality and HIPAA */}
      <div className="rounded-2xl border border-teal-200 bg-card overflow-hidden">
        <button onClick={() => toggle('hipaa')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-teal-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🔒</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">5. Confidentiality &amp; HIPAA</p>
            <p className="text-xs text-muted-foreground mt-0.5">PHI disclosure rules, minimum necessary, breach reporting</p>
          </div>
          {open.hipaa ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.hipaa && (
          <div className="border-t border-teal-100 p-4 bg-teal-50 space-y-1 text-xs">
            <ul className="space-y-1.5 text-muted-foreground">
              <li>• PHI may be disclosed only for treatment, payment, healthcare operations, and limited exceptions (reportable diseases, abuse, court orders)</li>
              <li>• Discuss patients only in private settings — avoid hallway, elevator, social media (even without names — incidental identification possible)</li>
              <li>• Minimum necessary information principle</li>
              <li>• Breaches must be reported per institutional policy</li>
            </ul>
          </div>
        )}
      </div>

      {/* 6. Error Disclosure and Just Culture */}
      <div className="rounded-2xl border border-yellow-200 bg-card overflow-hidden">
        <button onClick={() => toggle('error')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-yellow-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🔍</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">6. Error Disclosure &amp; Just Culture</p>
            <p className="text-xs text-muted-foreground mt-0.5">Console/coach/punish framework, disclosure components</p>
          </div>
          {open.error ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.error && (
          <div className="border-t border-yellow-100 p-4 bg-yellow-50 space-y-3 text-xs">
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">Just Culture Framework</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• <span className="font-semibold">Human error</span> → Console</li>
                <li>• <span className="font-semibold">At-risk behavior</span> → Coach</li>
                <li>• <span className="font-semibold">Reckless behavior</span> → Punish</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">Disclosure Must Include</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• What happened (clear, plain language)</li>
                <li>• An apology</li>
                <li>• What is being done to address the situation</li>
                <li>• What is being done to prevent recurrence</li>
                <li>• Follow-up plan</li>
                <li>• 'I'm sorry' laws in many jurisdictions protect disclosures</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 7. Patient Safety and QI */}
      <div className="rounded-2xl border border-green-200 bg-card overflow-hidden">
        <button onClick={() => toggle('safety')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-green-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🛡️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">7. Patient Safety &amp; Quality Improvement</p>
            <p className="text-xs text-muted-foreground mt-0.5">Swiss cheese model, RCA, FMEA, SBAR, CRM</p>
          </div>
          {open.safety ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.safety && (
          <div className="border-t border-green-100 p-4 bg-green-50 space-y-1 text-xs">
            <ul className="space-y-1.5 text-muted-foreground">
              <li>• <span className="font-semibold text-green-700">Swiss Cheese Model (Reason):</span> Errors penetrate when holes in multiple barriers align</li>
              <li>• <span className="font-semibold text-green-700">RCA (Root Cause Analysis):</span> Structured retrospective review to identify systemic contributors to adverse events</li>
              <li>• <span className="font-semibold text-green-700">FMEA:</span> Prospective identification of failure points</li>
              <li>• <span className="font-semibold text-green-700">PDSA cycles:</span> Plan-Do-Study-Act iterative improvement</li>
              <li>• <span className="font-semibold text-green-700">SBAR:</span> Situation, Background, Assessment, Recommendation — improves handoffs</li>
              <li>• <span className="font-semibold text-green-700">CRM (Crew Resource Management):</span> Aviation-derived teamwork, communication, situational awareness</li>
              <li>• <span className="font-semibold text-green-700">Closed-loop communication:</span> Sender → receiver acknowledges/repeats → sender confirms</li>
            </ul>
          </div>
        )}
      </div>

      {/* 8. Medication Safety */}
      <div className="rounded-2xl border border-rose-200 bg-card overflow-hidden">
        <button onClick={() => toggle('medsafety')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-rose-50 active:scale-[0.99] transition-all">
          <span className="text-xl">💊</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">8. Medication Safety &amp; High-Alert Medications</p>
            <p className="text-xs text-muted-foreground mt-0.5">ISMP list, syringe swaps, color-coded labels, smart pumps</p>
          </div>
          {open.medsafety ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.medsafety && (
          <div className="border-t border-rose-100 p-4 bg-rose-50 space-y-1 text-xs">
            <ul className="space-y-1.5 text-muted-foreground">
              <li>• <span className="font-semibold text-rose-700">ISMP High-Alert Medications:</span> insulin, heparin, opioids, NMBs, concentrated electrolytes, vasopressors, anticoagulants, chemotherapy</li>
              <li>• Anesthesia workstation drugs NOT pre-screened by pharmacy — extra vigilance required</li>
              <li>• Read labels twice; use color-coded syringes per ASA/ISO standards; prepare one medication at a time</li>
              <li>• Smart pumps with drug libraries reduce dosing errors</li>
              <li>• Standardized concentrations and pre-filled syringes reduce errors</li>
              <li>• Common errors: syringe swaps, wrong-route, calculation mistakes, look-alike/sound-alike drugs</li>
            </ul>
          </div>
        )}
      </div>

      {/* 9. Wrong-Site / Wrong-Patient Surgery */}
      <div className="rounded-2xl border border-indigo-200 bg-card overflow-hidden">
        <button onClick={() => toggle('wrongsite')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-indigo-50 active:scale-[0.99] transition-all">
          <span className="text-xl">✅</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">9. Wrong-Site / Wrong-Patient Surgery</p>
            <p className="text-xs text-muted-foreground mt-0.5">Universal Protocol, time-out, 'never event'</p>
          </div>
          {open.wrongsite ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.wrongsite && (
          <div className="border-t border-indigo-100 p-4 bg-indigo-50 space-y-1 text-xs">
            <p className="font-bold text-indigo-700 mb-1.5">Universal Protocol (Joint Commission) — 3 Steps</p>
            <ul className="space-y-1.5 text-muted-foreground">
              <li>1. Preoperative verification of patient, procedure, and site</li>
              <li>2. Marking of operative site by surgeon with patient involvement</li>
              <li>3. Time-out immediately before incision involving the entire team — any member can stop the procedure</li>
              <li>• Wrong-site surgery is a 'never event' (CMS) — non-reimbursable and reportable</li>
              <li>• Most common cause: communication failure and inadequate site verification</li>
            </ul>
          </div>
        )}
      </div>

      {/* 10. Substance Use Disorder */}
      <div className="rounded-2xl border border-amber-200 bg-card overflow-hidden">
        <button onClick={() => toggle('sud')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-amber-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🩺</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">10. Substance Use Disorder Among Anesthesiologists</p>
            <p className="text-xs text-muted-foreground mt-0.5">Prevalence, signs, reporting duty, PHP programs</p>
          </div>
          {open.sud ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.sud && (
          <div className="border-t border-amber-100 p-4 bg-amber-50 space-y-1 text-xs">
            <ul className="space-y-1.5 text-muted-foreground">
              <li>• Anesthesiology has higher SUD rates than most specialties — estimated 10–14% lifetime prevalence</li>
              <li>• Fentanyl and other opioids most commonly diverted</li>
              <li>• Signs: unexplained absences, mood/behavior changes, requests for solo cases, missing controlled substances, pinpoint pupils, declining performance</li>
              <li>• Colleague reporting is an ethical duty</li>
              <li>• State Physician Health Programs: confidential evaluation, treatment, and monitoring</li>
              <li>• Outcomes with appropriate treatment are excellent</li>
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
            <p className="text-xs text-muted-foreground mt-0.5">35 high-yield ethics, professionalism &amp; patient safety items</p>
          </div>
          {open.practice ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {open.practice && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Key High-Yield Topics</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• DNR 'required reconsideration' — never automatically suspend; three options</li>
                <li>• Valid consent = capacity + voluntariness + disclosure + understanding (NOT just a signature)</li>
                <li>• Capacity is decision-specific; competency is a legal determination</li>
                <li>• Surrogate hierarchy: written directive → guardian → POA → spouse → adult children → parents</li>
                <li>• Jehovah's Witness adults may refuse blood — document and use blood conservation strategies</li>
                <li>• Just culture: human error (console), at-risk (coach), reckless (punish)</li>
                <li>• Error disclosure: factual, compassionate, commit to investigation and prevention</li>
                <li>• Universal Protocol: verify → mark → time-out; any team member can stop</li>
                <li>• Wrong-site surgery is a CMS 'never event' — non-reimbursable and reportable</li>
                <li>• RCA = retrospective systemic review; FMEA = prospective failure identification</li>
                <li>• SBAR: Situation, Background, Assessment, Recommendation</li>
                <li>• High-alert ISMP meds: insulin, heparin, opioids, NMBs, concentrated electrolytes, vasopressors</li>
                <li>• SUD in anesthesiology 10–14% lifetime; fentanyl most commonly diverted; reporting is an ethical duty</li>
                <li>• Withholding = withdrawing life-sustaining treatment (ethically and legally equivalent)</li>
                <li>• Near-miss reporting drives improvement — report even when no harm occurred</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Study Tips */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200">
        <p className="text-xs font-bold text-emerald-700 mb-2">💡 Study Strategy — Final Module</p>
        <ul className="space-y-1 text-xs text-muted-foreground">
          <li>• Ethics questions test application, not memorization — focus on the right process</li>
          <li>• For consent scenarios: always assess capacity first, then find surrogate if lacking</li>
          <li>• DNR: never assume suspend; always required reconsideration discussion</li>
          <li>• Wrong site: any team member can call a stop — this is explicitly tested</li>
          <li>• Congratulations — you've completed all 7 ABA ADVANCED Board Review modules!</li>
        </ul>
      </div>
    </div>
  );
}