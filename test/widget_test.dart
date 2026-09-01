import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/app/app.dart';
import 'package:pill_reminder_app/app/locator.dart';

void main() {
  setUp(() {
    if (!locator.isRegistered<PillReminderApp>()) {
      setupLocator();
    }
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PillReminderApp());
    await tester.pump(const Duration(seconds: 3));
  });
}
