// lib/features/logbook/data/datasources/logbook_local_data_source.dart
import 'package:hive/hive.dart';
import '../models/glucose_log_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class LogbookLocalDataSource {
  Future<void> cacheLogEntry(GlucoseLogModel log);
  Future<List<GlucoseLogModel>> getUnsyncedLogs();
  Future<List<GlucoseLogModel>> getAllLogs();
  Future<void> updateSyncStatus(String id);
}

class LogbookLocalDataSourceImpl implements LogbookLocalDataSource {
  final Box<GlucoseLogModel> logBox;

  LogbookLocalDataSourceImpl({required this.logBox});

  @override
  Future<void> cacheLogEntry(GlucoseLogModel log) async {
    try {
      // Using the unique ID as the Hive key for fast retrieval and updates
      await logBox.put(log.id, log);
    } catch (e) {
      throw CacheException('Failed to cache log entry in Hive: $e');
    }
  }

  @override
  Future<List<GlucoseLogModel>> getUnsyncedLogs() async {
    try {
      return logBox.values.where((log) => !log.isSynced).toList();
    } catch (e) {
      throw CacheException('Failed to fetch unsynced logs: $e');
    }
  }

  @override
  Future<List<GlucoseLogModel>> getAllLogs() async {
    try {
      return logBox.values.toList()
        ..sort((a, b) => b.localTimestamp.compareTo(a.localTimestamp)); // Newest first
    } catch (e) {
      throw CacheException('Failed to fetch all logs: $e');
    }
  }

  @override
  Future<void> updateSyncStatus(String id) async {
    try {
      final log = logBox.get(id);
      if (log != null) {
        // Create an updated copy with isSynced = true
        final updatedLog = GlucoseLogModel(
          id: log.id,
          patientId: log.patientId,
          localTimestamp: log.localTimestamp,
          glucoseMgdl: log.glucoseMgdl,
          insulinUnits: log.insulinUnits,
          carbsGrams: log.carbsGrams,
          contextTags: log.contextTags,
          localPhotoPath: log.localPhotoPath,
          cloudPhotoUrl: log.cloudPhotoUrl,
          isSynced: true, // Updated status
        );
        await logBox.put(id, updatedLog);
      } else {
        throw CacheException('Log with id $id not found for sync update.');
      }
    } catch (e) {
      throw CacheException('Failed to update sync status: $e');
    }
  }
}