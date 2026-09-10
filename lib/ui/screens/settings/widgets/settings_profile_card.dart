import 'package:flutter/material.dart';
import '../../../custom_widgets/user_profile_card.dart';

class SettingsProfileCard extends StatelessWidget {
  final String userName;
  final String patientId;
  final String? profileImagePath;
  final VoidCallback? onEdit;

  const SettingsProfileCard({
    super.key,
    required this.userName,
    required this.patientId,
    this.profileImagePath,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return UserProfileCard(
      userName: userName,
      patientId: patientId,
      profileImagePath: profileImagePath,
      onEdit: onEdit,
    );
  }
}
