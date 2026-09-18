// -----------------------------------------------------------------------------
// Medication — full Base44 Medication entity schema.
// -----------------------------------------------------------------------------

class MedicationSource {
  final int? number;
  final String? tier;
  final String? type;
  final String? citation;
  final String? url;

  const MedicationSource({
    this.number,
    this.tier,
    this.type,
    this.citation,
    this.url,
  });

  factory MedicationSource.fromJson(Map<String, dynamic> j) => MedicationSource(
        number: j['number'] is int
            ? j['number'] as int
            : int.tryParse('${j['number'] ?? ''}'),
        tier: j['tier'] as String?,
        type: j['type'] as String?,
        citation: j['citation'] as String?,
        url: j['url'] as String?,
      );
}

class Medication {
  // Identity
  final String id;
  final String name;
  final String? brandName;
  final String? classShort;
  final String? classification;
  final String category;
  final List<String> secondaryCategories;

  // Warnings
  final bool highAlert;
  final String? deaSchedule;
  final String? blackBoxWarning;
  final String? lasaWarning;

  // Clinical narrative
  final String? indications;
  final String? mechanism;

  // Dosing
  final String? adultDose;
  final String? pedsDose;
  final num? doseMgPerKgMin;
  final num? doseMgPerKgMax;
  final String? doseUnit;
  final bool isInfusion;

  // Concentration & mixing
  final String? concentrationMixing;
  final bool requiresDilution;
  final String? targetConcentration;
  final String? standardRecipe;
  final num? finalVolumeMl;
  final String? diluent;
  final String? alternativeConcentrations;
  final num? stabilityHoursRoomTemp;
  final num? stabilityHoursRefrigerated;
  final String? mixingPearls;
  final String? notes;

  // Forms & routes
  final String? commonConcentrations;
  final String? dosageForms;
  final String? routes;

  // Timing
  final String? onsetDuration;
  final num? onsetMinutes;
  final num? durationMinutes;

  // Safety
  final String? contraindications;
  final String? sideEffects;
  final String? seriousEffects;
  final String? drugInteractions;
  final List<String> interactionsCritical;

  // Admin
  final String? administrationDetails;
  final String? specialPopulations;
  final String? pregnancyLactation;
  final String? warningsPrecautions;
  final String? pharmacokinetics;
  final String? antidoteReversal;
  final String? clinicalPearls;
  final String? specialConsiderations;

  // Monitoring
  final List<String> monitoringParameters;

  // Premium
  final String? deepDiveContent;

  // Citations
  final List<MedicationSource> sources;

  // Review metadata
  final String? lastReviewed;
  final String? clinicalReviewer;
  final int? reviewCycleMonths;

  const Medication({
    required this.id,
    required this.name,
    required this.category,
    this.brandName,
    this.classShort,
    this.classification,
    this.secondaryCategories = const [],
    this.highAlert = false,
    this.deaSchedule,
    this.blackBoxWarning,
    this.lasaWarning,
    this.indications,
    this.mechanism,
    this.adultDose,
    this.pedsDose,
    this.doseMgPerKgMin,
    this.doseMgPerKgMax,
    this.doseUnit,
    this.isInfusion = false,
    this.concentrationMixing,
    this.requiresDilution = false,
    this.targetConcentration,
    this.standardRecipe,
    this.finalVolumeMl,
    this.diluent,
    this.alternativeConcentrations,
    this.stabilityHoursRoomTemp,
    this.stabilityHoursRefrigerated,
    this.mixingPearls,
    this.notes,
    this.commonConcentrations,
    this.dosageForms,
    this.routes,
    this.onsetDuration,
    this.onsetMinutes,
    this.durationMinutes,
    this.contraindications,
    this.sideEffects,
    this.seriousEffects,
    this.drugInteractions,
    this.interactionsCritical = const [],
    this.administrationDetails,
    this.specialPopulations,
    this.pregnancyLactation,
    this.warningsPrecautions,
    this.pharmacokinetics,
    this.antidoteReversal,
    this.clinicalPearls,
    this.specialConsiderations,
    this.monitoringParameters = const [],
    this.deepDiveContent,
    this.sources = const [],
    this.lastReviewed,
    this.clinicalReviewer,
    this.reviewCycleMonths,
  });

  static String? _nullIfBlank(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return s;
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString())
          .toList();
    }
    return const [];
  }

  static num? _num(dynamic v) {
    if (v == null || (v is String && v.trim().isEmpty)) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  static int? _int(dynamic v) {
    if (v == null || (v is String && v.trim().isEmpty)) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        brandName: _nullIfBlank(j['brand_name']),
        classShort: _nullIfBlank(j['class_short']),
        classification: _nullIfBlank(j['classification']),
        secondaryCategories: _stringList(j['secondary_categories']),
        highAlert: j['high_alert'] == true,
        deaSchedule: _nullIfBlank(j['dea_schedule']),
        blackBoxWarning: _nullIfBlank(j['black_box_warning']),
        lasaWarning: _nullIfBlank(j['lasa_warning']),
        indications: _nullIfBlank(j['indications']),
        mechanism: _nullIfBlank(j['mechanism']),
        adultDose: _nullIfBlank(j['adult_dose']),
        pedsDose: _nullIfBlank(j['peds_dose']),
        doseMgPerKgMin: _num(j['dose_mg_per_kg_min']),
        doseMgPerKgMax: _num(j['dose_mg_per_kg_max']),
        doseUnit: _nullIfBlank(j['dose_unit']),
        isInfusion: j['is_infusion'] == true,
        concentrationMixing: _nullIfBlank(j['concentration_mixing']),
        requiresDilution: j['requires_dilution'] == true,
        targetConcentration: _nullIfBlank(j['target_concentration']),
        standardRecipe: _nullIfBlank(j['standard_recipe']),
        finalVolumeMl: _num(j['final_volume_ml']),
        diluent: _nullIfBlank(j['diluent']),
        alternativeConcentrations: _nullIfBlank(j['alternative_concentrations']),
        stabilityHoursRoomTemp: _num(j['stability_hours_room_temp']),
        stabilityHoursRefrigerated: _num(j['stability_hours_refrigerated']),
        mixingPearls: _nullIfBlank(j['mixing_pearls']),
        notes: _nullIfBlank(j['notes']),
        commonConcentrations: _nullIfBlank(j['common_concentrations']),
        dosageForms: _nullIfBlank(j['dosage_forms']),
        routes: _nullIfBlank(j['routes']),
        onsetDuration: _nullIfBlank(j['onset_duration']),
        onsetMinutes: _num(j['onset_minutes']),
        durationMinutes: _num(j['duration_minutes']),
        contraindications: _nullIfBlank(j['contraindications']),
        sideEffects: _nullIfBlank(j['side_effects']),
        seriousEffects: _nullIfBlank(j['serious_effects']),
        drugInteractions: _nullIfBlank(j['drug_interactions']),
        interactionsCritical: _stringList(j['interactions_critical']),
        administrationDetails: _nullIfBlank(j['administration_details']),
        specialPopulations: _nullIfBlank(j['special_populations']),
        pregnancyLactation: _nullIfBlank(j['pregnancy_lactation']),
        warningsPrecautions: _nullIfBlank(j['warnings_precautions']),
        pharmacokinetics: _nullIfBlank(j['pharmacokinetics']),
        antidoteReversal: _nullIfBlank(j['antidote_reversal']),
        clinicalPearls: _nullIfBlank(j['clinical_pearls']),
        specialConsiderations: _nullIfBlank(j['special_considerations']),
        monitoringParameters: _stringList(j['monitoring_parameters']),
        deepDiveContent: _nullIfBlank(j['deep_dive_content']),
        sources: (j['sources'] is List)
            ? (j['sources'] as List)
                .whereType<Map>()
                .map((m) => MedicationSource.fromJson(
                    Map<String, dynamic>.from(m as Map)))
                .toList()
            : const [],
        lastReviewed: _nullIfBlank(j['last_reviewed']),
        clinicalReviewer: _nullIfBlank(j['clinical_reviewer']),
        reviewCycleMonths: _int(j['review_cycle_months']),
      );

  bool get isScheduled =>
      deaSchedule != null &&
      deaSchedule!.isNotEmpty &&
      deaSchedule != 'non_scheduled';

  String get deaLabel {
    switch (deaSchedule) {
      case 'c_i':
        return 'C-I';
      case 'c_ii':
        return 'C-II';
      case 'c_iii':
        return 'C-III';
      case 'c_iv':
        return 'C-IV';
      case 'c_v':
        return 'C-V';
      default:
        return '';
    }
  }
}
