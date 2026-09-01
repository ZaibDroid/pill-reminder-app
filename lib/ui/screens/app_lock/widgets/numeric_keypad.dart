import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onBiometricPressed;
  final bool isEnabled;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onBiometricPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 10),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 10),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                key: const ValueKey('keypad_biometric'),
                icon: Icons.fingerprint,
                onPressed: isEnabled ? onBiometricPressed : () {},
                color: isEnabled ? AppColors.primary : AppColors.outline,
              ),
              _buildDigitButton('0'),
              _buildActionButton(
                key: const ValueKey('keypad_delete'),
                icon: Icons.backspace_outlined,
                onPressed: isEnabled ? onDeletePressed : () {},
                color: isEnabled ? AppColors.onSurfaceVariant : AppColors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitButton(d)).toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return Container(
      key: ValueKey('keypad_$digit'),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.surfaceContainerLow : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: isEnabled ? () => onDigitPressed(digit) : null,
        customBorder: const CircleBorder(),
        child: Center(
          child: Text(
            digit,
            style: AppTextStyles.displayLg.copyWith(
              color: isEnabled ? AppColors.onSurface : AppColors.outline,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    Key? key,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      key: key,
      width: 60,
      height: 60,
      child: IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }
}
