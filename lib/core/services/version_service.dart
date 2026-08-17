import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App Version Metadata model
class AppVersionInfo {
  final String currentVersion;
  final int buildNumber;
  final String minimumRequiredVersion;
  final String latestAvailableVersion;
  final String releaseChannel; // 'production', 'beta', 'alpha'
  final String buildCommitHash;
  final List<String> releaseNotes;

  AppVersionInfo({
    required this.currentVersion,
    required this.buildNumber,
    required this.minimumRequiredVersion,
    required this.latestAvailableVersion,
    required this.releaseChannel,
    required this.buildCommitHash,
    required this.releaseNotes,
  });

  bool get isForceUpdateRequired {
    return _compareVersions(currentVersion, minimumRequiredVersion) < 0;
  }

  bool get isUpdateAvailable {
    return _compareVersions(currentVersion, latestAvailableVersion) < 0;
  }

  static int _compareVersions(String v1, String v2) {
    List<int> parse(String v) => v.split('+').first.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final p1 = parse(v1);
    final p2 = parse(v2);

    final maxLength = p1.length > p2.length ? p1.length : p2.length;
    for (int i = 0; i < maxLength; i++) {
      final item1 = i < p1.length ? p1[i] : 0;
      final item2 = i < p2.length ? p2[i] : 0;
      if (item1 != item2) return item1.compareTo(item2);
    }
    return 0;
  }
}

/// Enterprise Version Service
class VersionService {
  AppVersionInfo getVersionInfo() {
    return AppVersionInfo(
      currentVersion: '1.0.0',
      buildNumber: 1,
      minimumRequiredVersion: '1.0.0',
      latestAvailableVersion: '1.0.1',
      releaseChannel: 'production',
      buildCommitHash: 'e7f82b1c',
      releaseNotes: [
        'Automated CI/CD release pipeline integration',
        'Firebase Crashlytics & Analytics monitoring enabled',
        'Real-time frame latency performance profiling added',
        'Security enhancement & memory optimization improvements',
      ],
    );
  }

  /// Verifies if version String matches semantic versioning regex format (e.g. 1.0.0 or 1.0.0+1)
  bool isValidSemVer(String versionStr) {
    final regex = RegExp(r'^\d+\.\d+\.\d+(\+\d+)?$');
    return regex.hasMatch(versionStr);
  }

  /// Utility to compare two semver version strings
  int compareVersions(String v1, String v2) {
    return AppVersionInfo._compareVersions(v1, v2);
  }
}

final versionServiceProvider = Provider<VersionService>((ref) {
  return VersionService();
});

final appVersionInfoProvider = Provider<AppVersionInfo>((ref) {
  return ref.watch(versionServiceProvider).getVersionInfo();
});
