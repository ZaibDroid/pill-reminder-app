import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class DoseDistributionChart extends StatelessWidget {
  final double takenPercentage;
  final double skippedPercentage;
  final double missedPercentage;

  const DoseDistributionChart({
    super.key,
    required this.takenPercentage,
    required this.skippedPercentage,
    required this.missedPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = (takenPercentage + skippedPercentage + missedPercentage) > 0;

    final sections = hasData
        ? [
            PieChartSectionData(
              color: AppColors.primaryContainer,
              value: takenPercentage > 0 ? takenPercentage : 0.01,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: AppColors.surfaceVariant,
              value: skippedPercentage > 0 ? skippedPercentage : 0.01,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: AppColors.errorContainer,
              value: missedPercentage > 0 ? missedPercentage : 0.01,
              radius: 20,
              showTitle: false,
            ),
          ]
        : [
            PieChartSectionData(
              color: AppColors.surfaceVariant,
              value: 100,
              radius: 20,
              showTitle: false,
            ),
          ];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dose Distribution',
            style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 65,
                    startDegreeOffset: -90,
                    sections: sections,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${takenPercentage.round()}%',
                      style: AppTextStyles.displayLg.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Taken',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(
                color: AppColors.primaryContainer,
                label: 'Taken (${takenPercentage.round()}%)',
              ),
              _buildLegend(
                color: AppColors.surfaceVariant,
                label: 'Skipped (${skippedPercentage.round()}%)',
              ),
              _buildLegend(
                color: AppColors.errorContainer,
                label: 'Missed (${missedPercentage.round()}%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
