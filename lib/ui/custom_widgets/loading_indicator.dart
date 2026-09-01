import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';

/// Reusable professional loading indicator for MediAlert using flutter_spinkit.
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const AppLoadingIndicator({
    super.key,
    this.size = 28.0,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: Center(
        child: SpinKitSquareCircle(
          color: color,
          size: size,
        ),
      ),
    );
  }
}
