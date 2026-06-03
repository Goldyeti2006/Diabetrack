import '../entities/glucose_log.dart';

abstract class LogbookRepository {
  Future<void> saveLog(GlucoseLog log);
  Future<List<GlucoseLog>> getAllLogs();
  Future<List<GlucoseLog>> getUnsyncedLogs();
  Future<void> updateSyncStatus(String id);
}