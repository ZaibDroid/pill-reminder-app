import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_test_');
    databaseService = DatabaseService();
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DatabaseService Lifecycle & Instance Tests', () {
    test('Throws StateError if isar is accessed before init', () {
      expect(databaseService.isOpen, isFalse);
      expect(() => databaseService.isar, throwsStateError);
    });

    test('Initializes successfully and opens isolated Isar instance', () async {
      await databaseService.init(
        directory: tempDir.path,
        name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
        inspector: false,
      );

      expect(databaseService.isOpen, isTrue);
      expect(databaseService.isar, isNotNull);
      expect(databaseService.isar.isOpen, isTrue);
    });

    test('Re-calling init on an already open database does not throw', () async {
      final dbName = 'test_db_${DateTime.now().microsecondsSinceEpoch}';
      await databaseService.init(
        directory: tempDir.path,
        name: dbName,
        inspector: false,
      );

      expect(databaseService.isOpen, isTrue);

      // Call init again
      await databaseService.init(
        directory: tempDir.path,
        name: dbName,
        inspector: false,
      );

      expect(databaseService.isOpen, isTrue);
    });

    test('Exposed Isar instance performs transactions and CRUD operations', () async {
      await databaseService.init(
        directory: tempDir.path,
        name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
        inspector: false,
      );

      final isar = databaseService.isar;

      // 1. Create / Save
      final medicine = Medicine()
        ..name = 'Amoxicillin'
        ..dosageValue = 500.0
        ..dosageUnit = 'mg'
        ..mealType = MealType.afterMeal
        ..frequency = FrequencyType.daily
        ..currentStock = 30
        ..lowStockThreshold = 5
        ..isRefillAlertEnabled = true;

      await isar.writeTxn(() async {
        await isar.medicines.put(medicine);
      });

      expect(medicine.id, isPositive);

      // 2. Read
      final fetched = await isar.medicines.get(medicine.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Amoxicillin'));
      expect(fetched.dosageValue, equals(500.0));

      // 3. Update
      await isar.writeTxn(() async {
        fetched.dosageValue = 250.0;
        await isar.medicines.put(fetched);
      });

      final updated = await isar.medicines.get(medicine.id);
      expect(updated!.dosageValue, equals(250.0));

      // 4. Delete
      await isar.writeTxn(() async {
        await isar.medicines.delete(medicine.id);
      });

      final deleted = await isar.medicines.get(medicine.id);
      expect(deleted, isNull);
    });

    test('Closes database properly and updates isOpen state', () async {
      await databaseService.init(
        directory: tempDir.path,
        name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
        inspector: false,
      );

      expect(databaseService.isOpen, isTrue);

      await databaseService.close(deleteFromDisk: true);

      expect(databaseService.isOpen, isFalse);
      expect(() => databaseService.isar, throwsStateError);
    });
  });
}
