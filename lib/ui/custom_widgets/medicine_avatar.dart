import 'dart:io';
import 'package:flutter/material.dart';

/// Reusable widget for displaying medicine images with automatic fallback to stylized icons.
class MedicineAvatar extends StatelessWidget {
  final String? imagePath;
  final String formFactor;
  final double size;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final BoxBorder? border;

  const MedicineAvatar({
    super.key,
    this.imagePath,
    this.formFactor = 'tablet',
    this.size = 52,
    this.borderRadius,
    this.isCircle = false,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = iconColor ?? theme.colorScheme.onPrimaryContainer;
    final iSize = iconSize ?? (size * 0.5);

    final hasValidFile = imagePath != null &&
        imagePath!.trim().isNotEmpty &&
        File(imagePath!).existsSync();

    if (hasValidFile) {
      Widget imageContent = Image.file(
        File(imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(bg, fg, iSize),
      );

      if (isCircle) {
        imageContent = ClipOval(child: imageContent);
      } else {
        imageContent = ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: imageContent,
        );
      }

      if (border != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : (borderRadius ?? BorderRadius.circular(16)),
            border: border,
          ),
          child: imageContent,
        );
      }

      return SizedBox(
        width: size,
        height: size,
        child: imageContent,
      );
    }

    return _buildFallbackIcon(bg, fg, iSize);
  }

  Widget _buildFallbackIcon(Color bg, Color fg, double iSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : (borderRadius ?? BorderRadius.circular(16)),
        border: border,
      ),
      child: Center(
        child: Icon(
          _getMedicineIcon(formFactor),
          color: fg,
          size: iSize,
        ),
      ),
    );
  }

  IconData _getMedicineIcon(String form) {
    switch (form.toLowerCase()) {
      case 'capsule':
        return Icons.medication_liquid;
      case 'liquid':
        return Icons.water_drop;
      case 'drops':
        return Icons.opacity;
      case 'injection':
        return Icons.vaccines;
      case 'spray':
        return Icons.air;
      case 'tablet':
      default:
        return Icons.medication;
    }
  }
}
