// lib/features/logbook/domain/entities/glucose_log.dart
class GlucoseLog {
  final String id;
  final String patientId;
  final DateTime localTimestamp;
  final int glucoseMgdl;
  final double insulinUnits;
  final int carbsGrams;
  final List<String> contextTags;
  final String? localPhotoPath;
  final String? cloudPhotoUrl;
  final bool isSynced;

  GlucoseLog({
    required this.id,
    required this.patientId,
    required this.localTimestamp,
    required this.glucoseMgdl,
    required this.insulinUnits,
    required this.carbsGrams,
    required this.contextTags,
    this.localPhotoPath,
    this.cloudPhotoUrl,
    required this.isSynced,
  });
}