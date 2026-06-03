// lib/features/logbook/data/repositories/logbook_repository_impl.dart
import 'dart:convert';
import '../../domain/entities/glucose_log.dart';
import '../../domain/repositories/logbook_repository.dart';
import '../datasources/logbook_local_data_source.dart';
import '../models/glucose_log_model.dart';
import '../../../../core/error/exceptions.dart';

class LogbookRepositoryImpl implements LogbookRepository {
  final LogbookLocalDataSource localDataSource;

  LogbookRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveLog(GlucoseLog log) async {
    try {
      // 1. Convert purely to data model
      // 2. Force isSynced to false because it is a new entry
      final model = GlucoseLogModel.fromEntity(log);
      final unsyncedModel = GlucoseLogModel(
        id: model.id,
        patientId: model.patientId,
        localTimestamp: model.localTimestamp,
        glucoseMgdl: model.glucoseMgdl,
        insulinUnits: model.insulinUnits,
        carbsGrams: model.carbsGrams,
        contextTags: model.contextTags,
        localPhotoPath: model.localPhotoPath,
        cloudPhotoUrl: model.cloudPhotoUrl,
        isSynced: false,
      );

      // 3. Save instantly to local cache (Offline First)
      await localDataSource.cacheLogEntry(unsyncedModel);

      // Note: We could trigger a sync operation here in the background,
      // but keeping it decoupled for a dedicated background worker is cleaner.
    } on CacheException catch (e) {
      // In a full implementation, you'd return an Either<Failure, void> (using dartz/fpdart)
      // Throwing for now to satisfy simple interface
      throw Exception('Repository Error: ${e.message}');
    }
  }

  @override
  Future<void> syncPendingLogs() async {
    try {
      // 1. Fetch all unsynced items from Hive
      final pendingLogs = await localDataSource.getUnsyncedLogs();

      if (pendingLogs.isEmpty) {
        print("SYNC QUEUE: No pending logs to sync.");
        return;
      }

      print("SYNC QUEUE: Found ${pendingLogs.length} pending logs. Starting sync...");

      // 2. Iterate and attempt to "upload"
      for (final log in pendingLogs) {
        // MOCK UPLOAD: Convert to JSON and print
        final jsonPayload = jsonEncode(log.toJson());
        print("UPLOADING TO FIRESTORE: $jsonPayload");

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        // 3. On "success", update local database status
        await localDataSource.updateSyncStatus(log.id);
        print("SUCCESS: Log ${log.id} marked as synced.");
      }

      print("SYNC QUEUE: All pending logs synchronized.");

    } on CacheException catch (e) {
      print("SYNC QUEUE ERROR: ${e.message}");
      // Do not crash the app on sync failure, just fail gracefully so it tries again later
    }
  }
  @override
   Future<List<GlucoseLog>> getAllLogs() async {
      try {
        return await localDataSource.getAllLogs();
      } catch (e) {
        throw CacheException('Failed to get all logs in repository: $e');
      }
    }

   @override
   Future<List<GlucoseLog>> getUnsyncedLogs() async {
      try {
        return await localDataSource.getUnsyncedLogs();
      } catch (e) {
        throw CacheException('Failed to get unsynced logs in repository: $e');
      }
    }

   @override
   Future<void> updateSyncStatus(String id) async {
      try {
        await localDataSource.updateSyncStatus(id);
      } catch (e) {
        throw CacheException('Failed to update sync status in repository: $e');
      }
    }
}