import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PinDotsIndicator extends StatelessWidget {
  final int pinLength;
  final int maxDigits;
  final bool isError;

  const PinDotsIndicator({
    super.key,
    required this.pinLength,
    this.maxDigits = 4,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxDigits, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isError
                ? AppColors.error
                : (isFilled ? AppColors.primary : AppColors.surfaceContainerHighest),
            border: isFilled
                ? null
                : Border.all(
                    color: isError ? AppColors.error : AppColors.outlineVariant,
                    width: 2,
                  ),
          ),
        );
      }),
    );
  }
}
