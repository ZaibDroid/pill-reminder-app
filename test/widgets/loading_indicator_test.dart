import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/core/constants/app_colors.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_indicator.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/primary_button.dart';

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
  group('AppLoadingIndicator Widget Tests', () {
    testWidgets('Renders SpinKitSquareCircle with default parameters', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(
          const AppLoadingIndicator(),
        ),
      );

      expect(find.byType(SpinKitSquareCircle), findsOneWidget);
      final spinkit = tester.widget<SpinKitSquareCircle>(find.byType(SpinKitSquareCircle));
      expect(spinkit.color, equals(AppColors.primary));
      expect(spinkit.size, equals(28.0));
    });

    testWidgets('Renders SpinKitSquareCircle with custom color and size', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(
          const AppLoadingIndicator(
            size: 32.0,
            color: Colors.white,
          ),
        ),
      );

      expect(find.byType(SpinKitSquareCircle), findsOneWidget);
      final spinkit = tester.widget<SpinKitSquareCircle>(find.byType(SpinKitSquareCircle));
      expect(spinkit.color, equals(Colors.white));
      expect(spinkit.size, equals(32.0));
    });
  });

  group('LoadingWidget Tests', () {
    testWidgets('Renders AppLoadingIndicator inside LoadingWidget', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(
          const LoadingWidget(),
        ),
      );

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.byType(SpinKitSquareCircle), findsOneWidget);
    });
  });

  group('PrimaryButton Loading State Tests', () {
    testWidgets('Displays normal text when not loading and triggers callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        _buildTestWrapper(
          PrimaryButton(
            text: 'Unlock',
            isLoading: false,
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlock'), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);

      await tester.tap(find.text('Unlock'));
      expect(pressed, isTrue);
    });

    testWidgets('Replaces text with AppLoadingIndicator when isLoading is true', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        _buildTestWrapper(
          PrimaryButton(
            text: 'Unlock',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Unlock'), findsNothing);
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.byType(SpinKitSquareCircle), findsOneWidget);

      // Verify button is disabled while loading (tapping does not trigger callback)
      await tester.tap(find.byType(PrimaryButton));
      expect(pressed, isFalse);
    });
  });
}
