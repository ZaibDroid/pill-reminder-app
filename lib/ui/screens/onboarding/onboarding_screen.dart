import 'package:flutter/material.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
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
      icon: Icons.notifications_active,
      title: 'Never Miss a Dose',
      description:
          'Receive timely, prominent alerts directly to your device so your medication schedule is always on track.',
    ),
    OnboardingPage(
      icon: Icons.medication,
      title: 'Visual Identification',
      description:
          'Clear images and exact dosage information ensure you are taking the right medication every single time.',
    ),
    OnboardingPage(
      icon: Icons.analytics,
      title: 'Track Your Health',
      description:
          'Monitor your adherence over time with easy-to-read charts that help you and your care team stay informed.',
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
