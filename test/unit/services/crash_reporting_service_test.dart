import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_field_service/core/services/crash_reporting_service.dart';

void main() {
  group('CrashReportingService Unit Tests', () {
    late CrashReportingService crashService;

    setUp(() {
      crashService = CrashReportingService();
    });

    test('setUserIdentifier tags user id to crash context', () {
      crashService.setUserIdentifier('usr_test_99');

      expect(crashService.currentUserId, equals('usr_test_99'));
    });

    test('setCustomKey attaches custom report keys', () {
      crashService.setCustomKey('environment', 'staging');

      expect(crashService.customKeys['environment'], equals('staging'));
    });

    test('recordError captures non-fatal errors with stack trace', () {
      crashService.recordError(
        'Test non-fatal exception',
        StackTrace.current,
        reason: 'Unit Test Validation',
        fatal: false,
      );

      expect(crashService.recentLogs.length, equals(1));
      final log = crashService.recentLogs.first;
      expect(log.level, equals('ERROR'));
      expect(log.message, contains('Test non-fatal exception'));
    });

    test('simulateNonFatalCrash records exception into log feed', () {
      crashService.simulateNonFatalCrash();

      expect(crashService.recentLogs, isNotEmpty);
      expect(crashService.recentLogs.first.message, contains('Simulated Non-Fatal'));
    });

    test('logInfo adds breadcrumb entry', () {
      crashService.logInfo('User navigated to profile');

      expect(crashService.recentLogs.length, equals(1));
      expect(crashService.recentLogs.first.level, equals('INFO'));
      expect(crashService.recentLogs.first.message, equals('User navigated to profile'));
    });
  });
}
