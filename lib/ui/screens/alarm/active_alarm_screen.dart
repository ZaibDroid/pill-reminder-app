import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/medicine.dart';
import '../../viewmodels/alarm_viewmodel.dart';
import 'widgets/alarm_action_buttons.dart';
import 'widgets/alarm_medication_card.dart';

class ActiveAlarmScreen extends StatelessWidget {
  final Medicine? medicine;

  const ActiveAlarmScreen({super.key, this.medicine});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<AlarmViewModel>()..medicine = medicine,
      child: const _ActiveAlarmContent(),
    );
  }
}

class _ActiveAlarmContent extends StatelessWidget {
  const _ActiveAlarmContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AlarmViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),
              AlarmMedicationCard(medicine: viewModel.medicine),
              AlarmActionButtons(
                onMarkTaken: () async {
                  await viewModel.markAsTaken();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                onSnooze: () async {
                  await viewModel.snooze();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                onSkip: () async {
                  await viewModel.skipDose();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
