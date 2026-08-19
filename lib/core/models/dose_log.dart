import 'package:isar/isar.dart';
import '../enums/medicine_status.dart';
import 'medicine.dart';
import 'reminder_time.dart';

part 'dose_log.g.dart';

@collection
class DoseLog {
  Id id = Isar.autoIncrement;

  final medicine = IsarLink<Medicine>();

  final reminderTime = IsarLink<ReminderTime>();

  @Index()
  DateTime scheduledDateTime = DateTime.now();

  DateTime? actualTakenDateTime;

  @enumerated
  MedicineStatus status = MedicineStatus.pending;

  String? skipReason;

  String? notes;

  DateTime createdAt = DateTime.now();
}
