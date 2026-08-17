import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_field_service/core/services/version_service.dart';

void main() {
  group('VersionService Unit Tests', () {
    late VersionService versionService;

    setUp(() {
      versionService = VersionService();
    });

    test('getVersionInfo returns correct app version metadata', () {
      final info = versionService.getVersionInfo();

      expect(info.currentVersion, equals('1.0.0'));
      expect(info.buildNumber, equals(1));
      expect(info.minimumRequiredVersion, equals('1.0.0'));
      expect(info.latestAvailableVersion, equals('1.0.1'));
      expect(info.releaseChannel, equals('production'));
      expect(info.releaseNotes, isNotEmpty);
    });

    test('isValidSemVer accurately validates semver string formats', () {
      expect(versionService.isValidSemVer('1.0.0'), isTrue);
      expect(versionService.isValidSemVer('2.14.3+42'), isTrue);
      expect(versionService.isValidSemVer('1.0'), isFalse);
      expect(versionService.isValidSemVer('v1.0.0'), isFalse);
      expect(versionService.isValidSemVer('invalid'), isFalse);
    });

    test('compareVersions accurately compares semantic version strings', () {
      // Version 1.0.0 vs 1.0.1
      expect(versionService.compareVersions('1.0.0', '1.0.1'), lessThan(0));

      // Version 2.1.0 vs 1.9.9
      expect(versionService.compareVersions('2.1.0', '1.9.9'), greaterThan(0));

      // Version 1.0.0 vs 1.0.0
      expect(versionService.compareVersions('1.0.0', '1.0.0'), equals(0));
    });

    test('AppVersionInfo evaluates force update requirement accurately', () {
      final updatedInfo = AppVersionInfo(
        currentVersion: '1.0.0',
        buildNumber: 1,
        minimumRequiredVersion: '1.1.0',
        latestAvailableVersion: '1.2.0',
        releaseChannel: 'production',
        buildCommitHash: 'abcdef',
        releaseNotes: [],
      );

      expect(updatedInfo.isForceUpdateRequired, isTrue);
      expect(updatedInfo.isUpdateAvailable, isTrue);
    });
  });
}
