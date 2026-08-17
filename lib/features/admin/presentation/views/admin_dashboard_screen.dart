import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/live_location_provider.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../auth/presentation/views/splash_screen.dart';
import '../../../bluetooth/presentation/views/bluetooth_settings_screen.dart';
import '../../../deeplink/presentation/views/deeplink_tester_dialog.dart';
import '../../../payment/presentation/views/invoice_details_screen.dart';
import 'release_diagnostics_screen.dart';

class TechFleetMember {
  final String id;
  final String name;
  final String status; 
  final String location;
  final int batteryLevel;
  final String phone;
  final Color color;
  final Offset mapPosition;

  TechFleetMember({
    required this.id,
    required this.name,
    required this.status,
    required this.location,
    required this.batteryLevel,
    required this.phone,
    required this.color,
    required this.mapPosition,
  });
}

class LiveActivityEvent {
  final String time;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;

  LiveActivityEvent({
    required this.time,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
  });
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _mapFilter = 'All Techs';
  TechFleetMember? _selectedMapTech;
  final List<TechFleetMember> _fleetMembers = [
    TechFleetMember(
      id: 'TECH-101',
      name: 'Alex Rivers',
      status: 'En Route',
      location: '742 Cyber Way',
      batteryLevel: 88,
      phone: '+1 555 0192',
      color: AppColors.technicianRole,
      mapPosition: const Offset(110, 140),
    ),
    TechFleetMember(
      id: 'TECH-102',
      name: 'Sam Wilson',
      status: 'On Site',
      location: '88 Wellness Parkway',
      batteryLevel: 94,
      phone: '+1 555 0833',
      color: AppColors.accentEmerald,
      mapPosition: const Offset(240, 90),
    ),
    TechFleetMember(
      id: 'TECH-103',
      name: 'Jordan Lee',
      status: 'Available',
      location: 'Central Depot Hub',
      batteryLevel: 72,
      phone: '+1 555 0411',
      color: AppColors.adminRole,
      mapPosition: const Offset(180, 220),
    ),
    TechFleetMember(
      id: 'TECH-104',
      name: 'Taylor Reed',
      status: 'En Route',
      location: '120 Innovation Blvd',
      batteryLevel: 65,
      phone: '+1 555 0922',
      color: AppColors.accentAmber,
      mapPosition: const Offset(300, 180),
    ),
  ];
  final List<LiveActivityEvent> _liveEvents = [
    LiveActivityEvent(
      time: 'Just now',
      title: 'Job Completed',
      detail: 'Tech Sam Wilson finished Emergency Generator Inspection',
      icon: Icons.check_circle_rounded,
      color: AppColors.accentEmerald,
    ),
    LiveActivityEvent(
      time: '4 mins ago',
      title: 'En Route Signal',
      detail: 'Tech Alex Rivers initiated navigation to Cyber Way',
      icon: Icons.navigation_rounded,
      color: AppColors.accent,
    ),
    LiveActivityEvent(
      time: '12 mins ago',
      title: 'New Dispatch Created',
      detail: 'Job #2045 assigned to Taylor Reed',
      icon: Icons.add_task_rounded,
      color: AppColors.adminRole,
    ),
  ];

  int _pendingJobsCount = 14;
  final int _completedTodayCount = 32;
  final int _totalRevenue = 4850;

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(currentUserProfileProvider);
    final liveLocationState = ref.watch(liveLocationControllerProvider);

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
                color: AppColors.adminRole.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppColors.adminRole,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispatcher Control Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Admin & Fleet Overview',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.adminRole,
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
            icon: const Icon(Icons.analytics_outlined, color: AppColors.accentAmber),
            tooltip: 'Release & Crash Diagnostics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReleaseDiagnosticsScreen(),
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
          final userName = appUser?.name ?? 'Dispatcher Admin';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.adminGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.adminRole.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, $userName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_fleetMembers.length} technicians online • Real-time GPS Fleet Feed Active',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.adminRole,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onPressed: () => _showCreateJobModal(context),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          'New Dispatch',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'System Overview',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tap card to view details',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                  children: [
                    _buildStatCard(
                      title: 'Active Techs',
                      value: '${_fleetMembers.length} / 12',
                      icon: Icons.person_pin_circle_rounded,
                      color: AppColors.accentEmerald,
                      onTap: () => _showActiveTechsModal(context),
                    ),
                    _buildStatCard(
                      title: 'Pending Jobs',
                      value: '$_pendingJobsCount',
                      icon: Icons.assignment_late_rounded,
                      color: AppColors.accentAmber,
                      onTap: () => _showPendingJobsModal(context),
                    ),
                    _buildStatCard(
                      title: 'Completed Today',
                      value: '$_completedTodayCount',
                      icon: Icons.verified_rounded,
                      color: AppColors.accent,
                      onTap: () => _showCompletedJobsModal(context),
                    ),
                    _buildStatCard(
                      title: 'Total Revenue',
                      value: '\$$__totalRevenueFormatted',
                      icon: Icons.payments_rounded,
                      color: AppColors.adminRole,
                      onTap: () => _showRevenueModal(context),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.map_rounded, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text(
                          'Live Fleet & GPS Dispatch Map',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentEmerald.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sensors_rounded, color: AppColors.accentEmerald, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: AppColors.accentEmerald,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All Techs', 'En Route', 'On Site', 'Available'].map((filter) {
                      final isSelected = _mapFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.adminRole,
                          backgroundColor: AppColors.surfaceCard,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _mapFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

          
                _buildLiveMapCanvas(),

                const SizedBox(height: 24),

                if (_selectedMapTech != null) _buildSelectedTechCard(liveLocationState),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.dynamic_feed_rounded, color: AppColors.accentAmber, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Real-Time Dispatch Activity Feed',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              setState(() {
                                _liveEvents.insert(
                                  0,
                                  LiveActivityEvent(
                                    time: 'Just now',
                                    title: 'Telemetry Sync',
                                    detail: 'All technician GPS vectors refreshed',
                                    icon: Icons.sync_rounded,
                                    color: AppColors.accent,
                                  ),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _liveEvents.length,
                        separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 16),
                        itemBuilder: (context, index) {
                          final evt = _liveEvents[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: evt.color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(evt.icon, color: evt.color, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evt.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      evt.detail,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                evt.time,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.adminRole),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading profile: $err',
            style: const TextStyle(color: AppColors.accentRose),
          ),
        ),
      ),
    );
  }

  String get __totalRevenueFormatted {
    return _totalRevenue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= LIVE MAP CANVAS WIDGET =================
  Widget _buildLiveMapCanvas() {
    final filteredTechs = _fleetMembers.where((tech) {
      if (_mapFilter == 'All Techs') return true;
      return tech.status == _mapFilter;
    }).toList();

    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminRole.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminRole.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background GIS Dark Grid Lines
          CustomPaint(
            size: Size.infinite,
            painter: _AdminFleetMapPainter(),
          ),

          // Interactive Technician Pins
          ...filteredTechs.map((tech) {
            final isSelected = _selectedMapTech?.id == tech.id;
            return Positioned(
              left: tech.mapPosition.dx,
              top: tech.mapPosition.dy,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMapTech = tech;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tech.color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: tech.color.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        tech.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : tech.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: isSelected ? 3 : 1.5),
                      ),
                      child: Icon(
                        Icons.handyman_rounded,
                        color: isSelected ? tech.color : Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Hint overlay at bottom left
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                '📍 Click any pin to inspect fleet status',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTechCard(LiveLocationState liveState) {
    final tech = _selectedMapTech!;
    final liveGps = liveState.locations[tech.id];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tech.color, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: tech.color.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: tech.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tech.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentEmerald.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE GPS STREAM',
                            style: TextStyle(color: AppColors.accentEmerald, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Location: ${tech.location} • Status: ${tech.status}',
                      style: TextStyle(color: tech.color, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Battery: ${tech.batteryLevel}% • Phone: ${tech.phone}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: tech.color),
                onPressed: () {
                  _showDispatchTaskDialog(tech);
                },
                child: const Text('Dispatch Job'),
              ),
            ],
          ),
          if (liveGps != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLiveTelemetryItem(
                  'COORDINATES',
                  '${liveGps.latitude.toStringAsFixed(4)}°, ${liveGps.longitude.toStringAsFixed(4)}°',
                  Icons.my_location_rounded,
                ),
                _buildLiveTelemetryItem(
                  'SPEED',
                  '${liveGps.speedMph.toStringAsFixed(1)} mph',
                  Icons.speed_rounded,
                ),
                _buildLiveTelemetryItem(
                  'GPS ACCURACY',
                  liveGps.isExternalGps ? '±0.4m (Ext. GPS)' : '±${liveGps.accuracyMeters.toStringAsFixed(1)}m',
                  Icons.satellite_alt_rounded,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLiveTelemetryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 14),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ================= MODALS & OVERVIEWS =================

  void _showActiveTechsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Technicians', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _fleetMembers.length,
                itemBuilder: (ctx, i) {
                  final t = _fleetMembers[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: t.color.withValues(alpha: 0.2), child: Icon(Icons.handyman, color: t.color)),
                    title: Text(t.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('${t.status} @ ${t.location}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    trailing: Text('${t.batteryLevel}% 🔋', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPendingJobsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending Queue ($_pendingJobsCount Jobs)', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: AppColors.accentRose),
                title: Text('Data Center Cooling Leak', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                subtitle: Text('High Priority • Unassigned', style: TextStyle(color: AppColors.accentRose)),
              ),
              const ListTile(
                leading: Icon(Icons.build, color: AppColors.accentAmber),
                title: Text('Security System Firmware Upgrade', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                subtitle: Text('Medium Priority • Unassigned', style: TextStyle(color: AppColors.accentAmber)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCompletedJobsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Completed Today ($_completedTodayCount Jobs)', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.accentEmerald),
                title: Text('Emergency Generator Inspection', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text('Completed by Sam Wilson • \$450', style: TextStyle(color: AppColors.accentEmerald)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRevenueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Revenue Overview', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Total Revenue Today: \$$__totalRevenueFormatted', style: const TextStyle(color: AppColors.accentEmerald, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('32 Dispatched & Billing Contracts Completed', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  void _showCreateJobModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          title: const Text('Create & Dispatch New Job', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Job Title / Description'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Site Address'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  setState(() {
                    _pendingJobsCount++;
                    _liveEvents.insert(
                      0,
                      LiveActivityEvent(
                        time: 'Just now',
                        title: 'New Dispatch Created',
                        detail: titleCtrl.text,
                        icon: Icons.add_task_rounded,
                        color: AppColors.adminRole,
                      ),
                    );
                  });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New job created and added to dispatch queue!')),
                  );
                }
              },
              child: const Text('Dispatch'),
            ),
          ],
        );
      },
    );
  }

  void _showDispatchTaskDialog(TechFleetMember tech) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dispatch notification sent to ${tech.name}!')),
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
            'Are you sure you want to log out of your Admin / Dispatcher account?',
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

// Custom Painter for Admin GIS Fleet Dark Satellite Grid
class _AdminFleetMapPainter extends CustomPainter {
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

    // Grid Radar Circles
    final circlePaint = Paint()
      ..color = AppColors.adminRole.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 80, circlePaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 140, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
