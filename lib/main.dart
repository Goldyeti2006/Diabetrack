import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/logbook/data/models/glucose_log_model.dart';
import 'features/logbook/presentation/pages/logbook_dashboard.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the local offline database
  await Hive.initFlutter();

  // 3. Register the generated Hive adapter for your data model
  Hive.registerAdapter(GlucoseLogModelAdapter());

  // 4. Open the specific box (table) for the logs
  await Hive.openBox<GlucoseLogModel>('glucose_logs');

  // 5. Run the app
  runApp(const ProviderScope(child: GlucoKidsApp()));
}

class GlucoKidsApp extends StatelessWidget {
  const GlucoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoKids',
      debugShowCheckedModeBanner: false,
      // We will define the Stitch theme directly in the new UI files
      home: const LogbookDashboard(),
    );
  }
}