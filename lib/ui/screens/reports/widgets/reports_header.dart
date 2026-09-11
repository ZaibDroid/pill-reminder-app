import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/report_filter.dart';

class ReportsHeader extends StatelessWidget {
  final DateTime? currentMonth;
  final ReportFilter? selectedFilter;
  final String? dateRangeText;

  const ReportsHeader({
    super.key,
    this.currentMonth,
    this.selectedFilter,
    this.dateRangeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final displayDate = dateRangeText ??
        (currentMonth != null
            ? DateFormat('MMMM yyyy').format(currentMonth!)
            : DateFormat('MMMM yyyy').format(DateTime.now()));

    final filterLabel = selectedFilter?.label ?? 'Overview';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adherence Overview',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayDate,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (selectedFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusFull,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 14,
                    color: isDark ? AppColors.inversePrimary : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    filterLabel,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isDark ? AppColors.inversePrimary : AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
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
