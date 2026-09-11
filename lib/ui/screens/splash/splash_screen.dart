import 'package:flutter/material.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/repositories/user_settings_repository.dart';

import '../../../app/routes.dart';
import '../../../core/services/alarm_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    // Non-blocking background sync for active medication alarms
    if (locator.isRegistered<AlarmService>()) {
      locator<AlarmService>().rescheduleAllActiveAlarms().catchError((_) => 0);
    }

    // Temporarily set to onboarding for visual testing and review as requested
    String nextRoute = AppRoutes.onboarding;

    try {
      if (locator.isRegistered<UserSettingsRepository>()) {
        final userSettingsRepo = locator<UserSettingsRepository>();
        await userSettingsRepo.getOrCreateSettings();
        // Force onboarding route for testing; will revert to isFirstTimeUser check later
        nextRoute = AppRoutes.onboarding;
      }
    } catch (_) {
      nextRoute = AppRoutes.onboarding;
    }

    // Ensure smooth entrance animation completes gracefully before transitioning
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 48,
                        spreadRadius: 2,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: Image.asset(
                      AppImages.appIcon,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(38),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: AppColors.onPrimary,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'MediAlert',
                  style: AppTextStyles.displayLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Reliable Health Companion',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
