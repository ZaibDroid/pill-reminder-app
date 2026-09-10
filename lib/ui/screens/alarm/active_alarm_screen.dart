import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../../app/routes.dart';
import '../../../core/models/medicine.dart';
import '../../viewmodels/alarm_viewmodel.dart';
import 'widgets/alarm_action_buttons.dart';
import 'widgets/alarm_medication_card.dart';

class ActiveAlarmScreen extends StatelessWidget {
  final Medicine? medicine;
  final int? medicineId;
  final int? reminderTimeId;

  const ActiveAlarmScreen({
    super.key,
    this.medicine,
    this.medicineId,
    this.reminderTimeId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<AlarmViewModel>()
        ..initializeAlarm(
          initialMedicine: medicine,
          medicineId: medicineId,
          reminderTimeId: reminderTimeId,
        ),
      child: const _ActiveAlarmContent(),
    );
  }
}

class _ActiveAlarmContent extends StatelessWidget {
  const _ActiveAlarmContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AlarmViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dosageVal = viewModel.medicine != null
        ? viewModel.medicine!.dosageValue.toStringAsFixed(
            viewModel.medicine!.dosageValue.truncateToDouble() ==
                    viewModel.medicine!.dosageValue
                ? 0
                : 1)
        : '1';
    final formName = viewModel.medicine?.formFactor != null
        ? '${viewModel.medicine!.formFactor[0].toUpperCase()}${viewModel.medicine!.formFactor.substring(1)}'
        : 'Tablet';
    final takeLabel = 'Take Dose ($dosageVal $formName)';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF031412), Color(0xFF072420), Color(0xFF041816)]
                : [const Color(0xFFF0FDF8), const Color(0xFFE8F7F2), const Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                AlarmMedicationCard(medicine: viewModel.medicine),
                const SizedBox(height: 24),
                AlarmActionButtons(
                  takeButtonLabel: takeLabel,
                  onMarkTaken: () async {
                    await viewModel.markAsTaken();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Dose recorded as taken for ${viewModel.medicine?.name ?? "medication"}!',
                          ),
                          backgroundColor: const Color(0xFF00D09C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  onSnooze: () async {
                    await viewModel.snooze(durationMinutes: 10);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alarm snoozed for 10 minutes.'),
                          backgroundColor: Color(0xFF00685F),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  onSkip: () async {
                    await viewModel.skipDose();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Dose skipped for ${viewModel.medicine?.name ?? "medication"}.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  onCallCaregiver: () async {
                    if (viewModel.hasCaregiver) {
                      final called = await viewModel.callCaregiver();
                      if (!called && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not initiate phone call to caregiver.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(AppRoutes.emergency);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

