import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/live_location_provider.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../auth/presentation/views/splash_screen.dart';
import '../../../bluetooth/presentation/views/bluetooth_settings_screen.dart';
import '../../../deeplink/presentation/views/deeplink_tester_dialog.dart';
import '../../../field_work/presentation/views/field_proof_screen.dart';
import '../../../payment/presentation/views/invoice_details_screen.dart';

class TechnicianJob {
  final String id;
  final String title;
  final String customerName;
  final String address;
  final String time;
  final String priority; // High, Medium, Low
  String status; // Pending, In Progress, Completed
  final IconData categoryIcon;

  TechnicianJob({
    required this.id,
    required this.title,
    required this.customerName,
    required this.address,
    required this.time,
    required this.priority,
    required this.status,
    required this.categoryIcon,
  });
}

class TechnicianDashboardScreen extends ConsumerStatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  ConsumerState<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState
    extends ConsumerState<TechnicianDashboardScreen> {
  int _currentTabIndex = 0;
  bool _isOnDuty = true;
  bool _locationSharing = true;
  bool _notificationsEnabled = true;

  // Local state for user profile edits
  String? _customName;
  String? _customPhone;

  // Local job list for interactivity
  final List<TechnicianJob> _jobs = [
    TechnicianJob(
      id: 'JOB-2041',
      title: 'HVAC Air Handler Repair & Calibration',
      customerName: 'Nexus Tech Plaza (Floor 4)',
      address: '742 Cyber Way, Suite 400',
      time: '10:30 AM - Today',
      priority: 'High',
      status: 'In Progress',
      categoryIcon: Icons.ac_unit_rounded,
    ),
    TechnicianJob(
      id: 'JOB-2045',
      title: 'Fiber Optic Router Installation',
      customerName: 'Aero Dynamics HQ',
      address: '120 Innovation Blvd',
      time: '02:00 PM - Today',
      priority: 'Medium',
      status: 'Pending',
      categoryIcon: Icons.router_rounded,
    ),
    TechnicianJob(
      id: 'JOB-2038',
      title: 'Emergency Generator Inspection',
      customerName: 'Metro Health Hospital',
      address: '88 Wellness Parkway',
      time: '08:00 AM - Today',
      priority: 'High',
      status: 'Completed',
      categoryIcon: Icons.bolt_rounded,
    ),
  ];

  String _jobFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.technicianRole.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handyman,
                color: AppColors.technicianRole,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTabIndex == 0
                      ? 'Technician Dashboard'
                      : _currentTabIndex == 1
                          ? 'Field Navigation Map'
                          : 'Profile & System Settings',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Field Agent Terminal',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.technicianRole,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded, color: AppColors.accent),
            tooltip: 'Deep Link Tester',
            onPressed: () => DeepLinkTesterDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: AppColors.accentEmerald),
            tooltip: 'Invoices & Payments',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InvoiceListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth_audio_rounded, color: AppColors.accent),
            tooltip: 'Bluetooth Module',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BluetoothSettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accentRose),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: userProfile.when(
        data: (appUser) {
          final userName = _customName ?? (appUser?.name ?? 'Alex Rivers');
          final userEmail = appUser?.email ?? 'tech.alex@enterprise.com';
          final userPhone = _customPhone ?? (appUser?.phone ?? '+1 555 0192');

          return IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildJobsTab(userName),
              _buildMapTab(),
              _buildProfileSettingsTab(userName, userEmail, userPhone),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.technicianRole),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading profile: $err',
            style: const TextStyle(color: AppColors.accentRose),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.technicianRole,
          unselectedItemColor: AppColors.textMuted,
          onTap: (idx) {
            setState(() {
              _currentTabIndex = idx;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Jobs & Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Route Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile & Settings',
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: JOBS & TASKS =================
  Widget _buildJobsTab(String userName) {
    final filteredJobs = _jobs.where((job) {
      if (_jobFilter == 'All') return true;
      return job.status == _jobFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // On Duty Toggle Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isOnDuty
                    ? AppColors.accentEmerald.withValues(alpha: 0.5)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnDuty
                            ? AppColors.accentEmerald
                            : AppColors.textMuted,
                        boxShadow: _isOnDuty
                            ? [
                                BoxShadow(
                                  color: AppColors.accentEmerald
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnDuty ? 'ACTIVE ON DUTY' : 'OFF DUTY',
                          style: TextStyle(
                            color: _isOnDuty
                                ? AppColors.accentEmerald
                                : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _isOnDuty
                              ? 'GPS active • Ready for dispatch'
                              : 'Shift offline',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _isOnDuty,
                  activeTrackColor: AppColors.accentEmerald,
                  onChanged: (val) {
                    setState(() {
                      _isOnDuty = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'You are now ON DUTY. Dispatchers notified.'
                              : 'You are now OFF DUTY.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_jobs.where((j) => j.status == "In Progress").length} job in progress • ${_jobs.where((j) => j.status == "Pending").length} pending',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filter & Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assigned Field Jobs',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_task_rounded, color: AppColors.accent),
                tooltip: 'Add Demo Task',
                onPressed: _showAddDemoJobDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'In Progress', 'Pending', 'Completed'].map((filter) {
                final isSelected = _jobFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.technicianRole,
                    backgroundColor: AppColors.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _jobFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Job Cards List
          if (filteredJobs.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No Jobs Match Filter',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];
                return _buildJobCard(job);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildJobCard(TechnicianJob job) {
    Color statusColor;
    if (job.status == 'In Progress') {
      statusColor = AppColors.accentAmber;
    } else if (job.status == 'Completed') {
      statusColor = AppColors.accentEmerald;
    } else {
      statusColor = AppColors.accent;
    }

    Color priorityColor = job.priority == 'High'
        ? AppColors.accentRose
        : AppColors.accentAmber;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: job.status == 'In Progress'
              ? AppColors.accentAmber.withValues(alpha: 0.6)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  job.id,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${job.priority} Priority',
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Description
          Text(
            job.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Details Row
          Row(
            children: [
              const Icon(Icons.business_rounded, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.customerName,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.address,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 6),
              Text(
                job.time,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),

          // Interactive Job Action Buttons
          Row(
            children: [
              if (job.status != 'Completed') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: job.status == 'In Progress'
                          ? AppColors.accentEmerald
                          : AppColors.technicianRole,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        if (job.status == 'Pending') {
                          job.status = 'In Progress';
                        } else {
                          job.status = 'Completed';
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${job.id} marked as ${job.status}!',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      job.status == 'In Progress'
                          ? Icons.check_circle_outline
                          : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(
                      job.status == 'In Progress' ? 'Complete Job' : 'Start Job',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentEmerald),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FieldProofScreen(jobId: job.id),
                    ),
                  );
                },
                icon: const Icon(Icons.draw_rounded,
                    color: AppColors.accentEmerald, size: 16),
                label: const Text(
                  'Proof & Sign',
                  style: TextStyle(color: AppColors.accentEmerald, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onPressed: () {
                  _showJobDetailsModal(job);
                },
                icon: const Icon(Icons.info_outline_rounded,
                    color: AppColors.textSecondary, size: 16),
                label: const Text(
                  'Details',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: ROUTE MAP =================
  Widget _buildMapTab() {
    final liveState = ref.watch(liveLocationControllerProvider);
    final myGps = liveState.locations['TECH-101'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Navigation Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.navigation_rounded, color: AppColors.accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Turn-by-Turn GPS Navigation',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentEmerald.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(color: AppColors.accentEmerald, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        myGps != null
                            ? 'GPS Fix: ${myGps.latitude.toStringAsFixed(4)}°, ${myGps.longitude.toStringAsFixed(4)}° • ${myGps.speedMph.toStringAsFixed(1)} mph'
                            : 'Next Waypoint: 742 Cyber Way (3.2 miles away)',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Map Widget Frame
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Simulated Custom Map Grid Background
                CustomPaint(
                  size: Size.infinite,
                  painter: _MapGridPainter(),
                ),

                // Technician Location Pin
                Positioned(
                  left: 120,
                  top: 180,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.technicianRole,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Your Location',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.navigation_rounded, color: AppColors.technicianRole, size: 32),
                    ],
                  ),
                ),

                // Target Destination Pin
                Positioned(
                  right: 80,
                  top: 90,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentRose,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Site #JOB-2041',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.location_on_rounded, color: AppColors.accentRose, size: 36),
                    ],
                  ),
                ),

                // Map Overlay Controls
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'recenter',
                        backgroundColor: AppColors.surfaceCard,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Map centered to current position.')),
                          );
                        },
                        child: const Icon(Icons.my_location_rounded, color: AppColors.accent),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'traffic',
                        backgroundColor: AppColors.surfaceCard,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Live Traffic Overlay Active.')),
                          );
                        },
                        child: const Icon(Icons.traffic_rounded, color: AppColors.accentAmber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Route Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMapMetric('EST. TIME', '12 mins', Icons.timer_outlined),
                Container(height: 30, width: 1, color: AppColors.border),
                _buildMapMetric('DISTANCE', '3.2 mi', Icons.straighten_rounded),
                Container(height: 30, width: 1, color: AppColors.border),
                _buildMapMetric('TRAFFIC', 'Light', Icons.speed_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  // ================= TAB 3: PROFILE & SETTINGS SCREEN =================
  Widget _buildProfileSettingsTab(String userName, String userEmail, String userPhone) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.technicianRole.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.technicianRole, width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.technicianRole,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                color: AppColors.accentEmerald,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userPhone,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.accent),
                  tooltip: 'Edit Profile Info',
                  onPressed: () => _showEditProfileModal(userName, userPhone),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security Section: Change Password
          const Text(
            'Security & Credentials',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Edit Password',
            subtitle: 'Update your account password',
            iconColor: AppColors.accentAmber,
            onTap: () => _showChangePasswordDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.bluetooth_audio_rounded,
            title: 'Bluetooth Hardware & Peripherals',
            subtitle: 'Connect thermal printers & external GPS units',
            iconColor: AppColors.accent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BluetoothSettingsScreen(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Privacy & System Settings
          const Text(
            'Privacy & System Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // GPS Switch
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.accent),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Background Location Sharing',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Share real-time GPS with dispatchers',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _locationSharing,
                  activeTrackColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      _locationSharing = val;
                    });
                  },
                ),
              ],
            ),
          ),

          // Notifications Switch
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: AppColors.technicianRole),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispatch Push Alerts',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Instant alerts when new job is assigned',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _notificationsEnabled,
                  activeTrackColor: AppColors.technicianRole,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),

          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy & Terms',
            subtitle: 'Read enterprise privacy compliance guidelines',
            iconColor: AppColors.accentEmerald,
            onTap: _showPrivacyPolicyModal,
          ),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRose.withValues(alpha: 0.15),
                foregroundColor: AppColors.accentRose,
                side: const BorderSide(color: AppColors.accentRose, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Logout of Technician Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      ),
    );
  }

  // ================= MODALS & DIALOGS =================

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppColors.accentAmber),
              SizedBox(width: 10),
              Text(
                'Edit Password',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter current password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Minimum 6 characters required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                    ),
                    validator: (val) {
                      if (val != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                      backgroundColor: AppColors.accentEmerald,
                    ),
                  );
                }
              },
              child: const Text('Update Password'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileModal(String currentName, String currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile Details',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _customName = nameCtrl.text.trim();
                      _customPhone = phoneCtrl.text.trim();
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully.')),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.security_rounded, color: AppColors.accentEmerald),
                  SizedBox(width: 10),
                  Text(
                    'Privacy & Data Policy',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '1. Location Data: GPS signals are gathered strictly during active duty hours to optimize technician route dispatching.\n'
                '2. Encryption: All communications with the enterprise field dispatch server are encrypted via AES-256 standards.\n'
                '3. Access Control: Only authorized dispatch administrators can view your current assigned job logs and location.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showJobDetailsModal(TechnicianJob job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.id,
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Priority: ${job.priority}',
                    style: const TextStyle(color: AppColors.accentAmber, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                job.title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Customer: ${job.customerName}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Address: ${job.address}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Scheduled Time: ${job.time}', style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _currentTabIndex = 1; // Switch to route map tab
                        });
                      },
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Start Navigation'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddDemoJobDialog() {
    final titleCtrl = TextEditingController(text: 'Water Leak Sensor Maintenance');
    final customerCtrl = TextEditingController(text: 'Horizon Financial Tower');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          title: const Text('Add Demo Field Job', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: customerCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Customer Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _jobs.insert(
                    0,
                    TechnicianJob(
                      id: 'JOB-${2046 + _jobs.length}',
                      title: titleCtrl.text,
                      customerName: customerCtrl.text,
                      address: '450 Tech Plaza',
                      time: 'Just Now',
                      priority: 'Medium',
                      status: 'Pending',
                      categoryIcon: Icons.build_rounded,
                    ),
                  );
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Add Job'),
            ),
          ],
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Are you sure you want to log out of your technician account?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// Custom Painter for Map background grid visualization
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const gridSpacing = 40.0;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Simulated Route Line
    final routePaint = Paint()
      ..color = AppColors.technicianRole
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(120, 180)
      ..lineTo(180, 180)
      ..lineTo(180, 100)
      ..lineTo(size.width - 80, 90);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
