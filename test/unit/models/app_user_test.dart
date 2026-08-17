import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_field_service/features/auth/domain/app_user.dart';

void main() {
  group('AppUser Model Unit Tests', () {
    test('AppUser converts to and from map serialization correctly', () {
      final now = DateTime.now();
      final user = AppUser(
        id: 'usr_001',
        name: 'Sarah Connor',
        email: 'sarah@enterprise.com',
        role: UserRole.admin,
        phone: '+15550199',
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['id'], equals('usr_001'));
      expect(map['role'], equals('admin'));

      final restored = AppUser.fromMap(map, 'usr_001');
      expect(restored.name, equals('Sarah Connor'));
      expect(restored.isAdmin, isTrue);
      expect(restored.isTechnician, isFalse);
    });

    test('UserRole string parser returns correct role enum', () {
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('ADMIN'), equals(UserRole.admin));
      expect(UserRole.fromString('technician'), equals(UserRole.technician));
      expect(UserRole.fromString('unknown'), equals(UserRole.technician));
    });
  });
}
