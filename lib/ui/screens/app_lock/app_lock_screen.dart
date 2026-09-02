import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../custom_widgets/loading_indicator.dart';
import '../../custom_widgets/primary_button.dart';
import '../../viewmodels/app_lock_viewmodel.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/pin_dots_indicator.dart';

class AppLockScreen extends StatelessWidget {
  final VoidCallback onUnlockSuccess;
  final AppLockViewModel? viewModel;

  const AppLockScreen({
    super.key,
    required this.onUnlockSuccess,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<AppLockViewModel>.value(
        value: viewModel!,
        child: _AppLockContent(onUnlockSuccess: onUnlockSuccess),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => locator<AppLockViewModel>()..init(),
      child: _AppLockContent(onUnlockSuccess: onUnlockSuccess),
    );
  }
}

class _AppLockContent extends StatelessWidget {
  final VoidCallback onUnlockSuccess;

  const _AppLockContent({required this.onUnlockSuccess});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AppLockViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Logo & Clinical Branding
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    AppImages.appIcon,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryContainer,
                      child: const Icon(
                        Icons.medical_services,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'MediAlert',
                style: AppTextStyles.displayLg.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // PIN Prompt & Indicator / Spinner
              Text(
                'Enter PIN to Unlock',
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: viewModel.isLoading
                    ? const AppLoadingIndicator(
                        size: 26.0,
                        color: AppColors.primary,
                      )
                    : PinDotsIndicator(
                        pinLength: viewModel.pinLength,
                        isError: viewModel.isError,
                      ),
              ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),

              // Keypad
              NumericKeypad(
                isEnabled: !viewModel.isLoading,
                onDigitPressed: (digit) async {
                  viewModel.appendDigit(digit);
                  if (viewModel.pinLength == 4) {
                    final valid = await viewModel.verifyPin();
                    if (valid && context.mounted) {
                      onUnlockSuccess();
                    }
                  }
                },
                onDeletePressed: viewModel.deleteDigit,
                onBiometricPressed: () async {
                  final success = await viewModel.authenticateWithBiometrics();
                  if (success && context.mounted) {
                    onUnlockSuccess();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Unlock Button (with loading indicator) & Forgot PIN
              if (viewModel.pinLength == 4 || viewModel.isLoading) ...[
                PrimaryButton(
                  text: 'Unlock',
                  isLoading: viewModel.isLoading,
                  height: 48,
                  onPressed: () async {
                    final valid = await viewModel.verifyPin();
                    if (valid && context.mounted) {
                      onUnlockSuccess();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Default recovery PIN is 1234')),
                            );
                          },
                    child: Text(
                      'Forgot PIN?',
                      style: AppTextStyles.labelMd.copyWith(
                        color: viewModel.isLoading ? AppColors.outline : AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/emergency');
                          },
                    icon: const Icon(Icons.emergency, size: 16, color: AppColors.error),
                    label: Text(
                      'Emergency',
                      style: AppTextStyles.labelMd.copyWith(
                        color: viewModel.isLoading ? AppColors.outline : AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
