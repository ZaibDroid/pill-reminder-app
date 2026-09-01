import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/medicine.dart';

class AlarmMedicationCard extends StatelessWidget {
  final Medicine? medicine;

  const AlarmMedicationCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Medication Image Circle
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.medication,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Urgent Alert Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: AppRadius.radiusFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active, color: AppColors.error, size: 16),
              const SizedBox(width: 6),
              Text(
                'ALARM REMINDER',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Time for Your Medication',
          style: AppTextStyles.headlineLgMobile.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Medicine Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
              Text(
                medicine?.name ?? 'Amoxicillin 500mg',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${medicine?.dosageValue ?? 1} ${medicine?.dosageUnit ?? "Tablet"}',
                style: AppTextStyles.bodyLg,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Take with water',
                      style: AppTextStyles.labelMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
