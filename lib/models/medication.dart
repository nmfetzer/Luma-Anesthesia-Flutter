// -----------------------------------------------------------------------------
// Medication — matches the Base44 `Medication` entity schema.
//
// Only the fields the Drugs flow needs right now are typed. The full record
// includes deep-dive markdown, references, etc.; those come in a follow-up
// once the Drug Detail screen is built.
// -----------------------------------------------------------------------------

class Medication {
  final String id;
  final String name;
  final String? brandName;
  final String? classShort;
  final String category;
  final bool highAlert;
  final String? deaSchedule;
  final String? adultDose;
  final String? pedsDose;
  final String? onsetDuration;
  final String? blackBoxWarning;

  const Medication({
    required this.id,
    required this.name,
    required this.category,
    this.brandName,
    this.classShort,
    this.highAlert = false,
    this.deaSchedule,
    this.adultDose,
    this.pedsDose,
    this.onsetDuration,
    this.blackBoxWarning,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        category: (json['category'] ?? '').toString(),
        brandName: (json['brand_name'] as String?)?.trim().isEmpty == true
            ? null
            : json['brand_name'] as String?,
        classShort: json['class_short'] as String?,
        highAlert: json['high_alert'] == true,
        deaSchedule: json['dea_schedule'] as String?,
        adultDose: json['adult_dose'] as String?,
        pedsDose: json['peds_dose'] as String?,
        onsetDuration: json['onset_duration'] as String?,
        blackBoxWarning: (json['black_box_warning'] as String?)?.trim().isEmpty ==
                true
            ? null
            : json['black_box_warning'] as String?,
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
