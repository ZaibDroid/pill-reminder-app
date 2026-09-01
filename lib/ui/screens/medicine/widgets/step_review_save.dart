import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../viewmodels/add_medicine_viewmodel.dart';

class StepReviewSave extends StatelessWidget {
  final AddMedicineViewModel viewModel;
  final Function(int step) onJumpToStep;

  const StepReviewSave({
    super.key,
    required this.viewModel,
    required this.onJumpToStep,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Almost done!',
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Please review the medication details before saving to your schedule.',
          style: AppTextStyles.bodyMd,
        ),
        const SizedBox(height: 16),

        // Review Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Hero Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceBright,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: AppColors.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.name.isNotEmpty ? viewModel.name : 'Medication Name',
                            style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${viewModel.dosageValue} ${viewModel.dosageUnit} ${viewModel.formFactor}',
                            style: AppTextStyles.bodyMd,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        'PRESCRIPTION',
                        style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              // Item 1: Intake
              _buildReviewRow(
                icon: Icons.water_drop,
                label: 'Intake Instructions',
                value: 'Take with food or water (${viewModel.mealType.name})',
                onEdit: () => onJumpToStep(1),
              ),
              const Divider(height: 1),

              // Item 2: Schedule
              _buildReviewRow(
                icon: Icons.calendar_month,
                label: 'Schedule',
                value: 'Frequency: ${viewModel.frequency.name.toUpperCase()} at ${viewModel.reminderTimes.map((t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}").join(', ')}',
                onEdit: () => onJumpToStep(1),
              ),
              const Divider(height: 1),

              // Item 3: Duration
              _buildReviewRow(
                icon: Icons.hourglass_empty,
                label: 'Duration & Inventory',
                value: viewModel.isOngoing ? 'Ongoing treatment' : 'Ends on ${viewModel.endDate?.toString().split(' ')[0]}',
                onEdit: () => onJumpToStep(2),
              ),

              // Item 4: Doctor / Notes
              if (viewModel.doctorName != null && viewModel.doctorName!.isNotEmpty) ...[
                const Divider(height: 1),
                _buildReviewRow(
                  icon: Icons.person_outline,
                  label: 'Prescribed by',
                  value: 'Dr. ${viewModel.doctorName}',
                  onEdit: () => onJumpToStep(2),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSm),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
