import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onEmergencyTap;

  const HomeHeader({
    super.key,
    this.onEmergencyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      color: theme.scaffoldBackgroundColor,
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
                color: primaryColor,
              ),
            ),
            IconButton(
              icon: Icon(Icons.contact_emergency_rounded, color: primaryColor),
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
