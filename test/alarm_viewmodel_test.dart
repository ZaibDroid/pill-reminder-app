import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/models/dose_log.dart';
import 'package:pill_reminder_app/core/models/emergency_contact.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/repositories/emergency_contact_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/services/alarm_service.dart';
import 'package:pill_reminder_app/core/services/audio_alarm_service.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/ui/viewmodels/alarm_viewmodel.dart';

class MockDatabaseService extends DatabaseService {}

class MockMedicineRepository extends MedicineRepository {
  Medicine? mockMedicine;
  bool updateCalled = false;

  MockMedicineRepository() : super(databaseService: MockDatabaseService());

  @override
  Future<Medicine?> getMedicine(int id) async => mockMedicine;

  @override
  Future<int> updateMedicine(Medicine medicine) async {
    updateCalled = true;
    mockMedicine = medicine;
    return medicine.id;
  }
}

class MockDoseLogRepository extends DoseLogRepository {
  final List<DoseLog> savedLogs = [];

  MockDoseLogRepository() : super(databaseService: MockDatabaseService());

  @override
  Future<int> saveDoseLog(DoseLog log) async {
    savedLogs.add(log);
    return 1;
  }
}

class MockAlarmService extends AlarmService {
  bool snoozeCalled = false;
  int? lastSnoozeDuration;

  @override
  Future<void> snoozeAlarm({
    required Medicine medicine,
    required ReminderTime reminder,
    int durationMinutes = 10,
    int? doseLogId,
  }) async {
    snoozeCalled = true;
    lastSnoozeDuration = durationMinutes;
  }
}

class MockAudioAlarmService extends AudioAlarmService {
  bool startAlarmCalled = false;
  bool stopAlarmCalled = false;

  @override
  Future<void> startAlarm({
    String? soundName,
    bool enableVibration = true,
  }) async {
    startAlarmCalled = true;
  }

  @override
  Future<void> stopAlarm() async {
    stopAlarmCalled = true;
  }
}

class MockEmergencyContactRepository extends EmergencyContactRepository {
  List<EmergencyContact> mockContacts = [];

  MockEmergencyContactRepository() : super(databaseService: MockDatabaseService());

  @override
  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    return mockContacts;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicineRepository mockMedRepo;
  late MockDoseLogRepository mockDoseLogRepo;
  late MockAlarmService mockAlarmService;
  late MockAudioAlarmService mockAudioAlarmService;
  late MockEmergencyContactRepository mockEmergencyRepo;
  late AlarmViewModel viewModel;

  Medicine createTestMedicine({
    int id = 1,
    String name = 'Metformin',
    double dosageValue = 500,
    int stock = 10,
  }) {
    final med = Medicine()
      ..name = name
      ..dosageValue = dosageValue
      ..dosageUnit = 'mg'
      ..formFactor = 'tablet'
      ..currentStock = stock
      ..frequency = FrequencyType.daily
      ..mealType = MealType.afterMeal
      ..startDate = DateTime.now();
    med.id = id;
    return med;
  }

  setUp(() {
    mockMedRepo = MockMedicineRepository();
    mockDoseLogRepo = MockDoseLogRepository();
    mockAlarmService = MockAlarmService();
    mockAudioAlarmService = MockAudioAlarmService();
    mockEmergencyRepo = MockEmergencyContactRepository();

    viewModel = AlarmViewModel(
      medicineRepository: mockMedRepo,
      doseLogRepository: mockDoseLogRepo,
      alarmService: mockAlarmService,
      audioAlarmService: mockAudioAlarmService,
      emergencyContactRepository: mockEmergencyRepo,
    );
  });

  group('AlarmViewModel Tests', () {
    test('initializeAlarm loads medicine, contacts and starts alarm ringtone', () async {
      final med = createTestMedicine();
      mockMedRepo.mockMedicine = med;

      final contact = EmergencyContact()
        ..fullName = 'Dr. Sarah'
        ..phoneNumber = '+1234567890'
        ..isPrimary = true;
      mockEmergencyRepo.mockContacts = [contact];

      await viewModel.initializeAlarm(medicineId: 1);

      expect(viewModel.medicine, isNotNull);
      expect(viewModel.medicine!.name, 'Metformin');
      expect(viewModel.primaryCaregiverContact?.fullName, 'Dr. Sarah');
      expect(viewModel.hasCaregiver, isTrue);
      expect(mockAudioAlarmService.startAlarmCalled, isTrue);
    });

    test('markAsTaken stops alarm, saves taken log, and decrements stock', () async {
      final med = createTestMedicine(stock: 5);
      viewModel.medicine = med;

      await viewModel.markAsTaken();

      expect(mockAudioAlarmService.stopAlarmCalled, isTrue);
      expect(mockDoseLogRepo.savedLogs.length, 1);
      expect(mockDoseLogRepo.savedLogs.first.status, MedicineStatus.taken);
      expect(med.currentStock, 4);
      expect(mockMedRepo.updateCalled, isTrue);
    });

    test('snooze stops alarm and schedules 10-minute snooze', () async {
      final med = createTestMedicine();
      viewModel.medicine = med;

      await viewModel.snooze(durationMinutes: 10);

      expect(mockAudioAlarmService.stopAlarmCalled, isTrue);
      expect(mockAlarmService.snoozeCalled, isTrue);
      expect(mockAlarmService.lastSnoozeDuration, 10);
    });

    test('skipDose stops alarm and logs dose as skipped', () async {
      final med = createTestMedicine();
      viewModel.medicine = med;

      await viewModel.skipDose(reason: 'Felt nauseous');

      expect(mockAudioAlarmService.stopAlarmCalled, isTrue);
      expect(mockDoseLogRepo.savedLogs.length, 1);
      final saved = mockDoseLogRepo.savedLogs.first;
      expect(saved.status, MedicineStatus.skipped);
      expect(saved.skipReason, 'Felt nauseous');
    });

    test('dispose stops alarm sound', () {
      viewModel.dispose();
      expect(mockAudioAlarmService.stopAlarmCalled, isTrue);
    });
  });
}
