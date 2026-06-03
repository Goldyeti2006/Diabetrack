import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/log_form_provider.dart';
import '../widgets/hypo_timer_overlay.dart';
import 'logbook_history_page.dart';

class LogbookDashboard extends ConsumerStatefulWidget {
  const LogbookDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<LogbookDashboard> createState() => _LogbookDashboardState();
}

class _LogbookDashboardState extends ConsumerState<LogbookDashboard> {
  final FocusNode _bgFocusNode = FocusNode();
  final TextEditingController _bgController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // CRITICAL: Evaluate BG only when focus is lost, preventing the 1-digit bug.
    _bgFocusNode.addListener(() {
      if (!_bgFocusNode.hasFocus) {
        ref.read(logFormProvider.notifier).evaluateBloodGlucose(context);
      }
    });
  }

  @override
  void dispose() {
    _bgFocusNode.dispose();
    _bgController.dispose();
    _insulinController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(logFormProvider);
    const primaryBlue = Color(0xFF0056B3);
    const surfaceWhite = Colors.white;
    const bgGray = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        backgroundColor: surfaceWhite,
        elevation: 0,
        title: Text(
          'Logbook',
          style: GoogleFonts.atkinsonHyperlegible(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: primaryBlue),
            onPressed: () {
                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LogbookHistoryPage(),
                                    ),
                                  );
            }, // Profile action
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New Log Entry',
                    style: GoogleFonts.atkinsonHyperlegible(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Blood Glucose Input (Traffic Light)
                  TextField(
                    controller: _bgController,
                    focusNode: _bgFocusNode,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => ref.read(logFormProvider.notifier).updateField(bg: val),
                    onSubmitted: (_) => ref.read(logFormProvider.notifier).evaluateBloodGlucose(context),
                    decoration: InputDecoration(
                      labelText: 'Blood Glucose (mg/dL)',
                      labelStyle: GoogleFonts.atkinsonHyperlegible(),
                      filled: true,
                      fillColor: formState.bgFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: formState.bgFieldColor == Colors.transparent
                              ? Colors.grey.shade400
                              : formState.bgFieldColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChoiceChip('Pre-Meal', formState.mealTag, primaryBlue),
                      const SizedBox(width: 12),
                      _buildChoiceChip('Post-Meal', formState.mealTag, primaryBlue),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Insulin & Carbs Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _insulinController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) => ref.read(logFormProvider.notifier).updateField(insulin: val),
                          decoration: InputDecoration(
                            labelText: 'Insulin (u)',
                            labelStyle: GoogleFonts.atkinsonHyperlegible(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) => ref.read(logFormProvider.notifier).updateField(carbs: val),
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            labelStyle: GoogleFonts.atkinsonHyperlegible(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Photo Button
                  OutlinedButton.icon(
                    onPressed: () {
                      // Handle Camera/Gallery intent
                    },
                    icon: const Icon(Icons.camera_alt_outlined, color: primaryBlue),
                    label: Text(
                      'Add Meal Photo',
                      style: GoogleFonts.atkinsonHyperlegible(color: primaryBlue),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: () async {
                      // Ensure BG is evaluated one last time if they didn't tap away
                      ref.read(logFormProvider.notifier).evaluateBloodGlucose(context);
                      await ref.read(logFormProvider.notifier).saveEntry();

                      _bgController.clear();
                      _insulinController.clear();
                      _carbsController.clear();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Entry Saved', style: GoogleFonts.atkinsonHyperlegible())),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Entry',
                      style: GoogleFonts.atkinsonHyperlegible(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String currentSelection, Color primaryColor) {
    final isSelected = label == currentSelection;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.atkinsonHyperlegible(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: Colors.grey.shade200,
      onSelected: (bool selected) {
        if (selected) {
          ref.read(logFormProvider.notifier).updateMealTag(label);
        }
      },
    );
  }
}