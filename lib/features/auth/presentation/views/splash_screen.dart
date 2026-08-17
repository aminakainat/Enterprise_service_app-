import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../admin/presentation/views/admin_dashboard_screen.dart';
import '../../../technician/presentation/views/technician_dashboard_screen.dart';
import '../../domain/app_user.dart';
import '../controllers/auth_providers.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final userProfile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: authState.when(
            data: (user) {
              if (user == null) {
              
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                });
                return _buildSplashContent('Redirecting to login...');
              }

             
              return userProfile.when(
                data: (appUser) {
                  final targetUser = appUser ??
                      AppUser(
                        id: user.uid,
                        name: user.displayName ??
                            (user.email != null && user.email!.contains('@')
                                ? user.email!.split('@').first
                                : 'User'),
                        email: user.email ?? '',
                        role: UserRole.technician,
                        createdAt: DateTime.now(),
                      );

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (targetUser.isAdmin) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const TechnicianDashboardScreen(),
                        ),
                      );
                    }
                  });

                  return _buildSplashContent('Welcome, ${targetUser.name}...');
                },
                loading: () => _buildSplashContent('Loading user permissions...'),
                error: (err, _) => _buildErrorContent(
                  context,
                  ref,
                  'Profile Error: ${err.toString()}',
                ),
              );
            },
            loading: () => _buildSplashContent('Initializing session...'),
            error: (err, _) => _buildErrorContent(
              context,
              ref,
              'Auth Error: ${err.toString()}',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashContent(String subtext) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: const Icon(
            Icons.build_circle_rounded,
            size: 52,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'FIELD SERVICE PRO',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enterprise Workforce Operations',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 48),
        const SpinKitThreeBounce(
          color: AppColors.accent,
          size: 28.0,
        ),
        const SizedBox(height: 16),
        Text(
          subtext,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref, String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.accentRose),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(authControllerProvider.notifier).signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Return to Login'),
        ),
      ],
    );
  }
}
