import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/models/emergency_contact.dart';
import 'package:pill_reminder_app/core/repositories/emergency_contact_repository.dart';
import 'package:pill_reminder_app/core/repositories/user_settings_repository.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/ui/custom_widgets/empty_state_widget.dart';
import 'package:pill_reminder_app/ui/screens/emergency/emergency_contacts_screen.dart';
import 'package:pill_reminder_app/ui/screens/emergency/widgets/emergency_contact_card.dart';
import 'package:pill_reminder_app/ui/screens/emergency/widgets/emergency_header.dart';
import 'package:pill_reminder_app/ui/screens/emergency/widgets/lock_screen_setting_card.dart';
import 'package:pill_reminder_app/ui/viewmodels/emergency_viewmodel.dart';

Widget _buildTestWrapper(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late DatabaseService databaseService;
  late EmergencyContactRepository emergencyContactRepository;
  late UserSettingsRepository userSettingsRepository;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_emerg_widget_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    emergencyContactRepository = EmergencyContactRepository(databaseService: databaseService);
    userSettingsRepository = UserSettingsRepository(databaseService: databaseService);
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('EmergencyContactsScreen Integration Tests', () {
    testWidgets('Displays EmptyStateWidget when no emergency contacts exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final viewModel = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadContacts();
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmergencyHeader), findsOneWidget);
      expect(find.byType(LockScreenSettingCard), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No Emergency Contacts'), findsOneWidget);
      expect(find.text('Add Emergency Contact'), findsWidgets);
    });

    testWidgets('Renders real primary and secondary EmergencyContactCards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.runAsync(() async {
        final c1 = EmergencyContact()
          ..fullName = 'Dr. Sarah Mitchell'
          ..phoneNumber = '+1 555-123-4567'
          ..relationship = 'Cardiologist'
          ..isPrimary = true;
        await emergencyContactRepository.saveEmergencyContact(c1);

        final c2 = EmergencyContact()
          ..fullName = 'Alice Johnson'
          ..phoneNumber = '+1 555-987-6543'
          ..relationship = 'Daughter'
          ..isPrimary = false;
        await emergencyContactRepository.saveEmergencyContact(c2);
      });

      final viewModel = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadContacts();
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmptyStateWidget), findsNothing);
      expect(find.byType(EmergencyContactCard), findsNWidgets(2));
      expect(find.text('Dr. Sarah Mitchell'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('Call Now'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    });

    testWidgets('Adding contact via viewModel persists and updates UI', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final viewModel = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadContacts();
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmptyStateWidget), findsOneWidget);

      await tester.runAsync(() async {
        await viewModel.addContact(
          fullName: 'Emergency Doc',
          phoneNumber: '555-888-9999',
          relationship: 'Physician',
          isPrimary: true,
        );
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmptyStateWidget), findsNothing);
      expect(find.text('Emergency Doc'), findsOneWidget);
      expect(find.text('555-888-9999'), findsOneWidget);
      expect(find.text('Physician'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
    });

    testWidgets('Deleting contact removes card from screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late int contactId;
      await tester.runAsync(() async {
        final c = EmergencyContact()
          ..fullName = 'Bob Temporary'
          ..phoneNumber = '555-000-1111';
        contactId = await emergencyContactRepository.saveEmergencyContact(c);
      });

      final viewModel = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadContacts();
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bob Temporary'), findsOneWidget);

      await tester.runAsync(() async {
        await viewModel.deleteContact(contactId);
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bob Temporary'), findsNothing);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('Toggling primary star updates contact to PRIMARY', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late int contactId;
      await tester.runAsync(() async {
        final c = EmergencyContact()
          ..fullName = 'Carol Caregiver'
          ..phoneNumber = '555-333-4444'
          ..isPrimary = false;
        contactId = await emergencyContactRepository.saveEmergencyContact(c);
      });

      final viewModel = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadContacts();
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('PRIMARY'), findsNothing);

      await tester.runAsync(() async {
        await viewModel.setPrimaryContact(contactId);
      });

      await tester.pumpWidget(_buildTestWrapper(EmergencyContactsScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('PRIMARY'), findsOneWidget);
      expect(find.text('Call Now'), findsOneWidget);
    });
  });
}
