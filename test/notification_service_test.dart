import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/services/notification_service.dart';
import 'package:pill_reminder_app/core/services/permission_service.dart';

class MockPermissionService extends PermissionService {
  bool requestNotificationCalled = false;
  PermissionStatus stubbedStatus = PermissionStatus.granted;

  @override
  Future<PermissionStatus> requestNotificationPermission() async {
    requestNotificationCalled = true;
    return stubbedStatus;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    return stubbedStatus.isGranted;
  }
}

class FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool initialized = false;
  final List<String> calls = [];
  final List<int> cancelledIds = [];
  final List<Map<String, dynamic>> shownNotifications = [];
  final List<Map<String, dynamic>> scheduledNotifications = [];
  List<PendingNotificationRequest> stubbedPending = [];
  List<ActiveNotification> stubbedActive = [];
  bool throwError = false;

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    if (throwError) throw Exception('Initialization failed');
    calls.add('initialize');
    initialized = true;
    return true;
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    if (throwError) throw Exception('Show failed');
    calls.add('show');
    shownNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (throwError) throw Exception('Schedule failed');
    calls.add('zonedSchedule');
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
      'matchDateTimeComponents': matchDateTimeComponents,
    });
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    if (throwError) throw Exception('Cancel failed');
    calls.add('cancel');
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    if (throwError) throw Exception('CancelAll failed');
    calls.add('cancelAll');
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    if (throwError) throw Exception('Pending failed');
    return stubbedPending;
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (throwError) throw Exception('Active failed');
    return stubbedActive;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFlutterLocalNotificationsPlugin fakePlugin;
  late MockPermissionService mockPermissionService;
  late NotificationService notificationService;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    fakePlugin = FakeFlutterLocalNotificationsPlugin();
    mockPermissionService = MockPermissionService();
    notificationService = NotificationService(
      notificationsPlugin: fakePlugin,
      permissionService: mockPermissionService,
    );
  });

  group('NotificationService - GetIt Locator Registration', () {
    test('NotificationService is registered and resolvable from GetIt locator', () {
      if (locator.isRegistered<NotificationService>()) {
        locator.unregister<NotificationService>();
      }
      setupLocator();

      final service = locator<NotificationService>();
      expect(service, isNotNull);
      expect(service, isA<NotificationService>());
    });
  });

  group('NotificationService - Initialization', () {
    test('init initializes plugin and returns true', () async {
      expect(notificationService.isInitialized, isFalse);

      final result = await notificationService.init(requestPermission: false);

      expect(result, isTrue);
      expect(notificationService.isInitialized, isTrue);
      expect(fakePlugin.calls, contains('initialize'));
      expect(mockPermissionService.requestNotificationCalled, isFalse);
    });

    test('init with requestPermission=true delegates to PermissionService', () async {
      final result = await notificationService.init(requestPermission: true);

      expect(result, isTrue);
      expect(mockPermissionService.requestNotificationCalled, isTrue);
    });

    test('re-calling init on already initialized service returns true without re-initializing', () async {
      await notificationService.init();
      final initialCallCount = fakePlugin.calls.length;

      final secondResult = await notificationService.init();

      expect(secondResult, isTrue);
      expect(fakePlugin.calls.length, initialCallCount);
    });
  });

  group('NotificationService - Showing Notifications', () {
    test('showNotification dispatches show to plugin with correct parameters', () async {
      await notificationService.showNotification(
        id: 42,
        title: 'Amoxicillin Reminder',
        body: 'Take 500 mg after breakfast',
        payload: 'payload_42',
      );

      expect(fakePlugin.calls, contains('show'));
      expect(fakePlugin.shownNotifications.length, 1);
      final item = fakePlugin.shownNotifications.first;
      expect(item['id'], 42);
      expect(item['title'], 'Amoxicillin Reminder');
      expect(item['body'], 'Take 500 mg after breakfast');
      expect(item['payload'], 'payload_42');
    });
  });

  group('NotificationService - Scheduling Notifications', () {
    test('scheduleNotification schedules future notification via zonedSchedule', () async {
      final futureDate = DateTime.now().add(const Duration(hours: 2));

      await notificationService.scheduleNotification(
        id: 100,
        title: 'Metformin Reminder',
        body: 'Take 850 mg with dinner',
        scheduledDate: futureDate,
        payload: 'payload_100',
      );

      expect(fakePlugin.calls, contains('zonedSchedule'));
      expect(fakePlugin.scheduledNotifications.length, 1);
      final item = fakePlugin.scheduledNotifications.first;
      expect(item['id'], 100);
      expect(item['title'], 'Metformin Reminder');
      expect(item['body'], 'Take 850 mg with dinner');
      expect(item['payload'], 'payload_100');
    });

    test('scheduleNotification gracefully ignores past date without scheduling', () async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 2));

      await notificationService.scheduleNotification(
        id: 101,
        title: 'Past Reminder',
        body: 'This was in the past',
        scheduledDate: pastDate,
      );

      expect(fakePlugin.calls, isNot(contains('zonedSchedule')));
      expect(fakePlugin.scheduledNotifications, isEmpty);
    });

    test('scheduleDailyNotification schedules daily repeating notification with time match', () async {
      await notificationService.scheduleDailyNotification(
        id: 200,
        title: 'Daily Morning Aspirin',
        body: 'Take 100 mg after breakfast',
        hour: 9,
        minute: 30,
        payload: 'daily_200',
      );

      expect(fakePlugin.calls, contains('zonedSchedule'));
      expect(fakePlugin.scheduledNotifications.length, 1);
      final item = fakePlugin.scheduledNotifications.first;
      expect(item['id'], 200);
      expect(item['title'], 'Daily Morning Aspirin');
      expect(item['matchDateTimeComponents'], DateTimeComponents.time);
    });
  });

  group('NotificationService - Cancellation', () {
    test('cancelNotification cancels specific notification by ID', () async {
      await notificationService.cancelNotification(42);

      expect(fakePlugin.calls, contains('cancel'));
      expect(fakePlugin.cancelledIds, contains(42));
    });

    test('cancelAllNotifications cancels all notifications', () async {
      await notificationService.cancelAllNotifications();

      expect(fakePlugin.calls, contains('cancelAll'));
    });
  });

  group('NotificationService - Querying Notifications', () {
    test('getPendingNotifications returns list of pending requests', () async {
      fakePlugin.stubbedPending = [
        const PendingNotificationRequest(101, 'Test Pill', 'Take 500mg', 'med_101'),
      ];

      final pending = await notificationService.getPendingNotifications();

      expect(pending, isNotEmpty);
      expect(pending.first.id, 101);
      expect(pending.first.title, 'Test Pill');
      expect(pending.first.body, 'Take 500mg');
    });

    test('getActiveNotifications returns active notifications', () async {
      fakePlugin.stubbedActive = [
        const ActiveNotification(
          id: 101,
          channelId: NotificationService.channelId,
          title: 'Test Pill',
          body: 'Take 500mg',
          payload: 'med_101',
        ),
      ];

      final active = await notificationService.getActiveNotifications();

      expect(active, isNotEmpty);
      expect(active.first.id, 101);
      expect(active.first.title, 'Test Pill');
    });
  });

  group('NotificationService - Error Resilience', () {
    test('catches platform exceptions and returns gracefully without crashing', () async {
      fakePlugin.throwError = true;

      final initResult = await notificationService.init();
      expect(initResult, isFalse);

      // Showing notification should not throw
      await expectLater(
        notificationService.showNotification(id: 1, title: 'T', body: 'B'),
        completes,
      );

      // Cancelling notification should not throw
      await expectLater(
        notificationService.cancelNotification(1),
        completes,
      );

      // Cancelling all notifications should not throw
      await expectLater(
        notificationService.cancelAllNotifications(),
        completes,
      );

      // Pending notifications should return empty list on error
      final pending = await notificationService.getPendingNotifications();
      expect(pending, isEmpty);

      // Active notifications should return empty list on error
      final active = await notificationService.getActiveNotifications();
      expect(active, isEmpty);
    });
  });
}
