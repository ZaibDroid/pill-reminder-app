import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dose History',
            style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Review your recent activity and adherence.',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
