import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_field_service/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService Unit Tests', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('logEvent records custom events in chronological history', () async {
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      expect(analyticsService.loggedEvents.length, equals(1));
      expect(analyticsService.loggedEvents.first.name, equals('test_event'));
      expect(analyticsService.loggedEvents.first.parameters['key'], equals('value'));
    });

    test('logScreenView dispatches screen_view event', () async {
      await analyticsService.logScreenView(screenName: 'DashboardScreen');

      expect(analyticsService.loggedEvents.length, equals(1));
      final event = analyticsService.loggedEvents.first;
      expect(event.name, equals('screen_view'));
      expect(event.parameters['screen_name'], equals('DashboardScreen'));
    });

    test('setUserProperty stores custom user property attributes', () async {
      await analyticsService.setUserProperty(name: 'user_tier', value: 'enterprise');

      expect(analyticsService.userProperties['user_tier'], equals('enterprise'));
    });

    test('setAnalyticsCollectionEnabled toggles collection', () async {
      analyticsService.setAnalyticsCollectionEnabled(false);
      await analyticsService.logEvent(name: 'disabled_event');

      expect(analyticsService.loggedEvents, isEmpty);
    });
  });
}
