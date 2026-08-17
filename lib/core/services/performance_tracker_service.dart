import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trace session metrics
class TraceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, dynamic> attributes;

  TraceMetric({
    required this.name,
    required this.startTime,
    Map<String, dynamic>? attributes,
  }) : attributes = attributes ?? {};

  Duration? get duration => endTime?.difference(startTime);
}

/// Real-time Performance & Profiling Tracker Service.
/// Measures frame rates (FPS), frame render latency, drops, and custom traces.
class PerformanceTrackerService {
  final Map<String, TraceMetric> _activeTraces = {};
  final List<TraceMetric> _completedTraces = [];
  
  double _currentFps = 60.0;
  int _droppedFrames = 0;
  int _totalFramesMeasured = 0;
  bool _isMonitoring = false;

  double get currentFps => _currentFps;
  int get droppedFrames => _droppedFrames;
  int get totalFrames => _totalFramesMeasured;
  List<TraceMetric> get completedTraces => List.unmodifiable(_completedTraces);
  bool get isMonitoring => _isMonitoring;

  /// Starts monitoring Flutter frame render callbacks
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    if (kDebugMode) {
      debugPrint('⚡ [PerformanceTracker] Frame profiling started');
    }
  }

  /// Stops monitoring frame timings
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    if (kDebugMode) {
      debugPrint('⚡ [PerformanceTracker] Frame profiling stopped');
    }
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      _totalFramesMeasured++;
      final totalMs = timing.totalSpan.inMicroseconds / 1000.0;
      
      // Target for 60fps is 16.6ms per frame
      if (totalMs > 16.6) {
        _droppedFrames++;
      }

      // Smooth FPS calculation
      final calculatedFps = (1000.0 / (totalMs > 0 ? totalMs : 16.6)).clamp(0.0, 60.0);
      _currentFps = (_currentFps * 0.9) + (calculatedFps * 0.1);
    }
  }

  /// Start a custom performance trace session
  void startTrace(String name, {Map<String, dynamic>? attributes}) {
    _activeTraces[name] = TraceMetric(
      name: name,
      startTime: DateTime.now(),
      attributes: attributes,
    );
  }

  /// Stop a trace session and log execution duration
  TraceMetric? stopTrace(String name) {
    final trace = _activeTraces.remove(name);
    if (trace == null) return null;

    trace.endTime = DateTime.now();
    _completedTraces.insert(0, trace);
    if (_completedTraces.length > 50) {
      _completedTraces.removeLast();
    }

    if (kDebugMode) {
      debugPrint(
        '⚡ [PerformanceTracker] Trace "$name" finished in ${trace.duration?.inMilliseconds} ms',
      );
    }
    return trace;
  }

  /// Estimated memory usage (mock/platform platform metric)
  double getEstimatedMemoryUsageMb() {
    // Basic runtime memory heuristic indicator
    return 48.5 + (_completedTraces.length * 0.2);
  }

  void resetMetrics() {
    _droppedFrames = 0;
    _totalFramesMeasured = 0;
    _currentFps = 60.0;
    _completedTraces.clear();
  }
}

final performanceTrackerProvider = Provider<PerformanceTrackerService>((ref) {
  final service = PerformanceTrackerService();
  service.startMonitoring();
  return service;
});
