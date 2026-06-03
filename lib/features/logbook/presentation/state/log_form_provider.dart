import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../widgets/hypo_timer_overlay.dart';
import '../../domain/entities/glucose_log.dart';
import '../../data/datasources/logbook_local_data_source.dart';
import '../../data/repositories/logbook_repository_impl.dart';
import '../../data/models/glucose_log_model.dart';

class LogFormState {
  final String? bloodGlucose;
  final String? insulin;
  final String? carbs;
  final String mealTag;
  final Color bgFieldColor;

  LogFormState({
    this.bloodGlucose,
    this.insulin,
    this.carbs,
    this.mealTag = 'Pre-Meal',
    this.bgFieldColor = Colors.transparent, // Default before submission
  });

  LogFormState copyWith({
    String? bloodGlucose,
    String? insulin,
    String? carbs,
    String? mealTag,
    Color? bgFieldColor,
  }) {
    return LogFormState(
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      insulin: insulin ?? this.insulin,
      carbs: carbs ?? this.carbs,
      mealTag: mealTag ?? this.mealTag,
      bgFieldColor: bgFieldColor ?? this.bgFieldColor,
    );
  }
}

class LogFormNotifier extends Notifier<LogFormState> {
  @override
  LogFormState build() {
    return LogFormState();
  }

  void updateField({String? bg, String? insulin, String? carbs}) {
    state = state.copyWith(
      bloodGlucose: bg,
      insulin: insulin,
      carbs: carbs,
    );
  }

  void updateMealTag(String tag) {
    state = state.copyWith(mealTag: tag);
  }

  // Evaluates BG ONLY when called (e.g., on focus lost), fixing the 1-digit bug
  void evaluateBloodGlucose(BuildContext context) {
    if (state.bloodGlucose == null || state.bloodGlucose!.isEmpty) {
      state = state.copyWith(bgFieldColor: Colors.transparent);
      return;
    }

    final bgValue = double.tryParse(state.bloodGlucose!);
    if (bgValue == null) return;

    Color newColor;
    if (bgValue < 70) {
      newColor = Colors.red.shade100;
      _triggerHypoOverlay(context);
    } else if (bgValue > 180) {
      newColor = Colors.yellow.shade100;
    } else {
      newColor = Colors.green.shade100;
    }

    state = state.copyWith(bgFieldColor: newColor);
  }

  void _triggerHypoOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HypoTimerOverlay(),
    );
  }

  Future<void> saveEntry() async {
    // 1. Validation: Abort if all fields are empty/null
    final isBgEmpty = state.bloodGlucose == null || state.bloodGlucose!.isEmpty;
    final isInsulinEmpty = state.insulin == null || state.insulin!.isEmpty;
    final isCarbsEmpty = state.carbs == null || state.carbs!.isEmpty;

    if (isBgEmpty && isInsulinEmpty && isCarbsEmpty) {
      return;
    }

    // 2. Entity Creation: Parse values into strict types
        final bgInt = int.tryParse(state.bloodGlucose ?? '');
        final insulinDouble = double.tryParse(state.insulin ?? '');
        final carbsInt = int.tryParse(state.carbs ?? '');

        final newLog = GlucoseLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: 'local_user',
          glucoseMgdl: bgInt ?? 0,
          insulinUnits: insulinDouble ?? 0.0, // <-- Fixed: Falls back to 0.0
          carbsGrams: carbsInt ?? 0,          // <-- Fixed: Falls back to 0
          contextTags: [state.mealTag],
          localTimestamp: DateTime.now(),
          isSynced: false,
        );

    // 3. Repository Injection
    final box = Hive.box<GlucoseLogModel>('glucose_logs');
    final dataSource = LogbookLocalDataSourceImpl(logBox: box);
    final repository = LogbookRepositoryImpl(localDataSource: dataSource);

    // 4. Execution
    await repository.saveLog(newLog);

    // 5. Cleanup: Clear the form fields for the next entry
    state = LogFormState();
  }
}

// Using the modern Riverpod 2.0+ syntax
final logFormProvider = NotifierProvider<LogFormNotifier, LogFormState>(LogFormNotifier.new);