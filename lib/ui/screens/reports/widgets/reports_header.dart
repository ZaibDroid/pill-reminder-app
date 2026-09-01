import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_text_styles.dart';

class ReportsHeader extends StatelessWidget {
  final DateTime currentMonth;

  const ReportsHeader({
    super.key,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMMM yyyy').format(currentMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Overview',
            style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            monthStr,
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
