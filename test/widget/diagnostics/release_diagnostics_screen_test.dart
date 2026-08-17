import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enterprise_field_service/features/admin/presentation/views/release_diagnostics_screen.dart';
import 'package:enterprise_field_service/core/services/crash_reporting_service.dart';
import 'package:enterprise_field_service/core/services/analytics_service.dart';
import 'package:enterprise_field_service/core/services/performance_tracker_service.dart';
import 'package:enterprise_field_service/core/services/version_service.dart';

void main() {
  group('ReleaseDiagnosticsScreen Widget Tests', () {
    late CrashReportingService mockCrashService;
    late AnalyticsService mockAnalyticsService;
    late PerformanceTrackerService mockPerfTracker;
    late VersionService mockVersionService;

    setUp(() {
      mockCrashService = CrashReportingService();
      mockAnalyticsService = AnalyticsService();
      mockPerfTracker = PerformanceTrackerService();
      mockVersionService = VersionService();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          crashReportingServiceProvider.overrideWithValue(mockCrashService),
          analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
          performanceTrackerProvider.overrideWithValue(mockPerfTracker),
          versionServiceProvider.overrideWithValue(mockVersionService),
        ],
        child: const MaterialApp(
          home: ReleaseDiagnosticsScreen(),
        ),
      );
    }

    testWidgets('Renders Title, Tabs and Performance Tab default content', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Title & Subtitle check
      expect(find.text('Production Release Diagnostics'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Crashlytics'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Version & Pipeline'), findsOneWidget);

      // Performance Tab content
      expect(find.text('REAL-TIME FRAME & MEMORY METRICS'), findsOneWidget);
      expect(find.text('Render FPS'), findsOneWidget);
      expect(find.text('Frame Drops'), findsOneWidget);
    });

    testWidgets('Switches to Crashlytics Tab and triggers crash simulation', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Crashlytics tab
      final crashlyticsTab = find.text('Crashlytics');
      await tester.tap(crashlyticsTab);
      await tester.pumpAndSettle();

      expect(find.text('CRASHLYTICS DIAGNOSTIC ACTIONS'), findsOneWidget);
      expect(find.text('Log Non-Fatal Error'), findsOneWidget);

      // Tap Log Non-Fatal Error button
      final logErrorBtn = find.text('Log Non-Fatal Error');
      await tester.tap(logErrorBtn);
      await tester.pumpAndSettle();

      // Verify SnackBar or Log entry created
      expect(mockCrashService.recentLogs, isNotEmpty);
    });

    testWidgets('Switches to Version & Pipeline Tab and displays semver info', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Version tab
      final versionTab = find.text('Version & Pipeline');
      await tester.tap(versionTab);
      await tester.pumpAndSettle();

      expect(find.text('APPLICATION VERSION STATUS'), findsOneWidget);
      expect(find.text('1.0.0+1'), findsOneWidget);
      expect(find.text('COMPLIANT (UP TO DATE)'), findsOneWidget);
    });
  });
}
