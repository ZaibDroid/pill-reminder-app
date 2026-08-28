import 'package:intl/intl.dart';
import '../enums/medicine_status.dart';
import '../enums/time_slot.dart';
import 'dose_log.dart';
import 'medicine.dart';
import 'reminder_time.dart';

/// Model encapsulating a scheduled timeline dose item for the Home screen.
class TimelineDoseItem {
  final Medicine medicine;
  final ReminderTime? reminderTime;
  final DoseLog? doseLog;
  final DateTime scheduledTime;
  final MedicineStatus status;

  const TimelineDoseItem({
    required this.medicine,
    this.reminderTime,
    this.doseLog,
    required this.scheduledTime,
    required this.status,
  });

  /// Time slot based on scheduled hour.
  TimeSlot get timeSlot => TimeSlot.fromHour(scheduledTime.hour);

  /// Formatted time string (e.g., "08:00 AM").
  String get formattedTime => DateFormat('hh:mm a').format(scheduledTime);

  /// Formatted 24-hour time string (e.g., "08:00").
  String get formatted24HourTime => DateFormat('HH:mm').format(scheduledTime);

  bool get isTaken => status == MedicineStatus.taken;
  bool get isSkipped => status == MedicineStatus.skipped;
  bool get isMissed => status == MedicineStatus.missed;
  bool get isPending => status == MedicineStatus.pending;

  TimelineDoseItem copyWith({
    Medicine? medicine,
    ReminderTime? reminderTime,
    DoseLog? doseLog,
    DateTime? scheduledTime,
    MedicineStatus? status,
  }) {
    return TimelineDoseItem(
      medicine: medicine ?? this.medicine,
      reminderTime: reminderTime ?? this.reminderTime,
      doseLog: doseLog ?? this.doseLog,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
    );
  }
}
