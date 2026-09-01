import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Circular progress ring visualizing daily medication adherence, matching Stitch design.
class ProgressRing extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final TextStyle? textStyle;
  final Widget? centerWidget;

  const ProgressRing({
    super.key,
    required this.percentage,
    this.size = 80.0,
    this.strokeWidth = 8.0,
    this.progressColor = AppColors.primary,
    this.trackColor = AppColors.surfaceVariant,
    this.textStyle,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percentage.clamp(0.0, 100.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progressPercent: clampedPercent / 100.0,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: trackColor,
            ),
          ),
          centerWidget ??
              Text(
                '${clampedPercent.round()}%',
                style: textStyle ??
                    AppTextStyles.headlineSm.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progressPercent;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progressPercent,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Paint
    if (progressPercent > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progressPercent;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
