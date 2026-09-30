import '../billing/ce_billing.dart';

/// Benefits reflect the published course catalogs, not invented outcomes.
class CePaywallCopy {
  const CePaywallCopy(this.kicker, this.description, this.highlights);
  final String kicker;
  final String description;
  final List<String> highlights;

  static const byProduct = {
    CeProduct.medication: CePaywallCopy(
      'MEDICATION REVIEW',
      'A focused pharmacology refresh for the experienced anesthesia professional.',
      [
        'Perioperative medications, interactions and patient-specific considerations',
        'GLP-1 agents, neuromuscular blockade, reversal and multimodal analgesia',
        'Course lessons, knowledge assessments and module evaluations',
      ],
    ),
    CeProduct.uncommon: CePaywallCopy(
      'UNCOMMON ANESTHESIA EVENTS',
      'Build a deeper understanding of complex and high-consequence perioperative events.',
      [
        'Malignant hyperthermia, LAST, amniotic fluid embolism and OR fire',
        'Complex care involving pheochromocytoma, blood refusal and hemostasis',
        'Course lessons, knowledge assessments and module evaluations',
      ],
    ),
    CeProduct.legal: CePaywallCopy(
      'LEGAL ESSENTIALS',
      'Explore the legal and professional responsibilities that shape anesthesia practice.',
      [
        'Scope of practice, informed consent and defensible documentation',
        'Malpractice, medication errors, privacy and just-culture response',
        'Course lessons, knowledge assessments and module evaluations',
      ],
    ),
    CeProduct.bundle: CePaywallCopy(
      'THE THREE-COURSE COLLECTION',
      'Three complementary courses. One purchase for your continuing education.',
      [
        'A Medication Review for the Experienced CRNA',
        'Uncommon but Catastrophic Anesthesia Events',
        'Legal Essentials for the CRNA',
      ],
    ),
  };
}
