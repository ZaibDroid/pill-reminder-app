import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 54,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            style: AppTextStyles.displayLg.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyLg.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )));
  }
}
