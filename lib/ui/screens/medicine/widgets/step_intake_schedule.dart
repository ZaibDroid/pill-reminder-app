import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/frequency_type.dart';
import '../../../../core/enums/meal_type.dart';
import '../../../viewmodels/add_medicine_viewmodel.dart';

class StepIntakeSchedule extends StatelessWidget {
  final AddMedicineViewModel viewModel;

  const StepIntakeSchedule({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Intake Relation
        Text(
          'Intake Relation',
          style: AppTextStyles.headlineSm.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildMealOption(
              context: context,
              type: MealType.beforeMeal,
              title: 'Before Meal',
              icon: Icons.restaurant,
            ),
            _buildMealOption(
              context: context,
              type: MealType.afterMeal,
              title: 'After Meal',
              icon: Icons.dinner_dining,
            ),
            _buildMealOption(
              context: context,
              type: MealType.withMeal,
              title: 'With Food',
              icon: Icons.lunch_dining,
            ),
            _buildMealOption(
              context: context,
              type: MealType.noRelation,
              title: 'No Relation',
              icon: Icons.water_drop,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Frequency
        Text(
          'Frequency',
          style: AppTextStyles.headlineSm.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            ),
          ),
          child: RadioGroup<FrequencyType>(
            groupValue: viewModel.frequency,
            onChanged: (val) {
              if (val != null) viewModel.frequency = val;
            },
            child: Column(
              children: [
                RadioListTile<FrequencyType>(
                  value: FrequencyType.daily,
                  title: Text('Daily', style: TextStyle(color: theme.colorScheme.onSurface)),
                  secondary: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  activeColor: theme.colorScheme.primary,
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                RadioListTile<FrequencyType>(
                  value: FrequencyType.specificDays,
                  title: Text('Specific Days', style: TextStyle(color: theme.colorScheme.onSurface)),
                  secondary: Icon(Icons.event_available, color: theme.colorScheme.primary),
                  activeColor: theme.colorScheme.primary,
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                RadioListTile<FrequencyType>(
                  value: FrequencyType.interval,
                  title: Text('Interval', style: TextStyle(color: theme.colorScheme.onSurface)),
                  secondary: Icon(Icons.schedule, color: theme.colorScheme.primary),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Reminders
        Text(
          'Reminder Times',
          style: AppTextStyles.headlineSm.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...viewModel.reminderTimes.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          final hourStr = time.hour.toString().padLeft(2, '0');
          final minStr = time.minute.toString().padLeft(2, '0');

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.alarm, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  '$hourStr:$minStr',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (viewModel.reminderTimes.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () => viewModel.removeReminderTime(index),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusXl,
            ),
          ),
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 12, minute: 0),
            );
            if (picked != null) {
              viewModel.addReminderTime(picked);
            }
          },
          icon: Icon(Icons.add, color: theme.colorScheme.primary),
          label: Text(
            'Add Another Time',
            style: AppTextStyles.labelMd.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealOption({
    required BuildContext context,
    required MealType type,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = viewModel.mealType == type;

    return InkWell(
      onTap: () => viewModel.mealType = type,
      borderRadius: AppRadius.radiusXl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
