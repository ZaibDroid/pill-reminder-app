import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class HistoryCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onTodayPressed;

  const HistoryCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onTodayPressed,
  });

  @override
  State<HistoryCalendarStrip> createState() => _HistoryCalendarStripState();
}

class _HistoryCalendarStripState extends State<HistoryCalendarStrip> {
  late ScrollController _scrollController;
  static const double _itemWidth = 54.0;
  static const double _itemSpacing = 8.0;
  static const double _horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant HistoryCalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate(animate: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate({required bool animate}) {
    if (!_scrollController.hasClients) return;

    final selectedIndex = widget.selectedDate.day - 1;
    final screenWidth = MediaQuery.of(context).size.width;

    // Center position of selected item relative to scroll start
    final itemCenter = _horizontalPadding + (selectedIndex * (_itemWidth + _itemSpacing)) + (_itemWidth / 2);
    final targetOffset = itemCenter - (screenWidth / 2);

    final maxScroll = _scrollController.position.maxScrollExtent;
    final minScroll = _scrollController.position.minScrollExtent;
    final clampedOffset = targetOffset.clamp(minScroll, maxScroll);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final monthYearStr = DateFormat('MMMM yyyy').format(widget.selectedDate);
    final now = DateTime.now();

    // Generate days for the entire selected month (1st to last day of month)
    final totalDaysInMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0).day;
    final days = List.generate(totalDaysInMonth, (index) {
      return DateTime(widget.selectedDate.year, widget.selectedDate.month, index + 1);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      final prevMonth = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month - 1,
                        1,
                      );
                      widget.onDateSelected(prevMonth);
                    },
                    borderRadius: AppRadius.radiusFull,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 22,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    monthYearStr,
                    style: AppTextStyles.labelMd.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      final nextMonth = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month + 1,
                        1,
                      );
                      widget.onDateSelected(nextMonth);
                    },
                    borderRadius: AppRadius.radiusFull,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onTodayPressed,
                borderRadius: AppRadius.radiusSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'Today',
                        style: AppTextStyles.labelSm.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: _itemSpacing),
            itemBuilder: (context, index) {
              final dayDate = days[index];
              final isSelected = dayDate.year == widget.selectedDate.year &&
                  dayDate.month == widget.selectedDate.month &&
                  dayDate.day == widget.selectedDate.day;
              final isToday = dayDate.year == now.year &&
                  dayDate.month == now.month &&
                  dayDate.day == now.day;
              final dayName = DateFormat('E').format(dayDate);
              final dayNumber = dayDate.day.toString();

              final unselectedBg = theme.colorScheme.surface;
              final unselectedBorderColor = isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.8)
                  : theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4);

              return InkWell(
                onTap: () => widget.onDateSelected(dayDate),
                borderRadius: AppRadius.radiusLg,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _itemWidth,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : unselectedBg,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : unselectedBorderColor,
                      width: (isToday || isSelected) ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayName,
                        style: AppTextStyles.labelSm.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayNumber,
                        style: AppTextStyles.headlineSm.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
