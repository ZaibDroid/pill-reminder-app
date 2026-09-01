import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(totalSteps, (index) {
              final isCompletedOrCurrent = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isCompletedOrCurrent
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    borderRadius: AppRadius.radiusFull,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Step ${currentStep + 1} of $totalSteps: $stepTitle',
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
