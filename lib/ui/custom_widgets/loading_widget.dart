import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'loading_indicator.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  final double size;
  
  const LoadingWidget({
    super.key,
    this.color = AppColors.primary,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppLoadingIndicator(
        color: color,
        size: size,
      ),
    );
  }
}
