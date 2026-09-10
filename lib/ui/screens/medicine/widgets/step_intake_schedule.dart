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

        // Hydration & Administration Guidance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hydration & Administration',
              style: AppTextStyles.headlineSm.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Alarm Display',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select or enter how this medication should be taken or applied.',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildGuidanceChip(
              context: context,
              title: 'Full glass of water',
              icon: Icons.water_drop_outlined,
            ),
            _buildGuidanceChip(
              context: context,
              title: 'With warm water',
              icon: Icons.local_cafe_outlined,
            ),
            _buildGuidanceChip(
              context: context,
              title: 'With milk',
              icon: Icons.local_drink_rounded,
            ),
            _buildGuidanceChip(
              context: context,
              title: 'With juice',
              icon: Icons.emoji_food_beverage_outlined,
            ),
            _buildGuidanceChip(
              context: context,
              title: 'Apply with cotton',
              icon: Icons.clean_hands_rounded,
            ),
            _buildGuidanceChip(
              context: context,
              title: 'Apply with fingertips',
              icon: Icons.touch_app_outlined,
            ),
            _buildGuidanceChip(
              context: context,
              title: 'Direct / Without water',
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: viewModel.intakeGuidance,
          decoration: InputDecoration(
            labelText: 'Custom Intake / Application Note',
            hintText: 'e.g. Apply with cotton, with warm milk',
            prefixIcon: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          onChanged: (val) {
            viewModel.intakeGuidance = val;
          },
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
          child: Column(
            children: [
              _buildFrequencyOption(
                context: context,
                title: 'Daily',
                icon: Icons.calendar_today,
                isSelected: viewModel.frequency == FrequencyType.daily,
                onTap: () => viewModel.frequency = FrequencyType.daily,
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
              _buildFrequencyOption(
                context: context,
                title: 'Specific Days',
                icon: Icons.event_available,
                isSelected: viewModel.frequency == FrequencyType.specificDays,
                onTap: () => viewModel.frequency = FrequencyType.specificDays,
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
              _buildFrequencyOption(
                context: context,
                title: 'Interval',
                icon: Icons.schedule,
                isSelected: viewModel.frequency == FrequencyType.interval,
                onTap: () {
                  viewModel.frequency = FrequencyType.interval;
                  viewModel.intervalHours ??= 8;
                },
              ),
            ],
          ),
        ),

        // Specific Days Weekday Selector
        if (viewModel.frequency == FrequencyType.specificDays) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Days of Week',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${viewModel.specificDaysOfWeek.length} of 7 days',
                      style: AppTextStyles.labelSm.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeekdayButton(context, 1, 'Mon'),
                    _buildWeekdayButton(context, 2, 'Tue'),
                    _buildWeekdayButton(context, 3, 'Wed'),
                    _buildWeekdayButton(context, 4, 'Thu'),
                    _buildWeekdayButton(context, 5, 'Fri'),
                    _buildWeekdayButton(context, 6, 'Sat'),
                    _buildWeekdayButton(context, 7, 'Sun'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('All 7 Days', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      avatar: const Icon(Icons.select_all, size: 16),
                      onPressed: () => viewModel.selectAllDays(),
                      backgroundColor: theme.colorScheme.surfaceContainerLow,
                    ),
                    ActionChip(
                      label: const Text('Mon - Fri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      avatar: const Icon(Icons.work_outline, size: 16),
                      onPressed: () => viewModel.selectWeekdaysOnly(),
                      backgroundColor: theme.colorScheme.surfaceContainerLow,
                    ),
                    ActionChip(
                      label: const Text('Sat - Sun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      avatar: const Icon(Icons.weekend_outlined, size: 16),
                      onPressed: () => viewModel.selectWeekendsOnly(),
                      backgroundColor: theme.colorScheme.surfaceContainerLow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Interval Hours Selector (1-24 Scale and 48, 72, 96 Hardcoded Options)
        if (viewModel.frequency == FrequencyType.interval) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hourly Scale (1 - 24 hrs)',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        _getIntervalBadgeText(viewModel.intervalHours ?? 8),
                        style: AppTextStyles.labelSm.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 1-24 Scale Slider with - / + Stepper Buttons
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () {
                        final current = viewModel.intervalHours ?? 8;
                        if (current > 1) {
                          if (current > 24) {
                            viewModel.intervalHours = 24;
                          } else {
                            viewModel.intervalHours = current - 1;
                          }
                        }
                      },
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                        ),
                        child: Slider(
                          value: (viewModel.intervalHours != null &&
                                  viewModel.intervalHours! <= 24 &&
                                  viewModel.intervalHours! >= 1)
                              ? viewModel.intervalHours!.toDouble()
                              : 8.0,
                          min: 1.0,
                          max: 24.0,
                          divisions: 23,
                          label: '${viewModel.intervalHours != null && viewModel.intervalHours! <= 24 ? viewModel.intervalHours : 8}h',
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            viewModel.intervalHours = val.round();
                          },
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () {
                        final current = viewModel.intervalHours ?? 8;
                        if (current < 24) {
                          viewModel.intervalHours = current + 1;
                        } else if (current > 24) {
                          viewModel.intervalHours = 24;
                        }
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1h', style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      Text('6h', style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      Text('12h', style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      Text('18h', style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      Text('24h', style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 12),

                // Hard-coded Extended Multi-Day Options: 48, 72, 96
                Text(
                  'Extended Multi-Day Interval',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildIntervalChip(context, 48, '48 Hours (2 Days)'),
                    _buildIntervalChip(context, 72, '72 Hours (3 Days)'),
                    _buildIntervalChip(context, 96, '96 Hours (4 Days)'),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
          final hourStr = hour12.toString().padLeft(2, '0');
          final minStr = time.minute.toString().padLeft(2, '0');
          final periodStr = time.period == DayPeriod.am ? 'AM' : 'PM';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.alarm, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      viewModel.updateReminderTime(index, picked);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      '$hourStr:$minStr',
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: periodStr,
                      dropdownColor: theme.colorScheme.surface,
                      items: const [
                        DropdownMenuItem(
                          value: 'AM',
                          child: Text('AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'PM',
                          child: Text('PM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null && val != periodStr) {
                          viewModel.toggleAmPm(index);
                        }
                      },
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit Time',
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      viewModel.updateReminderTime(index, picked);
                    }
                  },
                ),
                if (viewModel.reminderTimes.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                    tooltip: 'Delete',
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

  Widget _buildWeekdayButton(BuildContext context, int day, String label) {
    final theme = Theme.of(context);
    final isSelected = viewModel.isDaySelected(day);

    return InkWell(
      onTap: () => viewModel.toggleDayOfWeek(day),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIntervalBadgeText(int hours) {
    if (hours == 1) return 'Every 1 Hour';
    if (hours == 48) return 'Every 48 Hours (2 Days)';
    if (hours == 72) return 'Every 72 Hours (3 Days)';
    if (hours == 96) return 'Every 96 Hours (4 Days)';
    if (hours == 24) return 'Every 24 Hours (1 Day)';
    return 'Every $hours Hours';
  }

  Widget _buildIntervalChip(BuildContext context, int hours, String label) {
    final theme = Theme.of(context);
    final isSelected = viewModel.intervalHours == hours;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          viewModel.intervalHours = hours;
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildGuidanceChip({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = viewModel.intakeGuidance.trim().toLowerCase() == title.trim().toLowerCase();

    return InkWell(
      onTap: () {
        viewModel.intakeGuidance = title;
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required dynamic isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final selected = isSelected == true;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
