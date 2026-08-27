import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/services/alarm_service.dart';
import 'package:pill_reminder_app/core/services/notification_service.dart';

class MockNotificationService extends NotificationService {
  final List<String> calls = [];
  final List<int> cancelledIds = [];
  final List<Map<String, dynamic>> scheduledDaily = [];
  final List<Map<String, dynamic>> scheduledOneTime = [];
  bool throwError = false;

  @override
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    bool enableVibration = true,
  }) async {
    if (throwError) throw Exception('Daily schedule failed');
    calls.add('scheduleDailyNotification');
    scheduledDaily.add({
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
      'payload': payload,
      'enableVibration': enableVibration,
    });
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool enableVibration = true,
  }) async {
    if (throwError) throw Exception('One-time schedule failed');
    calls.add('scheduleNotification');
    scheduledOneTime.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
      'enableVibration': enableVibration,
    });
  }

  @override
  Future<void> cancelNotification(int id) async {
    if (throwError) throw Exception('Cancel failed');
    calls.add('cancelNotification');
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (throwError) throw Exception('CancelAll failed');
    calls.add('cancelAllNotifications');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationService mockNotificationService;
  late AlarmService alarmService;

  Medicine createTestMedicine({
    int id = 1,
    String name = 'Amoxicillin',
    double dosageValue = 500.0,
    String dosageUnit = 'mg',
    MealType mealType = MealType.afterMeal,
    FrequencyType frequency = FrequencyType.daily,
    List<int>? specificDays,
  }) {
    final med = Medicine()
      ..name = name
      ..dosageValue = dosageValue
      ..dosageUnit = dosageUnit
      ..mealType = mealType
      ..frequency = frequency
      ..specificDaysOfWeek = specificDays ?? []
      ..startDate = DateTime.now();
    med.id = id;
    return med;
  }

  ReminderTime createTestReminder({
    int id = 10,
    int hour = 8,
    int minute = 30,
    bool isActive = true,
    bool isVibrationEnabled = true,
  }) {
    final reminder = ReminderTime()
      ..hour = hour
      ..minute = minute
      ..isActive = isActive
      ..isVibrationEnabled = isVibrationEnabled;
    reminder.id = id;
    return reminder;
  }

  setUp(() {
    mockNotificationService = MockNotificationService();
    alarmService = AlarmService(notificationService: mockNotificationService);
  });

  group('AlarmService - GetIt Locator Registration', () {
    test('AlarmService is registered and resolvable from GetIt locator', () {
      if (locator.isRegistered<AlarmService>()) {
        locator.unregister<AlarmService>();
      }
      setupLocator();

      final service = locator<AlarmService>();
      expect(service, isNotNull);
      expect(service, isA<AlarmService>());
    });
  });

  group('AlarmService - Helpers & String Formatting', () {
    test('getMealGuidanceText returns expected instructions for all MealTypes', () {
      expect(alarmService.getMealGuidanceText(MealType.beforeMeal), 'Take before food');
      expect(alarmService.getMealGuidanceText(MealType.afterMeal), 'Take after food');
      expect(alarmService.getMealGuidanceText(MealType.withMeal), 'Take with food');
      expect(alarmService.getMealGuidanceText(MealType.noRelation), '');
    });

    test('formatDosage formats integer and decimal values accurately', () {
      expect(alarmService.formatDosage(500.0, 'mg'), '500 mg');
      expect(alarmService.formatDosage(2.5, 'Tablet'), '2.5 Tablet');
      expect(alarmService.formatDosage(1.0, 'Puff'), '1 Puff');
    });

    test('buildAlarmTitle generates readable reminder title', () {
      final med = createTestMedicine(name: 'Metformin');
      expect(alarmService.buildAlarmTitle(med), 'Time for Metformin');
    });

    test('buildAlarmBody generates dosage and meal information', () {
      final med = createTestMedicine(
        name: 'Lipitor',
        dosageValue: 20.0,
        dosageUnit: 'mg',
        mealType: MealType.afterMeal,
      );
      expect(alarmService.buildAlarmBody(med), '20 mg • Take after food');

      final medNoRelation = createTestMedicine(
        name: 'Vitamin D',
        dosageValue: 1000.0,
        dosageUnit: 'IU',
        mealType: MealType.noRelation,
      );
      expect(alarmService.buildAlarmBody(medNoRelation), '1000 IU');
    });

    test('buildAlarmPayload generates JSON string with metadata', () {
      final payload = alarmService.buildAlarmPayload(
        medicineId: 1,
        reminderTimeId: 10,
        doseLogId: 99,
      );
      expect(payload, contains('"type":"medication_alarm"'));
      expect(payload, contains('"medicineId":1'));
      expect(payload, contains('"reminderTimeId":10'));
      expect(payload, contains('"doseLogId":99'));
    });
  });

  group('AlarmService - Scheduling Alarms', () {
    test('scheduleMedicationAlarm schedules daily notification for daily frequency', () async {
      final med = createTestMedicine(frequency: FrequencyType.daily);
      final reminder = createTestReminder(id: 10, hour: 9, minute: 0);

      await alarmService.scheduleMedicationAlarm(med, reminder);

      expect(mockNotificationService.calls, contains('scheduleDailyNotification'));
      expect(mockNotificationService.scheduledDaily.length, 1);
      final entry = mockNotificationService.scheduledDaily.first;
      expect(entry['id'], 10);
      expect(entry['hour'], 9);
      expect(entry['minute'], 0);
      expect(entry['title'], 'Time for Amoxicillin');
      expect(entry['body'], '500 mg • Take after food');
    });

    test('scheduleMedicationAlarm cancels alarm when reminder is inactive', () async {
      final med = createTestMedicine();
      final inactiveReminder = createTestReminder(id: 20, isActive: false);

      await alarmService.scheduleMedicationAlarm(med, inactiveReminder);

      expect(mockNotificationService.calls, isNot(contains('scheduleDailyNotification')));
      expect(mockNotificationService.calls, contains('cancelNotification'));
      expect(mockNotificationService.cancelledIds, contains(20));
    });

    test('scheduleMedicationAlarm schedules one-time notification for specificDays frequency', () async {
      final med = createTestMedicine(
        frequency: FrequencyType.specificDays,
        specificDays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );
      final reminder = createTestReminder(id: 30, hour: 14, minute: 15);

      await alarmService.scheduleMedicationAlarm(med, reminder);

      expect(mockNotificationService.calls, contains('scheduleNotification'));
      expect(mockNotificationService.scheduledOneTime.length, 1);
      final entry = mockNotificationService.scheduledOneTime.first;
      expect(entry['id'], 30);
      expect(entry['title'], 'Time for Amoxicillin');
    });

    test('scheduleAllRemindersForMedicine schedules multiple reminders', () async {
      final med = createTestMedicine(id: 5);
      final reminders = [
        createTestReminder(id: 51, hour: 8, minute: 0),
        createTestReminder(id: 52, hour: 14, minute: 0),
        createTestReminder(id: 53, hour: 20, minute: 0),
      ];

      await alarmService.scheduleAllRemindersForMedicine(med, reminders);

      expect(mockNotificationService.scheduledDaily.length, 3);
      final ids = mockNotificationService.scheduledDaily.map((e) => e['id']).toList();
      expect(ids, [51, 52, 53]);
    });

    test('scheduleOneTimeAlarm schedules single dose with optional doseLogId', () async {
      final med = createTestMedicine();
      final reminder = createTestReminder(id: 40);
      final scheduledTime = DateTime.now().add(const Duration(hours: 3));

      await alarmService.scheduleOneTimeAlarm(
        medicine: med,
        reminder: reminder,
        scheduledDateTime: scheduledTime,
        doseLogId: 777,
      );

      expect(mockNotificationService.calls, contains('scheduleNotification'));
      final entry = mockNotificationService.scheduledOneTime.first;
      expect(entry['id'], 40);
      expect(entry['payload'], contains('"doseLogId":777'));
    });
  });

  group('AlarmService - Updating & Snooze', () {
    test('updateMedicationAlarm cancels previous alarm and re-schedules active reminder', () async {
      final med = createTestMedicine();
      final reminder = createTestReminder(id: 60, hour: 10, minute: 0, isActive: true);

      await alarmService.updateMedicationAlarm(med, reminder);

      expect(mockNotificationService.cancelledIds, contains(60));
      expect(mockNotificationService.scheduledDaily.length, 1);
    });

    test('updateMedicationAlarm cancels alarm without re-scheduling when inactive', () async {
      final med = createTestMedicine();
      final inactiveReminder = createTestReminder(id: 61, isActive: false);

      await alarmService.updateMedicationAlarm(med, inactiveReminder);

      expect(mockNotificationService.cancelledIds, contains(61));
      expect(mockNotificationService.scheduledDaily, isEmpty);
    });

    test('snoozeAlarm schedules deferred notification with unique snooze ID', () async {
      final med = createTestMedicine(name: 'Aspirin');
      final reminder = createTestReminder(id: 70);

      await alarmService.snoozeAlarm(
        medicine: med,
        reminder: reminder,
        durationMinutes: 15,
        doseLogId: 123,
      );

      expect(mockNotificationService.calls, contains('scheduleNotification'));
      expect(mockNotificationService.scheduledOneTime.length, 1);
      final entry = mockNotificationService.scheduledOneTime.first;
      expect(entry['id'], 100070); // 70 + 100000
      expect(entry['title'], 'Snoozed: Aspirin');
      expect(entry['payload'], contains('"doseLogId":123'));
    });
  });

  group('AlarmService - Cancellation', () {
    test('cancelMedicationAlarm cancels base reminder and potential snooze alarm', () async {
      await alarmService.cancelMedicationAlarm(80);

      expect(mockNotificationService.cancelledIds, contains(80));
      expect(mockNotificationService.cancelledIds, contains(100080));
    });

    test('cancelAlarmsForReminders cancels all given reminders', () async {
      final reminders = [
        createTestReminder(id: 81),
        createTestReminder(id: 82),
      ];

      await alarmService.cancelAlarmsForReminders(reminders);

      expect(mockNotificationService.cancelledIds, contains(81));
      expect(mockNotificationService.cancelledIds, contains(82));
    });

    test('cancelAllAlarms cancels all notifications across the app', () async {
      await alarmService.cancelAllAlarms();

      expect(mockNotificationService.calls, contains('cancelAllNotifications'));
    });
  });

  group('AlarmService - Error Resilience', () {
    test('catches underlying exceptions without rethrowing', () async {
      mockNotificationService.throwError = true;
      final med = createTestMedicine();
      final reminder = createTestReminder(id: 90);

      await expectLater(
        alarmService.scheduleMedicationAlarm(med, reminder),
        completes,
      );

      await expectLater(
        alarmService.snoozeAlarm(medicine: med, reminder: reminder),
        completes,
      );

      await expectLater(
        alarmService.cancelMedicationAlarm(90),
        completes,
      );

      await expectLater(
        alarmService.cancelAllAlarms(),
        completes,
      );
    });
  });
}
