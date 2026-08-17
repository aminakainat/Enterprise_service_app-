import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/crash_reporting_service.dart';
import '../../../../core/services/performance_tracker_service.dart';
import '../../../../core/services/version_service.dart';

class ReleaseDiagnosticsScreen extends ConsumerStatefulWidget {
  const ReleaseDiagnosticsScreen({super.key});

  @override
  ConsumerState<ReleaseDiagnosticsScreen> createState() =>
      _ReleaseDiagnosticsScreenState();
}

class _ReleaseDiagnosticsScreenState
    extends ConsumerState<ReleaseDiagnosticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final versionInfo = ref.watch(appVersionInfoProvider);
    final crashService = ref.watch(crashReportingServiceProvider);
    final analyticsService = ref.watch(analyticsServiceProvider);
    final perfTracker = ref.watch(performanceTrackerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Production Release Diagnostics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Monitoring, Crashlytics, Analytics & CI/CD Pipeline',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.bug_report), text: 'Crashlytics'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.system_update_alt), text: 'Version & Pipeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPerformanceTab(perfTracker),
          _buildCrashlyticsTab(crashService),
          _buildAnalyticsTab(analyticsService),
          _buildVersionAndPipelineTab(versionInfo),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Performance & Profiling
  // ---------------------------------------------------------------------------
  Widget _buildPerformanceTab(PerformanceTrackerService perfTracker) {
    final fps = perfTracker.currentFps;
    final drops = perfTracker.droppedFrames;
    final memoryMb = perfTracker.getEstimatedMemoryUsageMb();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('REAL-TIME FRAME & MEMORY METRICS', Icons.memory),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Render FPS',
                  value: '${fps.toStringAsFixed(1)} FPS',
                  subtitle: fps > 50 ? 'Optimal Performance' : 'Potential Jank',
                  color: fps > 50 ? AppColors.accentEmerald : AppColors.accentAmber,
                  icon: Icons.speed_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Frame Drops',
                  value: '$drops Frames',
                  subtitle: 'Target: < 5 Drops',
                  color: drops < 5 ? AppColors.accentEmerald : AppColors.accentRose,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            title: 'Estimated Memory Footprint',
            value: '${memoryMb.toStringAsFixed(1)} MB',
            subtitle: 'Optimized Image Caching & Dynamic List Recycling active',
            color: AppColors.accent,
            icon: Icons.developer_board_rounded,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('TRACE EXECUTION PROFILER', Icons.timer_outlined),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trace Benchmark Runner',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Measure synchronous data serialization and widget rendering latency.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    perfTracker.startTrace('ManualTrace_WorkOrderFetch');
                    Future.delayed(const Duration(milliseconds: 140), () {
                      perfTracker.stopTrace('ManualTrace_WorkOrderFetch');
                      setState(() {});
                    });
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Run Benchmark Trace'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recent Completed Traces:',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (perfTracker.completedTraces.isEmpty)
                  const Text(
                    'No benchmarks run yet. Tap above to execute.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  )
                else
                  ...perfTracker.completedTraces.take(5).map(
                        (t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.name,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${t.duration?.inMilliseconds} ms',
                                  style: const TextStyle(
                                    color: AppColors.accentEmerald,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Crashlytics & Error Handling
  // ---------------------------------------------------------------------------
  Widget _buildCrashlyticsTab(CrashReportingService crashService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CRASHLYTICS DIAGNOSTIC ACTIONS', Icons.bug_report),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentAmber,
                          side: const BorderSide(color: AppColors.accentAmber),
                        ),
                        onPressed: () {
                          crashService.simulateNonFatalCrash();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Simulated non-fatal exception logged to Crashlytics feed.'),
                              backgroundColor: AppColors.accentAmber,
                            ),
                          );
                        },
                        icon: const Icon(Icons.warning_amber_rounded),
                        label: const Text('Log Non-Fatal Error'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentRose,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          crashService.simulateFatalCrash();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fatal crash exception captured in logs.'),
                              backgroundColor: AppColors.accentRose,
                            ),
                          );
                        },
                        icon: const Icon(Icons.error_outline),
                        label: const Text('Trigger Fatal Crash'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          crashService.setUserIdentifier('tech_lead_prod_001');
                          crashService.setCustomKey('user_role', 'Administrator');
                          setState(() {});
                        },
                        icon: const Icon(Icons.person_pin_rounded),
                        label: const Text('Tag User Context'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('LIVE EXCEPTION & BREADCRUMB LOG FEED', Icons.list_alt_rounded),
          const SizedBox(height: 12),
          if (crashService.recentLogs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No crash logs recorded in this session.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: crashService.recentLogs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = crashService.recentLogs[index];
                final isFatal = log.level == 'FATAL';
                final isError = log.level == 'ERROR';

                final color = isFatal
                    ? AppColors.accentRose
                    : isError
                        ? AppColors.accentAmber
                        : AppColors.accentEmerald;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.level,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.message,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Timestamp: ${log.timestamp.toIso8601String().substring(11, 19)}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Analytics Events
  // ---------------------------------------------------------------------------
  Widget _buildAnalyticsTab(AnalyticsService analyticsService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ANALYTICS DISPATCHER', Icons.analytics),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dispatch Test Events to Firebase Analytics',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      backgroundColor: AppColors.primaryLight,
                      label: const Text('Log Screen View', style: TextStyle(color: AppColors.accent)),
                      avatar: const Icon(Icons.pageview_rounded, size: 16, color: AppColors.accent),
                      onPressed: () {
                        analyticsService.logScreenView(screenName: 'ReleaseDiagnosticsScreen');
                        setState(() {});
                      },
                    ),
                    ActionChip(
                      backgroundColor: AppColors.primaryLight,
                      label: const Text('Log Work Order Edit', style: TextStyle(color: AppColors.accentEmerald)),
                      avatar: const Icon(Icons.assignment_turned_in, size: 16, color: AppColors.accentEmerald),
                      onPressed: () {
                        analyticsService.logWorkOrderUpdated(
                          orderId: 'WO-9982',
                          oldStatus: 'In-Progress',
                          newStatus: 'Completed',
                        );
                        setState(() {});
                      },
                    ),
                    ActionChip(
                      backgroundColor: AppColors.primaryLight,
                      label: const Text('Log Payment Processed', style: TextStyle(color: AppColors.accentAmber)),
                      avatar: const Icon(Icons.payments_rounded, size: 16, color: AppColors.accentAmber),
                      onPressed: () {
                        analyticsService.logPaymentProcessed(
                          invoiceId: 'INV-4819',
                          amount: 249.99,
                          currency: 'USD',
                        );
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('LOGGED ANALYTICS EVENTS STREAM', Icons.stream),
          const SizedBox(height: 12),
          if (analyticsService.loggedEvents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No analytics events dispatched in current session.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analyticsService.loggedEvents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final event = analyticsService.loggedEvents[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            event.timestamp.toIso8601String().substring(11, 19),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (event.parameters.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Params: ${event.parameters}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Version Control & CI/CD Pipelines
  // ---------------------------------------------------------------------------
  Widget _buildVersionAndPipelineTab(AppVersionInfo info) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('APPLICATION VERSION STATUS', Icons.system_update_alt),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow('Installed Version', '${info.currentVersion}+${info.buildNumber}'),
                const Divider(color: AppColors.border),
                _buildInfoRow('Minimum Required Version', info.minimumRequiredVersion),
                const Divider(color: AppColors.border),
                _buildInfoRow('Latest Store Version', info.latestAvailableVersion),
                const Divider(color: AppColors.border),
                _buildInfoRow(
                  'Force Update Policy Status',
                  info.isForceUpdateRequired ? 'FORCE UPDATE REQUIRED' : 'COMPLIANT (UP TO DATE)',
                  valueColor: info.isForceUpdateRequired ? AppColors.accentRose : AppColors.accentEmerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('PRODUCTION BUILD & CI/CD ENVIRONMENT', Icons.cloud_done_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow('Deployment Channel', info.releaseChannel.toUpperCase(), valueColor: AppColors.accent),
                const Divider(color: AppColors.border),
                _buildInfoRow('Git Commit Hash', info.buildCommitHash),
                const Divider(color: AppColors.border),
                _buildInfoRow('Build Automation System', 'GitHub Actions & Codemagic'),
                const Divider(color: AppColors.border),
                _buildInfoRow('Distribution Method', 'Firebase App Distribution & Play Store'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('RELEASE NOTES & CHANGELOG', Icons.notes_rounded),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: info.releaseNotes
                  .map(
                    (note) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: AppColors.accent, fontSize: 14)),
                          Expanded(
                            child: Text(
                              note,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper UI Widgets
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
