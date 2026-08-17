import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/crash_reporting_service.dart';
import 'core/services/performance_tracker_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/views/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final crashService = CrashReportingService();
    crashService.initializeGlobalHandlers();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      crashService.logInfo('Firebase successfully initialized');
    } catch (e, stack) {
      debugPrint('Firebase initialization warning: $e');
      crashService.recordError(e, stack, reason: 'Firebase Init Warning', fatal: false);
    }

    runApp(
      const ProviderScope(
        child: EnterpriseFieldServiceApp(),
      ),
    );
  }, (error, stack) {
    // Intercept uncaught Dart zone errors
    final crashService = CrashReportingService();
    crashService.recordError(error, stack, reason: 'Uncaught Zone Error', fatal: true);
  });
}

class EnterpriseFieldServiceApp extends ConsumerStatefulWidget {
  const EnterpriseFieldServiceApp({super.key});

  @override
  ConsumerState<EnterpriseFieldServiceApp> createState() => _EnterpriseFieldServiceAppState();
}

class _EnterpriseFieldServiceAppState extends ConsumerState<EnterpriseFieldServiceApp> {
  @override
  void initState() {
    super.initState();
    // Initialize performance profiling frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(performanceTrackerProvider).startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Field Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
