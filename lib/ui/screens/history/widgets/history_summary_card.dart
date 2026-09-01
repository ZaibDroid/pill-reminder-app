import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/progress_ring.dart';

class HistorySummaryCard extends StatelessWidget {
  final double adherenceRate;
  final String motivationalMessage;

  const HistorySummaryCard({
    super.key,
    required this.adherenceRate,
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
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(
            percentage: adherenceRate,
            size: 64,
            strokeWidth: 6,
            progressColor: AppColors.secondary,
            trackColor: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY ADHERENCE',
                  style: AppTextStyles.labelSm.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motivationalMessage.isNotEmpty ? motivationalMessage : 'Keep up the good progress!',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
