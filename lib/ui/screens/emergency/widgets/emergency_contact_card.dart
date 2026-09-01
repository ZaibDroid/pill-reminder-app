import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/emergency_contact.dart';

class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback? onSms;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTogglePrimary;

  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.onCall,
    this.onSms,
    required this.onEdit,
    required this.onDelete,
    this.onTogglePrimary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = contact.isPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: isPrimary
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.surfaceContainerHigh,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXl,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isPrimary ? AppColors.primary : AppColors.surfaceVariant,
                width: isPrimary ? 5 : 1,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? AppColors.primaryContainer.withValues(alpha: 0.25)
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariant,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.fullName,
                                style: AppTextStyles.headlineSm.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPrimary) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PRIMARY',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPrimary
                                    ? AppColors.primaryContainer.withValues(alpha: 0.15)
                                    : AppColors.surfaceVariant,
                                borderRadius: AppRadius.radiusFull,
                              ),
                              child: Text(
                                contact.relationship ?? (isPrimary ? 'Primary Physician' : 'Emergency Contact'),
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.phoneNumber,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (contact.email != null && contact.email!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            contact.email!,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTogglePrimary != null)
                    IconButton(
                      icon: Icon(
                        isPrimary ? Icons.star : Icons.star_border,
                        color: isPrimary ? Colors.amber[700] : AppColors.outline,
                        size: 22,
                      ),
                      tooltip: isPrimary ? 'Unset Primary' : 'Set as Primary',
                      onPressed: onTogglePrimary,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPrimary ? AppColors.tertiary : AppColors.primary,
                        foregroundColor: isPrimary ? AppColors.onTertiary : AppColors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onCall,
                      icon: const Icon(Icons.call, size: 18),
                      label: Text(
                        isPrimary ? 'Call Now' : 'Call',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                  if (onSms != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: const Icon(Icons.message_outlined, size: 18),
                      tooltip: 'Send SMS',
                      onPressed: onSms,
                    ),
                  ],
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit Contact',
                    onPressed: onEdit,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    tooltip: 'Delete Contact',
                    onPressed: onDelete,
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
