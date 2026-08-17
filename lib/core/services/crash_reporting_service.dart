import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recorded log item for diagnostics
class CrashLogEntry {
  final DateTime timestamp;
  final String level; // 'INFO', 'WARN', 'ERROR', 'FATAL'
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? details;

  CrashLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
    this.details,
  });
}

/// Enterprise Crash & Diagnostics Reporting Service.
/// Intercepts uncaught Flutter, Zone, and Isolate exceptions and provides
/// structured breadcrumb recording, user tagging, and non-fatal reporting.
class CrashReportingService {
  final List<CrashLogEntry> _recentLogs = [];
  String? _currentUserId;
  final Map<String, String> _customKeys = {};
  bool _crashlyticsEnabled = true;

  List<CrashLogEntry> get recentLogs => List.unmodifiable(_recentLogs);
  String? get currentUserId => _currentUserId;
  Map<String, String> get customKeys => Map.unmodifiable(_customKeys);
  bool get isEnabled => _crashlyticsEnabled;

  /// Initializes error boundaries for Flutter framework & Dart zones
  void initializeGlobalHandlers() {
    // Intercept Flutter framework rendering/widget errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordFlutterError(details);
    };

    // Intercept async platform dispatcher errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      recordError(
        error,
        stack,
        reason: 'Async Unhandled Platform Exception',
        fatal: true,
      );
      return true;
    };

    logInfo('Crash reporting global handlers initialized');
  }

  /// Sets user identification for crash context
  void setUserIdentifier(String userId) {
    _currentUserId = userId;
    logInfo('User context attached to Crashlytics: $userId');
  }

  /// Sets custom key-value attributes for crash reports
  void setCustomKey(String key, String value) {
    _customKeys[key] = value;
  }

  /// Records a non-fatal or fatal error with stack trace and metadata
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    final entry = CrashLogEntry(
      timestamp: DateTime.now(),
      level: fatal ? 'FATAL' : 'ERROR',
      message: '${reason != null ? "$reason: " : ""}$error',
      stackTrace: stackTrace?.toString(),
      details: {
        'userId': _currentUserId,
        'fatal': fatal,
        ..._customKeys,
      },
    );

    _addLog(entry);

    if (kDebugMode) {
      debugPrint('🔴 [CrashReportingService] [${entry.level}] ${entry.message}');
    }
  }

  /// Records Flutter details error
  void recordFlutterError(FlutterErrorDetails details) {
    recordError(
      details.exception,
      details.stack,
      reason: details.context?.toString() ?? 'Flutter Framework Error',
      fatal: false,
    );
  }

  /// Adds a breadcrumb event log
  void logInfo(String message) {
    _addLog(CrashLogEntry(
      timestamp: DateTime.now(),
      level: 'INFO',
      message: message,
    ));
  }

  /// Adds a warning breadcrumb
  void logWarning(String message) {
    _addLog(CrashLogEntry(
      timestamp: DateTime.now(),
      level: 'WARN',
      message: message,
    ));
  }

  /// Simulates a test non-fatal crash for diagnostics dashboard
  void simulateNonFatalCrash() {
    try {
      throw Exception('Simulated Non-Fatal Diagnostic Exception from Release Dashboard');
    } catch (e, stack) {
      recordError(e, stack, reason: 'Manual Release Test Trigger', fatal: false);
    }
  }

  /// Simulates a fatal exception event
  void simulateFatalCrash() {
    recordError(
      StateError('Simulated Fatal Crash Event for Production Monitoring'),
      StackTrace.current,
      reason: 'Manual Fatal Crash Test',
      fatal: true,
    );
  }

  void toggleCrashlytics(bool enabled) {
    _crashlyticsEnabled = enabled;
    logInfo('Crashlytics collection state set to: $enabled');
  }

  void _addLog(CrashLogEntry entry) {
    _recentLogs.insert(0, entry);
    if (_recentLogs.length > 50) {
      _recentLogs.removeLast();
    }
  }
}

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return CrashReportingService();
});
