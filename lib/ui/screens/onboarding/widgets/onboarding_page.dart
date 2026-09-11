import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String? imagePath;
  final IconData icon;
  final String tag;
  final String title;
  final String description;
  final List<String> highlights;

  const OnboardingPage({
    super.key,
    this.imagePath,
    required this.icon,
    this.tag = '',
    required this.title,
    required this.description,
    this.highlights = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero Image Container with elevation & smooth corners
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2529) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: imagePath != null
                      ? Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 280,
                          errorBuilder: (context, error, stackTrace) => _buildIconFallback(theme),
                        )
                      : _buildIconFallback(theme),
                ),
              ),
              const SizedBox(height: 28),

              // Category / Feature Guide Tag
              if (tag.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        tag.toUpperCase(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Main Display Title
              Text(
                title,
                style: AppTextStyles.displayLg.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Clear & Friendly Description
              Text(
                description,
                style: AppTextStyles.bodyLg.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              // Quick-Glance Feature Highlights
              if (highlights.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: highlights.map((highlight) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            highlight,
                            style: AppTextStyles.labelSm.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconFallback(ThemeData theme) {
    return Center(
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
    );
  }
}
