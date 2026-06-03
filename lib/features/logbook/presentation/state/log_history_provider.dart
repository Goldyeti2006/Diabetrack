import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/glucose_log_model.dart';
import '../../data/datasources/logbook_local_data_source.dart';
import 'package:hive/hive.dart';
// Assuming you have a provider for your data source.
// If not, instantiate it directly or adjust this to match your DI setup.
final logbookLocalDataSourceProvider = Provider<LogbookLocalDataSourceImpl>((ref) {
  return LogbookLocalDataSourceImpl(
  logBox: Hive.box<GlucoseLogModel>('glucose_logs'),
  );
});

final logHistoryProvider = AsyncNotifierProvider<LogHistoryNotifier, List<GlucoseLogModel>>(() {
  return LogHistoryNotifier();
});

class LogHistoryNotifier extends AsyncNotifier<List<GlucoseLogModel>> {
  @override
  Future<List<GlucoseLogModel>> build() async {
    return _fetchLogs();
  }

  Future<List<GlucoseLogModel>> _fetchLogs() async {
    final dataSource = ref.read(logbookLocalDataSourceProvider);
    return await dataSource.getAllLogs();
  }

  /// Call this when a new entry is added to refresh the history list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLogs());
  }
}