import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/meal_type.dart';
import '../../../../core/models/medicine.dart';
import '../../../custom_widgets/medicine_avatar.dart';

class MedicineInfoCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineInfoCard({
    super.key,
    required this.medicine,
  });

  String _getMealText(MealType mealType) {
    switch (mealType) {
      case MealType.beforeMeal:
        return 'Before food';
      case MealType.afterMeal:
        return 'After food';
      case MealType.withMeal:
        return 'With food';
      case MealType.noRelation:
        return 'With water';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dosageVal = medicine.dosageValue.toStringAsFixed(
      medicine.dosageValue.truncateToDouble() == medicine.dosageValue ? 0 : 1,
    );
    final formName = medicine.formFactor.isNotEmpty
        ? '${medicine.formFactor[0].toUpperCase()}${medicine.formFactor.substring(1)}'
        : 'Tablet';
    final mealText = _getMealText(medicine.mealType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Prominent Large Medicine Image / Avatar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: MedicineAvatar(
              imagePath: medicine.pillImageLocalPath,
              formFactor: medicine.formFactor,
              size: 96,
              isCircle: false,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.6),
              iconColor: theme.colorScheme.primary,
              iconSize: 48,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // 2. Medicine Details cleanly shifted towards the right side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    medicine.name,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$dosageVal ${medicine.dosageUnit} • $formName',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          medicine.intakeGuidance.isNotEmpty
                              ? '$mealText • ${medicine.intakeGuidance}'
                              : mealText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (medicine.doctorName != null && medicine.doctorName!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Dr. ${medicine.doctorName}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

