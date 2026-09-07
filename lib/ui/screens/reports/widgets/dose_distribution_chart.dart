import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasData = (takenPercentage + skippedPercentage + missedPercentage) > 0;

    final takenColor = theme.colorScheme.primary;
    final skippedColor = theme.colorScheme.surfaceContainerHighest;
    final missedColor = theme.colorScheme.error;

    final sections = hasData
        ? [
            PieChartSectionData(
              color: takenColor,
              value: takenPercentage > 0 ? takenPercentage : 0.01,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: skippedColor,
              value: skippedPercentage > 0 ? skippedPercentage : 0.01,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: missedColor,
              value: missedPercentage > 0 ? missedPercentage : 0.01,
              radius: 20,
              showTitle: false,
            ),
          ]
        : [
            PieChartSectionData(
              color: theme.colorScheme.surfaceContainerHigh,
              value: 100,
              radius: 20,
              showTitle: false,
            ),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
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
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
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
                        color: theme.colorScheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Taken',
                      style: AppTextStyles.labelSm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                context: context,
                color: takenColor,
                label: 'Taken (${takenPercentage.round()}%)',
              ),
              _buildLegend(
                context: context,
                color: skippedColor,
                label: 'Skipped (${skippedPercentage.round()}%)',
              ),
              _buildLegend(
                context: context,
                color: missedColor,
                label: 'Missed (${missedPercentage.round()}%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required BuildContext context, required Color color, required String label}) {
    final theme = Theme.of(context);
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
          style: AppTextStyles.labelSm.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
