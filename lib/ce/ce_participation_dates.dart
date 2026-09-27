/// Date-only registration values are stored as ISO dates, never timestamps.
DateTime? parseCeParticipationDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null || parsed.toIso8601String().substring(0, 10) != value) {
    return null;
  }
  return parsed;
}

String? validateCeParticipationDates(
  String start,
  String end, {
  bool preview = false,
  DateTime? now,
}) {
  // Registration can be saved before participation is finished.
  if (start.isEmpty && end.isEmpty) return null;
  final first = parseCeParticipationDate(start);
  final last = parseCeParticipationDate(end);
  if (first == null || last == null) return 'Enter both dates as YYYY-MM-DD.';
  if (first.isBefore(DateTime(2026, 10, 1)) ||
      last.isAfter(DateTime(2029, 9, 30))) {
    return 'Dates must fall between 2026-10-01 and 2029-09-30.';
  }
  if (last.isBefore(first)) return 'End date cannot be before start date.';
  final today = now ?? DateTime.now();
  if (!preview && last.isAfter(DateTime(today.year, today.month, today.day))) {
    return 'Enter actual participation dates, not future dates.';
  }
  return null;
}
