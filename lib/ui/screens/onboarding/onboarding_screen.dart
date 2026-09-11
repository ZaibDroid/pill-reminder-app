import 'package:flutter/material.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/repositories/user_settings_repository.dart';
import '../../custom_widgets/primary_button.dart';
import 'widgets/onboarding_indicators.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    OnboardingPage(
      imagePath: AppImages.onboarding1,
      icon: Icons.notifications_active_rounded,
      tag: 'Smart Reminders',
      title: 'Never Miss a Dose',
      description:
          'Personalized, full-screen alarms and gentle notifications keep your medication routine on track every single day.',
      highlights: ['Precise Alarm Schedules', 'Snooze & Grace Periods', 'Low Stock Refill Alerts'],
    ),
    OnboardingPage(
      imagePath: AppImages.onboarding2,
      icon: Icons.medication_rounded,
      tag: 'Medication Safety',
      title: 'Visual Identification',
      description:
          'Inspect pill photos, exact dosage values, and before/after meal guides so you always take the right medicine with total confidence.',
      highlights: ['Pill Color & Shape Match', 'Dosage & Meal Guidelines', 'Pill Organizer View'],
    ),
    OnboardingPage(
      imagePath: AppImages.onboarding3,
      icon: Icons.insights_rounded,
      tag: 'Health Insights',
      title: 'Track Your Health',
      description:
          'Visualize adherence streaks, monthly calendar heatmaps, and export clinical PDF reports to share with your doctor or caregiver.',
      highlights: ['Daily Adherence Streak', 'Monthly Health Heatmap', 'PDF Medical Export'],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final settingsRepo = locator<UserSettingsRepository>();
    final settings = await settingsRepo.getOrCreateSettings();
    settings.isFirstTimeUser = false;
    await settingsRepo.saveUserSettings(settings);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  OnboardingIndicators(
                    currentIndex: _currentPage,
                    totalCount: _pages.length,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: isLastPage ? 'Get Started' : 'Next',
                    icon: isLastPage ? Icons.check : Icons.arrow_forward,
                    onPressed: () {
                      if (isLastPage) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
