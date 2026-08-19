import 'package:isar/isar.dart';
import '../enums/meal_type.dart';
import '../enums/frequency_type.dart';
import 'reminder_time.dart';
import 'dose_log.dart';

part 'medicine.g.dart';

@collection
class Medicine {
  Id id = Isar.autoIncrement;

  late String name;

  double dosageValue = 0.0;

  String dosageUnit = 'mg';

  String? pillImageLocalPath;

  String formFactor = 'tablet';

  String colorHex = '#00685F';

  @enumerated
  MealType mealType = MealType.noRelation;

  @enumerated
  FrequencyType frequency = FrequencyType.daily;

  List<int> specificDaysOfWeek = [];

  int? intervalHours;

  DateTime startDate = DateTime.now();

  DateTime? endDate;

  bool isOngoing = true;

  String? doctorName;

  String? prescriptionNotes;

  int currentStock = 0;

  int lowStockThreshold = 5;

  bool isRefillAlertEnabled = false;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  final reminders = IsarLinks<ReminderTime>();

  @Backlink(to: 'medicine')
  final doseLogs = IsarLinks<DoseLog>();
}
