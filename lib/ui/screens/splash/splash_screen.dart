import 'package:flutter/material.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/repositories/user_settings_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _checkNextDestination();
  }

  Future<void> _checkNextDestination() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    try {
      if (locator.isRegistered<UserSettingsRepository>()) {
        final userSettingsRepo = locator<UserSettingsRepository>();
        final settings = await userSettingsRepo.getOrCreateSettings();

        if (!mounted) return;
        if (settings.isFirstTimeUser) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
          return;
        } else if (settings.pinHash != null && settings.pinHash!.isNotEmpty) {
          Navigator.of(context).pushReplacementNamed('/app_lock');
          return;
        }
      }
    } catch (_) {
      // Fallback gracefully to home if database is offline or not yet initialized
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
