import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';

/// A reusable profile hero card displaying patient avatar,
/// active status badge, full name, medical ID, and a dedicated edit button.
class UserProfileCard extends StatelessWidget {
  final String userName;
  final String patientId;
  final String? profileImagePath;
  final VoidCallback? onEdit;
  final String statusLabel;
  final Color statusColor;
  final bool showEditButton;
  final EdgeInsetsGeometry margin;

  const UserProfileCard({
    super.key,
    required this.userName,
    required this.patientId,
    this.profileImagePath,
    this.onEdit,
    this.statusLabel = 'ACTIVE PATIENT',
    this.statusColor = const Color(0xFF007432),
    this.showEditButton = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final imageExists = profileImagePath != null && File(profileImagePath!).existsSync();

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status Badge & Dedicated Edit Profile Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Active Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF003816).withValues(alpha: 0.6)
                        : const Color(0xFFE8F8EE),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF007432).withValues(alpha: 0.5)
                          : const Color(0xFFB5EDC7),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF4AE176) : statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF6BFF8F) : const Color(0xFF005321),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dedicated Edit Profile Button
                if (showEditButton && onEdit != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 13,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Main Info Row: Clean Avatar + Name & Medical ID
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Clean Avatar without camera icon overlay
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: imageExists
                        ? Image.file(
                            File(profileImagePath!),
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: primaryColor,
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name and Medical ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          fontSize: 19,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'ID: $patientId',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
