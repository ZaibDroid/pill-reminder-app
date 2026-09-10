import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/frequency_type.dart';
import '../../../../core/enums/meal_type.dart';
import '../../../custom_widgets/medicine_avatar.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Almost done!',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Please review the medication details before saving to your schedule.',
          style: AppTextStyles.bodyMd.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Review Card
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
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
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    MedicineAvatar(
                      imagePath: viewModel.pillImageLocalPath,
                      formFactor: viewModel.formFactor,
                      size: 56,
                      isCircle: true,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      iconColor: theme.colorScheme.onPrimaryContainer,
                      iconSize: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.name.isNotEmpty ? viewModel.name : 'Medication Name',
                            style: AppTextStyles.headlineSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${_formatDosage(viewModel.dosageValue, viewModel.dosageUnit)} • ${viewModel.formFactor[0].toUpperCase()}${viewModel.formFactor.substring(1)}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        'PRESCRIPTION',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Item 1: Intake & Administration
              _buildReviewRow(
                context: context,
                icon: Icons.restaurant,
                label: 'Intake & Administration',
                value: '${_formatMealType(viewModel.mealType)} • ${viewModel.intakeGuidance}',
                onEdit: () => onJumpToStep(1),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),

              // Item 2: Schedule
              _buildReviewRow(
                context: context,
                icon: Icons.calendar_month,
                label: 'Schedule',
                value: _formatSchedule(),
                onEdit: () => onJumpToStep(1),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),

              // Item 3: Duration
              _buildReviewRow(
                context: context,
                icon: Icons.hourglass_empty,
                label: 'Duration',
                value: viewModel.isOngoing ? 'Ongoing medication' : 'Ends on ${viewModel.endDate?.toString().split(' ')[0]}',
                onEdit: () => onJumpToStep(2),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),

              // Item 4: Stock & Inventory
              _buildReviewRow(
                context: context,
                icon: Icons.inventory_2_rounded,
                label: 'Inventory & Stock',
                value: '${viewModel.currentStock} in stock'
                    '${viewModel.isRefillAlertEnabled ? ' • Alert at ${viewModel.lowStockThreshold} left' : ''}',
                onEdit: () => onJumpToStep(2),
              ),

              // Item 5: Doctor / Notes
              if (viewModel.doctorName != null && viewModel.doctorName!.isNotEmpty) ...[
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                _buildReviewRow(
                  context: context,
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

  String _formatSchedule() {
    String freqStr;
    if (viewModel.frequency == FrequencyType.daily) {
      freqStr = 'Daily';
    } else if (viewModel.frequency == FrequencyType.specificDays) {
      const dayNames = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
      final days = viewModel.specificDaysOfWeek.map((d) => dayNames[d] ?? '').where((s) => s.isNotEmpty).join(', ');
      freqStr = 'Specific Days ($days)';
    } else {
      final hours = viewModel.intervalHours ?? 8;
      String intervalLabel;
      if (hours == 48) {
        intervalLabel = 'Every 48h (2 Days)';
      } else if (hours == 72) {
        intervalLabel = 'Every 72h (3 Days)';
      } else if (hours == 96) {
        intervalLabel = 'Every 96h (4 Days)';
      } else if (hours == 24) {
        intervalLabel = 'Every 24h (1 Day)';
      } else if (hours == 1) {
        intervalLabel = 'Every 1 Hour';
      } else {
        intervalLabel = 'Every ${hours}h';
      }
      freqStr = 'Interval ($intervalLabel)';
    }
    final times = viewModel.reminderTimes.map(_formatTime12).join(', ');
    return '$freqStr • $times';
  }

  String _formatTime12(TimeOfDay t) {
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final hourStr = hour12.toString().padLeft(2, '0');
    final minStr = t.minute.toString().padLeft(2, '0');
    final periodStr = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hourStr:$minStr $periodStr';
  }

  String _formatMealType(MealType type) {
    switch (type) {
      case MealType.beforeMeal:
        return 'Take Before Meal';
      case MealType.afterMeal:
        return 'Take After Meal';
      case MealType.withMeal:
        return 'Take With Food';
      case MealType.noRelation:
        return 'No Food Relation';
    }
  }

  String _formatDosage(double val, String unit) {
    final cleanVal = val.truncateToDouble() == val ? val.toInt().toString() : val.toString();
    return '$cleanVal $unit';
  }

  Widget _buildReviewRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 18),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
