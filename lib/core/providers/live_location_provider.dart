import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechnicianGpsLocation {
  final String technicianId;
  final String technicianName;
  final double latitude;
  final double longitude;
  final double speedMph;
  final double headingDegrees;
  final double accuracyMeters;
  final bool isExternalGps;
  final int satelliteCount;
  final DateTime lastUpdated;

  TechnicianGpsLocation({
    required this.technicianId,
    required this.technicianName,
    required this.latitude,
    required this.longitude,
    required this.speedMph,
    required this.headingDegrees,
    required this.accuracyMeters,
    this.isExternalGps = false,
    this.satelliteCount = 12,
    required this.lastUpdated,
  });

  TechnicianGpsLocation copyWith({
    double? latitude,
    double? longitude,
    double? speedMph,
    double? headingDegrees,
    double? accuracyMeters,
    bool? isExternalGps,
    int? satelliteCount,
    DateTime? lastUpdated,
  }) {
    return TechnicianGpsLocation(
      technicianId: technicianId,
      technicianName: technicianName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedMph: speedMph ?? this.speedMph,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      isExternalGps: isExternalGps ?? this.isExternalGps,
      satelliteCount: satelliteCount ?? this.satelliteCount,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class LiveLocationState {
  final Map<String, TechnicianGpsLocation> locations;
  final bool isLiveTrackingActive;

  LiveLocationState({
    required this.locations,
    this.isLiveTrackingActive = true,
  });

  LiveLocationState copyWith({
    Map<String, TechnicianGpsLocation>? locations,
    bool? isLiveTrackingActive,
  }) {
    return LiveLocationState(
      locations: locations ?? this.locations,
      isLiveTrackingActive: isLiveTrackingActive ?? this.isLiveTrackingActive,
    );
  }
}

class LiveLocationController extends StateNotifier<LiveLocationState> {
  Timer? _timer;

  LiveLocationController()
      : super(
          LiveLocationState(
            locations: {
              'TECH-101': TechnicianGpsLocation(
                technicianId: 'TECH-101',
                technicianName: 'Alex Rivers',
                latitude: 37.7749,
                longitude: -122.4194,
                speedMph: 28.5,
                headingDegrees: 45.0,
                accuracyMeters: 1.2,
                lastUpdated: DateTime.now(),
              ),
              'TECH-102': TechnicianGpsLocation(
                technicianId: 'TECH-102',
                technicianName: 'Sam Wilson',
                latitude: 37.7833,
                longitude: -122.4167,
                speedMph: 0.0,
                headingDegrees: 0.0,
                accuracyMeters: 0.4,
                isExternalGps: true, // Connected via Garmin GLO 2
                satelliteCount: 16,
                lastUpdated: DateTime.now(),
              ),
              'TECH-103': TechnicianGpsLocation(
                technicianId: 'TECH-103',
                technicianName: 'Jordan Lee',
                latitude: 37.7690,
                longitude: -122.4480,
                speedMph: 14.2,
                headingDegrees: 180.0,
                accuracyMeters: 2.1,
                lastUpdated: DateTime.now(),
              ),
            },
          ),
        ) {
    _startLiveSimulation();
  }

  void _startLiveSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!state.isLiveTrackingActive) return;

      final updated = Map<String, TechnicianGpsLocation>.from(state.locations);

      // Simulate micro GPS coordinate updates for live tracking movement
      if (updated.containsKey('TECH-101')) {
        final loc = updated['TECH-101']!;
        updated['TECH-101'] = loc.copyWith(
          latitude: loc.latitude + 0.00015,
          longitude: loc.longitude + 0.00012,
          speedMph: 25.0 + (timer.tick % 5),
          lastUpdated: DateTime.now(),
        );
      }

      if (updated.containsKey('TECH-103')) {
        final loc = updated['TECH-103']!;
        updated['TECH-103'] = loc.copyWith(
          latitude: loc.latitude - 0.00010,
          longitude: loc.longitude + 0.00008,
          speedMph: 15.0 + (timer.tick % 4),
          lastUpdated: DateTime.now(),
        );
      }

      state = state.copyWith(locations: updated);
    });
  }

  void toggleLiveTracking(bool active) {
    state = state.copyWith(isLiveTrackingActive: active);
  }

  void updateExternalGpsConnected(String techId, bool isExternal, int satCount) {
    if (!state.locations.containsKey(techId)) return;
    final updated = Map<String, TechnicianGpsLocation>.from(state.locations);
    final loc = updated[techId]!;
    updated[techId] = loc.copyWith(
      isExternalGps: isExternal,
      satelliteCount: satCount,
      accuracyMeters: isExternal ? 0.4 : 2.5,
    );
    state = state.copyWith(locations: updated);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final liveLocationControllerProvider =
    StateNotifierProvider<LiveLocationController, LiveLocationState>((ref) {
  return LiveLocationController();
});
