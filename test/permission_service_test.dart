import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/services/permission_service.dart';

/// Testable subclass of [PermissionService] allowing deterministic platform overrides.
class TestablePermissionService extends PermissionService {
  final bool _overrideIsAndroid;

  TestablePermissionService({bool isAndroid = true})
      : _overrideIsAndroid = isAndroid;

  @override
  bool get isAndroid => _overrideIsAndroid;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('flutter.baseflow.com/permissions/methods');

  late TestablePermissionService androidService;
  late TestablePermissionService iOSService;

  // Permission value integers used by permission_handler:
  // Permission.notification.value -> 17
  // Permission.scheduleExactAlarm.value -> 34
  // PermissionStatus integer values:
  // 0: denied, 1: granted, 2: restricted, 3: limited, 4: permanentlyDenied

  int notificationStatusInt = 1; // Default: granted
  int exactAlarmStatusInt = 1; // Default: granted
  bool openSettingsResult = true;
  List<int> requestedPermissionsList = [];

  setUp(() {
    notificationStatusInt = 1;
    exactAlarmStatusInt = 1;
    openSettingsResult = true;
    requestedPermissionsList = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'checkPermissionStatus':
          final permission = methodCall.arguments as int;
          if (permission == Permission.notification.value) {
            return notificationStatusInt;
          } else if (permission == Permission.scheduleExactAlarm.value) {
            return exactAlarmStatusInt;
          }
          return 0; // denied

        case 'requestPermissions':
          final permissions = List<int>.from(methodCall.arguments as List);
          requestedPermissionsList.addAll(permissions);
          final Map<int, int> results = {};
          for (final p in permissions) {
            if (p == Permission.notification.value) {
              results[p] = notificationStatusInt;
            } else if (p == Permission.scheduleExactAlarm.value) {
              results[p] = exactAlarmStatusInt;
            } else {
              results[p] = 0;
            }
          }
          return results;

        case 'openAppSettings':
          return openSettingsResult;

        default:
          return null;
      }
    });

    androidService = TestablePermissionService(isAndroid: true);
    iOSService = TestablePermissionService(isAndroid: false);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('PermissionService - GetIt Locator Registration', () {
    test('PermissionService is registered and resolvable from GetIt locator', () {
      if (locator.isRegistered<PermissionService>()) {
        locator.unregister<PermissionService>();
      }
      setupLocator();

      final service = locator<PermissionService>();
      expect(service, isNotNull);
      expect(service, isA<PermissionService>());
    });
  });

  group('PermissionService - Notification Permission', () {
    test('checkNotificationPermission returns granted when permission is allowed', () async {
      notificationStatusInt = 1; // granted

      final status = await androidService.checkNotificationPermission();
      expect(status, PermissionStatus.granted);
    });

    test('checkNotificationPermission returns denied when permission is denied', () async {
      notificationStatusInt = 0; // denied

      final status = await androidService.checkNotificationPermission();
      expect(status, PermissionStatus.denied);
    });

    test('isNotificationPermissionGranted returns true when granted', () async {
      notificationStatusInt = 1; // granted

      final isGranted = await androidService.isNotificationPermissionGranted();
      expect(isGranted, isTrue);
    });

    test('isNotificationPermissionGranted returns true when limited (iOS provisional)', () async {
      notificationStatusInt = 3; // limited

      final isGranted = await iOSService.isNotificationPermissionGranted();
      expect(isGranted, isTrue);
    });

    test('isNotificationPermissionGranted returns false when permanently denied', () async {
      notificationStatusInt = 4; // permanentlyDenied

      final isGranted = await androidService.isNotificationPermissionGranted();
      expect(isGranted, isFalse);
    });

    test('requestNotificationPermission requests and returns status', () async {
      notificationStatusInt = 1; // granted

      final status = await androidService.requestNotificationPermission();
      expect(status, PermissionStatus.granted);
      expect(
        requestedPermissionsList,
        contains(Permission.notification.value),
      );
    });
  });

  group('PermissionService - Exact Alarm Permission', () {
    test('Android: checkExactAlarmPermission returns status from platform', () async {
      exactAlarmStatusInt = 1; // granted

      final status = await androidService.checkExactAlarmPermission();
      expect(status, PermissionStatus.granted);
    });

    test('Android: checkExactAlarmPermission returns denied when not granted', () async {
      exactAlarmStatusInt = 0; // denied

      final status = await androidService.checkExactAlarmPermission();
      expect(status, PermissionStatus.denied);
    });

    test('Android: isExactAlarmPermissionGranted returns true when granted', () async {
      exactAlarmStatusInt = 1; // granted

      final isGranted = await androidService.isExactAlarmPermissionGranted();
      expect(isGranted, isTrue);
    });

    test('Android: isExactAlarmPermissionGranted returns false when denied', () async {
      exactAlarmStatusInt = 0; // denied

      final isGranted = await androidService.isExactAlarmPermissionGranted();
      expect(isGranted, isFalse);
    });

    test('Android: requestExactAlarmPermission requests exact alarm permission', () async {
      exactAlarmStatusInt = 1; // granted

      final status = await androidService.requestExactAlarmPermission();
      expect(status, PermissionStatus.granted);
      expect(
        requestedPermissionsList,
        contains(Permission.scheduleExactAlarm.value),
      );
    });

    test('iOS: checkExactAlarmPermission returns granted without querying Android exact alarm', () async {
      exactAlarmStatusInt = 0; // denied on platform

      final status = await iOSService.checkExactAlarmPermission();
      expect(status, PermissionStatus.granted);
    });

    test('iOS: isExactAlarmPermissionGranted always returns true', () async {
      exactAlarmStatusInt = 0; // denied on platform

      final isGranted = await iOSService.isExactAlarmPermissionGranted();
      expect(isGranted, isTrue);
    });

    test('iOS: requestExactAlarmPermission returns granted immediately without requesting', () async {
      final status = await iOSService.requestExactAlarmPermission();
      expect(status, PermissionStatus.granted);
      expect(
        requestedPermissionsList,
        isNot(contains(Permission.scheduleExactAlarm.value)),
      );
    });
  });

  group('PermissionService - hasAllRequiredPermissions', () {
    test('Android: returns true when both notification and exact alarm are granted', () async {
      notificationStatusInt = 1; // granted
      exactAlarmStatusInt = 1; // granted

      final hasAll = await androidService.hasAllRequiredPermissions();
      expect(hasAll, isTrue);
    });

    test('Android: returns false when notification is granted but exact alarm is denied', () async {
      notificationStatusInt = 1; // granted
      exactAlarmStatusInt = 0; // denied

      final hasAll = await androidService.hasAllRequiredPermissions();
      expect(hasAll, isFalse);
    });

    test('Android: returns false when notification is denied even if exact alarm is granted', () async {
      notificationStatusInt = 0; // denied
      exactAlarmStatusInt = 1; // granted

      final hasAll = await androidService.hasAllRequiredPermissions();
      expect(hasAll, isFalse);
    });

    test('iOS: returns true when notification is granted (regardless of exact alarm)', () async {
      notificationStatusInt = 1; // granted
      exactAlarmStatusInt = 0; // denied

      final hasAll = await iOSService.hasAllRequiredPermissions();
      expect(hasAll, isTrue);
    });

    test('iOS: returns false when notification is denied', () async {
      notificationStatusInt = 0; // denied

      final hasAll = await iOSService.hasAllRequiredPermissions();
      expect(hasAll, isFalse);
    });
  });

  group('PermissionService - requestAllRequiredPermissions', () {
    test('Android: requests both notification and exact alarm permissions', () async {
      notificationStatusInt = 1; // granted
      exactAlarmStatusInt = 1; // granted

      final results = await androidService.requestAllRequiredPermissions();

      expect(results.length, 2);
      expect(results[Permission.notification], PermissionStatus.granted);
      expect(results[Permission.scheduleExactAlarm], PermissionStatus.granted);
      expect(
        requestedPermissionsList,
        contains(Permission.notification.value),
      );
      expect(
        requestedPermissionsList,
        contains(Permission.scheduleExactAlarm.value),
      );
    });

    test('iOS: requests only notification permission', () async {
      notificationStatusInt = 1; // granted

      final results = await iOSService.requestAllRequiredPermissions();

      expect(results.length, 1);
      expect(results[Permission.notification], PermissionStatus.granted);
      expect(results.containsKey(Permission.scheduleExactAlarm), isFalse);
      expect(
        requestedPermissionsList,
        contains(Permission.notification.value),
      );
      expect(
        requestedPermissionsList,
        isNot(contains(Permission.scheduleExactAlarm.value)),
      );
    });
  });

  group('PermissionService - openAppSettings', () {
    test('openAppSettings returns true on successful invocation', () async {
      openSettingsResult = true;

      final result = await androidService.openAppSettings();
      expect(result, isTrue);
    });

    test('openAppSettings returns false when invocation fails', () async {
      openSettingsResult = false;

      final result = await androidService.openAppSettings();
      expect(result, isFalse);
    });
  });

  group('PermissionService - Default instance behavior', () {
    test('Default instance uses defaultTargetPlatform', () {
      final service = PermissionService();
      expect(service.isAndroid, defaultTargetPlatform == TargetPlatform.android);
    });
  });
}
