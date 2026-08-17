import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics Event Representation
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });
}

/// Enterprise Firebase Analytics Service Wrapper.
/// Tracks user engagement, screen view transitions, work order actions,
/// and custom enterprise metrics.
class AnalyticsService {
  final List<AnalyticsEvent> _loggedEvents = [];
  final Map<String, String> _userProperties = {};
  bool _analyticsEnabled = true;

  List<AnalyticsEvent> get loggedEvents => List.unmodifiable(_loggedEvents);
  Map<String, String> get userProperties => Map.unmodifiable(_userProperties);
  bool get isEnabled => _analyticsEnabled;

  /// Log a custom analytics event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    final event = AnalyticsEvent(
      name: name,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    );

    _loggedEvents.insert(0, event);
    if (_loggedEvents.length > 100) {
      _loggedEvents.removeLast();
    }

    if (kDebugMode) {
      debugPrint('📊 [AnalyticsService] Logged Event: "$name" | Params: ${parameters ?? {}}');
    }
  }

  /// Record screen navigation view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        'screen_class': screenClass ?? screenName,
      },
    );
  }

  /// Record User Login event
  Future<void> logLogin({required String method, required String userId}) async {
    await logEvent(
      name: 'login',
      parameters: {
        'method': method,
        'user_id': userId,
      },
    );
  }

  /// Record Work Order Status Update
  Future<void> logWorkOrderUpdated({
    required String orderId,
    required String oldStatus,
    required String newStatus,
  }) async {
    await logEvent(
      name: 'work_order_updated',
      parameters: {
        'order_id': orderId,
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
  }

  /// Record Payment / Invoice Action
  Future<void> logPaymentProcessed({
    required String invoiceId,
    required double amount,
    required String currency,
  }) async {
    await logEvent(
      name: 'payment_processed',
      parameters: {
        'invoice_id': invoiceId,
        'amount': amount,
        'currency': currency,
      },
    );
  }

  /// Set User Property attribute
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    _userProperties[name] = value;
    if (kDebugMode) {
      debugPrint('📊 [AnalyticsService] UserProperty set: $name = $value');
    }
  }

  /// Enable or disable collection (e.g. for GDPR / opt-out)
  void setAnalyticsCollectionEnabled(bool enabled) {
    _analyticsEnabled = enabled;
    if (kDebugMode) {
      debugPrint('📊 [AnalyticsService] Collection enabled set to: $enabled');
    }
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
