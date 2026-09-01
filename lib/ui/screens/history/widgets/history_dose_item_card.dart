import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/timeline_dose_item.dart';

class HistoryDoseItemCard extends StatelessWidget {
  final TimelineDoseItem item;

  const HistoryDoseItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
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
      leftBorderColor = AppColors.secondary;
      iconBgColor = AppColors.secondaryContainer.withValues(alpha: 0.35);
      iconFgColor = AppColors.secondary;
      statusFgColor = AppColors.secondary;
      statusIcon = Icons.check_circle;
      statusText = item.doseLog?.actualTakenDateTime != null
          ? 'Taken at ${DateFormat('hh:mm a').format(item.doseLog!.actualTakenDateTime!)}'
          : 'Taken';
    } else if (isMissed) {
      leftBorderColor = AppColors.error;
      iconBgColor = AppColors.errorContainer;
      iconFgColor = AppColors.error;
      statusFgColor = AppColors.error;
      statusIcon = Icons.cancel;
      statusText = 'Missed';
    } else if (isSkipped) {
      leftBorderColor = AppColors.outline;
      iconBgColor = AppColors.surfaceContainer;
      iconFgColor = AppColors.outline;
      statusFgColor = AppColors.outline;
      statusIcon = Icons.do_not_disturb_on;
      statusText = 'Skipped';
    } else {
      leftBorderColor = AppColors.outlineVariant;
      iconBgColor = AppColors.surfaceContainer;
      iconFgColor = AppColors.onSurfaceVariant;
      statusFgColor = AppColors.onSurfaceVariant;
      statusIcon = Icons.schedule;
      statusText = 'Scheduled';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: iconFgColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.medicine.name,
                            style: AppTextStyles.headlineSm.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              decoration: isSkipped ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedTime,
                          style: AppTextStyles.labelSm.copyWith(
                            color: isMissed ? AppColors.error : AppColors.onSurfaceVariant,
                            fontWeight: isMissed ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.medicine.dosageValue} ${item.medicine.dosageUnit} • ${item.medicine.frequency.name}',
                      style: AppTextStyles.bodyMd.copyWith(fontSize: 14),
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
            ],
          ),
        ),
      ),
    );
  }
}
