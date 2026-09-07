import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/medicine.dart';

class MedicineScheduleCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineScheduleCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remindersList = medicine.reminders.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Schedule & Times',
                style: AppTextStyles.headlineSm.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Frequency: ${medicine.frequency.name.toUpperCase()}',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (remindersList.isEmpty)
            Text(
              'No active reminder times set.',
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: remindersList.map((reminder) {
                final hourStr = reminder.hour.toString().padLeft(2, '0');
                final minStr = reminder.minute.toString().padLeft(2, '0');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: theme.colorScheme.secondaryContainer),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 16,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$hourStr:$minStr',
                        style: AppTextStyles.labelMd.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
