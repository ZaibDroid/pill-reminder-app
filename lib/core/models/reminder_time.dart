import 'package:isar/isar.dart';
import 'medicine.dart';

part 'reminder_time.g.dart';

@collection
class ReminderTime {
  Id id = Isar.autoIncrement;

  final medicine = IsarLink<Medicine>();

  int hour = 8;

  int minute = 0;

  bool isActive = true;

  String soundRingtone = 'default';

  bool isVibrationEnabled = true;

  DateTime? lastTriggeredAt;
}
