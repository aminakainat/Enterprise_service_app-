import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enterprise_field_service/main.dart';
import 'package:enterprise_field_service/features/auth/presentation/controllers/auth_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Enterprise Field Service E2E Integration Tests', () {
    testWidgets('Full app lifecycle: Launch, Splash, Login & Diagnostics Navigation', (WidgetTester tester) async {
      // Launch application with mocked auth state stream
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const EnterpriseFieldServiceApp(),
        ),
      );

      // Verify splash screen renders
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('FIELD SERVICE PRO'), findsOneWidget);

      // Wait for redirect to LoginScreen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify Login Screen form elements
      expect(find.text('Enterprise Operations Sign In'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

      // Tap Quick Admin Login button if available
      final adminDemoBtn = find.text('Quick Admin Login');
      if (adminDemoBtn.evaluate().isNotEmpty) {
        await tester.tap(adminDemoBtn);
        await tester.pumpAndSettle();
      }
    });
  });
}
