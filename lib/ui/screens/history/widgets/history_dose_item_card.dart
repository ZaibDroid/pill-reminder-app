import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/timeline_dose_item.dart';
import '../../../custom_widgets/medicine_avatar.dart';

class HistoryDoseItemCard extends StatelessWidget {
  final TimelineDoseItem item;

  const HistoryDoseItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTaken = item.isTaken;
    final isSkipped = item.isSkipped;
    final isMissed = item.isMissed;

    Color leftBorderColor;
    Color iconBgColor;
    Color iconFgColor;
    Color statusFgColor;
    IconData statusIcon;
    String statusText;

    if (isTaken) {
      leftBorderColor = theme.colorScheme.secondary;
      iconBgColor = theme.colorScheme.secondaryContainer.withValues(alpha: 0.5);
      iconFgColor = theme.colorScheme.secondary;
      statusFgColor = theme.colorScheme.secondary;
      statusIcon = Icons.check_circle;
      statusText = item.doseLog?.actualTakenDateTime != null
          ? 'Taken at ${DateFormat('hh:mm a').format(item.doseLog!.actualTakenDateTime!)}'
          : 'Taken';
    } else if (isMissed) {
      leftBorderColor = theme.colorScheme.error;
      iconBgColor = theme.colorScheme.errorContainer;
      iconFgColor = theme.colorScheme.error;
      statusFgColor = theme.colorScheme.error;
      statusIcon = Icons.cancel;
      statusText = 'Missed';
    } else if (isSkipped) {
      leftBorderColor = theme.colorScheme.outline;
      iconBgColor = theme.colorScheme.surfaceContainerHigh;
      iconFgColor = theme.colorScheme.outline;
      statusFgColor = theme.colorScheme.outline;
      statusIcon = Icons.do_not_disturb_on;
      statusText = 'Skipped';
    } else {
      leftBorderColor = theme.colorScheme.outlineVariant;
      iconBgColor = theme.colorScheme.surfaceContainerHigh;
      iconFgColor = theme.colorScheme.onSurfaceVariant;
      statusFgColor = theme.colorScheme.onSurfaceVariant;
      statusIcon = Icons.schedule;
      statusText = 'Scheduled';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXl,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: leftBorderColor,
                width: 6,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MedicineAvatar(
                imagePath: item.medicine.pillImageLocalPath,
                formFactor: item.medicine.formFactor,
                size: 74,
                borderRadius: BorderRadius.circular(18),
                backgroundColor: iconBgColor,
                iconColor: iconFgColor,
                iconSize: 38,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.medicine.name,
                              style: AppTextStyles.headlineSm.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                                decoration: isSkipped ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Text(
                            item.formattedTime,
                            style: AppTextStyles.labelSm.copyWith(
                              color: isMissed ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isMissed ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.medicine.dosageValue.toStringAsFixed(item.medicine.dosageValue.truncateToDouble() == item.medicine.dosageValue ? 0 : 1)} ${item.medicine.dosageUnit} • ${item.medicine.frequency.name.toUpperCase()}',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(statusIcon, color: statusFgColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: AppTextStyles.labelSm.copyWith(
                              color: statusFgColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    ),
  );
}
}
