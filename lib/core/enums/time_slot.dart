/// Representation of chronological time slots on the Home dashboard as defined in PRD Section 8.3.
enum TimeSlot {
  morning('Morning', '🌅'),
  afternoon('Afternoon', '☀️'),
  evening('Evening', '🌆'),
  night('Night', '🌙');

  final String title;
  final String icon;

  const TimeSlot(this.title, this.icon);

  /// Determines time slot from an hour (0..23).
  /// - Morning: 05:00 - 11:59 (05:00 <= hour < 12:00)
  /// - Afternoon: 12:00 - 16:59 (12:00 <= hour < 17:00)
  /// - Evening: 17:00 - 21:59 (17:00 <= hour < 22:00)
  /// - Night: 22:00 - 04:59 (22:00 <= hour < 05:00)
  static TimeSlot fromHour(int hour) {
    if (hour >= 5 && hour < 12) {
      return TimeSlot.morning;
    } else if (hour >= 12 && hour < 17) {
      return TimeSlot.afternoon;
    } else if (hour >= 17 && hour < 22) {
      return TimeSlot.evening;
    } else {
      return TimeSlot.night;
    }
  }
}
