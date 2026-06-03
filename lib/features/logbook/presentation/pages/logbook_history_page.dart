import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/glucose_log_model.dart';
import '../state/log_history_provider.dart';

class LogbookHistoryPage extends ConsumerWidget {
  const LogbookHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsyncValue = ref.watch(logHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Log History',
          style: GoogleFonts.atkinsonHyperlegible(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: false,
      ),
      body: logsAsyncValue.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Text(
                'No logs found.',
                style: GoogleFonts.atkinsonHyperlegible(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return LogCard(log: log);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading logs: $error',
            style: GoogleFonts.atkinsonHyperlegible(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class LogCard extends StatelessWidget {
  final GlucoseLogModel log;

  const LogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final isEmergencyLow = log.glucoseMgdl < 70;
    final isHigh = log.glucoseMgdl > 180;

    // Traffic Light Logic
    Color glucoseColor = Colors.green;
    if (isEmergencyLow) {
      glucoseColor = Colors.red;
    } else if (isHigh) {
      glucoseColor = Colors.amber[700]!; // Using amber-700 for better contrast on white than plain yellow
    }

    final dateFormat = DateFormat('MMM d, h:mm a');
    final formattedDate = dateFormat.format(log.localTimestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isEmergencyLow
            ? const BorderSide(color: Colors.red, width: 3)
            : BorderSide.none,
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date/Time & Status Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.atkinsonHyperlegible(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEmergencyLow)
                  Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'EMERGENCY LOW',
                        style: GoogleFonts.atkinsonHyperlegible(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  Icon(
                    log.isSynced ? Icons.cloud_done : Icons.cloud_upload,
                    color: log.isSynced ? Colors.green : Colors.grey[400],
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Row: Glucose, Insulin, Carbs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${log.glucoseMgdl}',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: glucoseColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'mg/dL',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (log.insulinUnits != null && log.insulinUnits! > 0)
                      Text(
                        '${log.insulinUnits} U',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    if (log.carbsGrams != null && log.carbsGrams! > 0)
                      Text(
                        '${log.carbsGrams}g Carbs',
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[800],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Bottom Row: Context Tags
            if (log.contextTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: log.contextTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}