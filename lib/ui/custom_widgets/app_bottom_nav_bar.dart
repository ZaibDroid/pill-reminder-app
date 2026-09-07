import 'package:flutter/material.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable Bottom Navigation Bar matching the modern MediAlert design
/// featuring an elevated centered Floating Action Button (+) for quick action.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onAddPressed;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 64 + bottomPadding + 16,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background navigation card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 14,
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Tab 0: Dashboard
                      Expanded(
                        child: _buildNavItem(
                          index: 0,
                          label: 'Dashboard',
                          activeIcon: Icons.home_rounded,
                          inactiveIcon: Icons.home_outlined,
                          primaryColor: primaryColor,
                          onSurfaceVariant: onSurfaceVariant,
                        ),
                      ),
                      // Tab 1: History
                      Expanded(
                        child: _buildNavItem(
                          index: 1,
                          label: 'History',
                          activeIcon: Icons.history_rounded,
                          inactiveIcon: Icons.history_outlined,
                          primaryColor: primaryColor,
                          onSurfaceVariant: onSurfaceVariant,
                        ),
                      ),
                      // Center Spacer for Floating Action Button
                      const SizedBox(width: 58),
                      // Tab 2: Reports
                      Expanded(
                        child: _buildNavItem(
                          index: 2,
                          label: 'Reports',
                          activeIcon: Icons.analytics_rounded,
                          inactiveIcon: Icons.analytics_outlined,
                          primaryColor: primaryColor,
                          onSurfaceVariant: onSurfaceVariant,
                        ),
                      ),
                      // Tab 3: Settings
                      Expanded(
                        child: _buildNavItem(
                          index: 3,
                          label: 'Settings',
                          activeIcon: Icons.settings_rounded,
                          inactiveIcon: Icons.settings_outlined,
                          primaryColor: primaryColor,
                          onSurfaceVariant: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Elevated Center Floating Action Button (+)
          Positioned(
            top: 0,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onAddPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                    border: Border.all(
                      color: surfaceColor,
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.38),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required Color primaryColor,
    required Color onSurfaceVariant,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? primaryColor : onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isSelected ? primaryColor : onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
