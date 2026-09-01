import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/medicine.dart';
import '../../custom_widgets/custom_app_bar.dart';
import '../../custom_widgets/primary_button.dart';
import '../../custom_widgets/secondary_button.dart';
import '../../viewmodels/add_medicine_viewmodel.dart';
import 'widgets/step_basic_info.dart';
import 'widgets/step_intake_schedule.dart';
import 'widgets/step_progress_indicator.dart';
import 'widgets/step_reminders_duration.dart';
import 'widgets/step_review_save.dart';

class AddMedicineScreen extends StatelessWidget {
  final Medicine? existingMedicine;
  final AddMedicineViewModel? viewModel;

  const AddMedicineScreen({
    super.key,
    this.existingMedicine,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<AddMedicineViewModel>.value(
        value: viewModel!,
        child: const _AddMedicineContent(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => locator<AddMedicineViewModel>(param1: existingMedicine),
      child: const _AddMedicineContent(),
    );
  }
}

class _AddMedicineContent extends StatelessWidget {
  const _AddMedicineContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddMedicineViewModel>();

    final stepTitles = [
      'Basic Info',
      'Intake & Schedule',
      'Duration & Reminders',
      'Review Details',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: viewModel.isEditing ? 'Edit Medication' : 'Add Medication',
        showBackButton: true,
        showEmergencyShortcut: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            StepProgressIndicator(
              currentStep: viewModel.currentStep,
              totalSteps: viewModel.totalSteps,
              stepTitle: stepTitles[viewModel.currentStep],
            ),
            if (viewModel.errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: _buildCurrentStepView(viewModel),
            ),
            _buildBottomActionBar(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(AddMedicineViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return StepBasicInfo(viewModel: viewModel);
      case 1:
        return StepIntakeSchedule(viewModel: viewModel);
      case 2:
        return StepRemindersDuration(viewModel: viewModel);
      case 3:
        return StepReviewSave(
          viewModel: viewModel,
          onJumpToStep: (step) => viewModel.setStep(step),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActionBar(BuildContext context, AddMedicineViewModel viewModel) {
    final isLastStep = viewModel.currentStep == viewModel.totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: const Border(top: BorderSide(color: AppColors.surfaceVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (viewModel.currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: SecondaryButton(
                text: 'Back',
                onPressed: () => viewModel.previousStep(),
                height: 52,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: isLastStep ? 'Save Medication' : 'Next Step',
              icon: isLastStep ? Icons.check : Icons.arrow_forward,
              isLoading: viewModel.isLoading,
              height: 52,
              onPressed: () async {
                if (isLastStep) {
                  final success = await viewModel.saveMedication();
                  if (success && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } else {
                  viewModel.nextStep();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
