import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onEmergencyTap;

  const HomeHeader({
    super.key,
    this.onEmergencyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MediAlert',
              style: AppTextStyles.displayLg.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.emergency, color: AppColors.primary),
              tooltip: 'Emergency Contacts',
              onPressed: onEmergencyTap ??
                  () {
                    Navigator.of(context).pushNamed('/emergency');
                  },
            ),
          ],
        ),
      ),
    );
  }
}
