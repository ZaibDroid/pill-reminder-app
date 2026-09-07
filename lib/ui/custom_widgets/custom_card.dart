import 'package:flutter/material.dart';
import '../../core/constants/app_radius.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final Color? accentBorderColor;
  final double accentBorderWidth;
  final bool hasShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.onTap,
    this.accentBorderColor,
    this.accentBorderWidth = 4.0,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    final decoration = BoxDecoration(
      color: effectiveColor,
      borderRadius: AppRadius.radiusXl,
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
        width: 1,
      ),
    );

    Widget content = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (accentBorderColor != null) {
      content = ClipRRect(
        borderRadius: AppRadius.radiusXl,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            border: Border(
              left: BorderSide(
                color: accentBorderColor!,
                width: accentBorderWidth,
              ),
            ),
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Container(
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppRadius.radiusXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusXl,
          child: content,
        ),
      );
    }

    return content;
  }
}
