import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/progress_ring.dart';

class AdherenceCard extends StatelessWidget {
  final double adherenceRate;
  final int takenDoses;
  final int totalDoses;
  final String motivationalMessage;

  const AdherenceCard({
    super.key,
    required this.adherenceRate,
    required this.takenDoses,
    required this.totalDoses,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.surfaceContainerHigh,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Adherence",
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMd,
                    children: [
                      const TextSpan(text: "You've taken "),
                      TextSpan(
                        text: '$takenDoses of $totalDoses',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' doses today'),
                    ],
                  ),
                ),
                if (motivationalMessage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    motivationalMessage,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          ProgressRing(
            percentage: adherenceRate,
            size: 72,
            strokeWidth: 8,
            progressColor: AppColors.primary,
            trackColor: AppColors.surfaceVariant,
          ),
        ],
      ),
    );
  }
}
