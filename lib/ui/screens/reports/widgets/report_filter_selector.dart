import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/report_filter.dart';

class ReportFilterSelector extends StatelessWidget {
  final ReportFilter selectedFilter;
  final ValueChanged<ReportFilter> onFilterSelected;

  const ReportFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHigh
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: ReportFilter.values.map((filter) {
            final isSelected = filter == selectedFilter;

            return Expanded(
              child: GestureDetector(
                onTap: () => onFilterSelected(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.primaryContainer : AppColors.primary)
                        : Colors.transparent,
                    borderRadius: AppRadius.radiusMd,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark ? Colors.black : AppColors.primary)
                                  .withValues(alpha: isDark ? 0.3 : 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter.label,
                        style: AppTextStyles.labelMd.copyWith(
                          color: isSelected
                              ? AppColors.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        filter.shortLabel,
                        style: AppTextStyles.labelSm.copyWith(
                          color: isSelected
                              ? AppColors.onPrimary.withValues(alpha: 0.85)
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
