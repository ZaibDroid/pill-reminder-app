import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/meal_type.dart';
import '../../../../core/models/timeline_dose_item.dart';
import '../../../custom_widgets/status_badge.dart';

class DoseTimelineCard extends StatelessWidget {
  final TimelineDoseItem item;
  final VoidCallback onTakeDose;
  final VoidCallback onSkipDose;
  final VoidCallback? onCardTap;

  const DoseTimelineCard({
    super.key,
    required this.item,
    required this.onTakeDose,
    required this.onSkipDose,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final med = item.medicine;
    final isTaken = item.isTaken;
    final isSkipped = item.isSkipped;
    final isMissed = item.isMissed;
    final isPending = item.isPending;

    Color leftBorderColor;
    Color iconBgColor;
    Color iconFgColor;

    if (isTaken) {
      leftBorderColor = AppColors.secondary;
      iconBgColor = AppColors.secondaryContainer;
      iconFgColor = AppColors.onSecondaryContainer;
    } else if (isMissed) {
      leftBorderColor = AppColors.error;
      iconBgColor = AppColors.errorContainer;
      iconFgColor = AppColors.error;
    } else if (isSkipped) {
      leftBorderColor = AppColors.outline;
      iconBgColor = AppColors.surfaceContainer;
      iconFgColor = AppColors.outline;
    } else {
      leftBorderColor = AppColors.primary;
      iconBgColor = AppColors.primaryContainer;
      iconFgColor = AppColors.onPrimaryContainer;
    }

    final mealInstruction = _getMealInstruction(med.mealType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.surfaceContainerHigh, width: 1),
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
        child: InkWell(
          onTap: onCardTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: leftBorderColor,
                  width: 5,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Box
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: AppRadius.radiusLg,
                        ),
                        child: Icon(
                          _getMedicineIcon(med.formFactor),
                          color: iconFgColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    med.name,
                                    style: AppTextStyles.headlineSm.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  item.formattedTime,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: isPending
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: isPending
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Text(
                                    '${med.dosageValue.toStringAsFixed(med.dosageValue.truncateToDouble() == med.dosageValue ? 0 : 1)} ${med.dosageUnit}',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (med.doctorName != null &&
                                    med.doctorName!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '• Dr. ${med.doctorName}',
                                    style: AppTextStyles.labelSm,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                            if (mealInstruction.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                mealInstruction,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Action row or status footer
                if (isPending) ...[
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.surfaceVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              foregroundColor: AppColors.onSurface,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: onSkipDose,
                            child: Text(
                              'Skip',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: onTakeDose,
                            icon: const Icon(Icons.task_alt, size: 18),
                            label: Text(
                              'Take Dose',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.surfaceVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    child: StatusBadge.fromMedicineStatus(item.status),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMealInstruction(MealType type) {
    switch (type) {
      case MealType.beforeMeal:
        return 'Take before meal';
      case MealType.afterMeal:
        return 'Take after meal';
      case MealType.withMeal:
        return 'Take with food or water';
      case MealType.noRelation:
        return 'Take with water';
    }
  }

  IconData _getMedicineIcon(String formFactor) {
    final lower = formFactor.toLowerCase();
    if (lower.contains('drop')) return Icons.water_drop;
    if (lower.contains('capsule')) return Icons.medication;
    if (lower.contains('injection') || lower.contains('vaccine')) {
      return Icons.vaccines;
    }
    return Icons.medication;
  }
}
