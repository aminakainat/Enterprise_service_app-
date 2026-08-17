import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enterprise_field_service/main.dart';
import 'package:enterprise_field_service/features/auth/presentation/controllers/auth_providers.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const EnterpriseFieldServiceApp(),
      ),
    );

    // Verify splash screen branding renders correctly
    expect(find.text('FIELD SERVICE PRO'), findsOneWidget);
    expect(find.text('Enterprise Workforce Operations'), findsOneWidget);
  });
}
