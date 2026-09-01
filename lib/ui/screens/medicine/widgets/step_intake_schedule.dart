import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Intake Relation
        Text(
          'Intake Relation',
          style: AppTextStyles.headlineSm.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
              type: MealType.beforeMeal,
              title: 'Before Meal',
              icon: Icons.restaurant,
            ),
            _buildMealOption(
              type: MealType.afterMeal,
              title: 'After Meal',
              icon: Icons.dinner_dining,
            ),
            _buildMealOption(
              type: MealType.withMeal,
              title: 'With Food',
              icon: Icons.lunch_dining,
            ),
            _buildMealOption(
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
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: RadioGroup<FrequencyType>(
            groupValue: viewModel.frequency,
            onChanged: (val) {
              if (val != null) viewModel.frequency = val;
            },
            child: const Column(
              children: [
                RadioListTile<FrequencyType>(
                  value: FrequencyType.daily,
                  title: Text('Daily'),
                  secondary: Icon(Icons.calendar_today, color: AppColors.primary),
                  activeColor: AppColors.primary,
                ),
                Divider(height: 1),
                RadioListTile<FrequencyType>(
                  value: FrequencyType.specificDays,
                  title: Text('Specific Days'),
                  secondary: Icon(Icons.event_available, color: AppColors.primary),
                  activeColor: AppColors.primary,
                ),
                Divider(height: 1),
                RadioListTile<FrequencyType>(
                  value: FrequencyType.interval,
                  title: Text('Interval'),
                  secondary: Icon(Icons.schedule, color: AppColors.primary),
                  activeColor: AppColors.primary,
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
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  '$hourStr:$minStr',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (viewModel.reminderTimes.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
            side: const BorderSide(color: AppColors.primary, width: 1.5),
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
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: Text(
            'Add Another Time',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildMealOption({
    required MealType type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = viewModel.mealType == type;

    return InkWell(
      onTap: () => viewModel.mealType = type,
      borderRadius: AppRadius.radiusXl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
