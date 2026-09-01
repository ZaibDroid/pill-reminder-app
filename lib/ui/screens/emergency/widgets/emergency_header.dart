import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

class EmergencyHeader extends StatelessWidget {
  const EmergencyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your trusted contacts for quick access during an emergency.',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
