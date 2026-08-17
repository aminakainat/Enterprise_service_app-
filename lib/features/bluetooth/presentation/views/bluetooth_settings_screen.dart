import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/bluetooth_device_model.dart';
import '../controllers/bluetooth_providers.dart';

class BluetoothSettingsScreen extends ConsumerStatefulWidget {
  const BluetoothSettingsScreen({super.key});

  @override
  ConsumerState<BluetoothSettingsScreen> createState() =>
      _BluetoothSettingsScreenState();
}

class _BluetoothSettingsScreenState
    extends ConsumerState<BluetoothSettingsScreen> {
  String _deviceTypeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final btState = ref.watch(bluetoothControllerProvider);
    final btController = ref.read(bluetoothControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.bluetooth_audio_rounded, color: AppColors.accent, size: 24),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bluetooth Hardware Center',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Printers • External GPS • Scanners',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              btState.isScanning
                  ? Icons.bluetooth_searching_rounded
                  : Icons.sync_rounded,
              color: AppColors.accent,
            ),
            tooltip: 'Scan Devices',
            onPressed: btState.isBluetoothEnabled && !btState.isScanning
                ? () => btController.startScan()
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: btState.isBluetoothEnabled
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: btState.isBluetoothEnabled
                                  ? AppColors.accent.withValues(alpha: 0.15)
                                  : AppColors.inputBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              btState.isBluetoothEnabled
                                  ? Icons.bluetooth_connected_rounded
                                  : Icons.bluetooth_disabled_rounded,
                              color: btState.isBluetoothEnabled
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                btState.isBluetoothEnabled
                                    ? 'Bluetooth Active'
                                    : 'Bluetooth Disabled',
                                style: TextStyle(
                                  color: btState.isBluetoothEnabled
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                btState.isScanning
                                    ? 'Scanning for nearby peripherals...'
                                    : '${btState.discoveredDevices.length} devices available',
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
                        value: btState.isBluetoothEnabled,
                        activeTrackColor: AppColors.accent,
                        onChanged: (val) {
                          btController.toggleBluetooth(val);
                        },
                      ),
                    ],
                  ),
                  if (btState.isBluetoothEnabled) ...[
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 10),

                
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                              foregroundColor: AppColors.accent,
                              side: const BorderSide(color: AppColors.accent),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: btState.isScanning
                                ? null
                                : () => btController.startScan(),
                            icon: btState.isScanning
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accent,
                                    ),
                                  )
                                : const Icon(Icons.search_rounded, size: 18),
                            label: Text(
                              btState.isScanning ? 'Scanning...' : 'Scan Nearby',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.adminRole,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => _showPrintReportModal(context, ref),
                            icon: const Icon(Icons.print_rounded, size: 18),
                            label: const Text(
                              'Print Report',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Connected Hardware Peripherals',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildConnectedPrinterCard(btState, btController),

            const SizedBox(height: 14),

            _buildConnectedGpsCard(btState, btController),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Bluetooth Devices',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap Connect to pair',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Printers', 'GPS Receivers', 'Scanners'].map((filter) {
                  final isSelected = _deviceTypeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.surfaceCard,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _deviceTypeFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            if (!btState.isBluetoothEnabled)
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
                    Icon(Icons.bluetooth_disabled_rounded, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'Bluetooth Adapter Turn Off',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Toggle the switch above to scan thermal printers and external GPS units.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              )
            else ...[
              _buildDiscoveredDevicesList(btState, btController),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedPrinterCard(
      BluetoothState btState, BluetoothController btController) {
    final printer = btState.connectedPrinter;

    if (printer == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.print_disabled_rounded,
                  color: AppColors.textMuted, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Bluetooth Thermal Printer Connected',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Scan nearby devices to connect Zebra, Epson, or TSC printer.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentEmerald, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentEmerald.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentEmerald.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.print_rounded,
                    color: AppColors.accentEmerald, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          printer.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentEmerald.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ONLINE',
                            style: TextStyle(
                              color: AppColors.accentEmerald,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MAC: ${printer.macAddress} • Battery: ${printer.batteryLevel ?? 90}% 🔋',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _showPrintReportModal(context, ref),
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  label: const Text('Print Field Receipt', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentRose),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () {
                  btController.disconnectDevice(printer.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${printer.name} disconnected.')),
                  );
                },
                child: const Text(
                  'Disconnect',
                  style: TextStyle(color: AppColors.accentRose, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedGpsCard(
      BluetoothState btState, BluetoothController btController) {
    final gps = btState.connectedGps;

    if (gps == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.satellite_alt_rounded,
                  color: AppColors.textMuted, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No External Bluetooth GPS Paired',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Pair Garmin GLO, Bad Elf, or Trimble for high-precision sub-meter tracking.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.satellite_alt_rounded,
                    color: AppColors.accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          gps.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'HIGH ACCURACY (±0.4m)',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Satellites: 14 Fix • Lat: 37.7749°, Lon: -122.4194°',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentRose),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                onPressed: () {
                  btController.disconnectDevice(gps.id);
                },
                child: const Text(
                  'Disconnect GPS',
                  style: TextStyle(color: AppColors.accentRose, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 
  Widget _buildDiscoveredDevicesList(
      BluetoothState btState, BluetoothController btController) {
    final filtered = btState.discoveredDevices.where((device) {
      if (_deviceTypeFilter == 'Printers') {
        return device.type == BluetoothDeviceType.printer;
      }
      if (_deviceTypeFilter == 'GPS Receivers') {
        return device.type == BluetoothDeviceType.externalGps;
      }
      if (_deviceTypeFilter == 'Scanners') {
        return device.type == BluetoothDeviceType.scanner;
      }
      return true;
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final device = filtered[index];
        final isConnected = device.isConnected;
        final isConnecting = device.isConnecting;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConnected ? AppColors.accentEmerald : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: device.type.icon == Icons.print_rounded
                      ? AppColors.accentEmerald.withValues(alpha: 0.15)
                      : AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  device.type.icon,
                  color: device.type.icon == Icons.print_rounded
                      ? AppColors.accentEmerald
                      : AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          device.type.label,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.wifi, color: device.signalColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${device.rssi} dBm (${device.signalQuality})',
                          style: TextStyle(color: device.signalColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isConnecting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              else if (isConnected)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentRose),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => btController.disconnectDevice(device.id),
                  child: const Text('Disconnect', style: TextStyle(color: AppColors.accentRose, fontSize: 12)),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await btController.connectDevice(device);
                    if (ok) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Connected to ${device.name}!'),
                          backgroundColor: AppColors.accentEmerald,
                        ),
                      );
                    }
                  },
                  child: const Text('Connect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }
  void _showPrintReportModal(BuildContext context, WidgetRef ref) {
    final btState = ref.read(bluetoothControllerProvider);
    final btController = ref.read(bluetoothControllerProvider.notifier);

    final report = FieldServiceReport(
      reportId: 'REP-9042',
      jobTitle: 'HVAC Air Handler Repair & Calibration',
      customerName: 'Nexus Tech Plaza',
      technicianName: 'Tech Alex Rivers',
      location: '742 Cyber Way, Suite 400',
      timestamp: DateTime.now(),
      summary: 'Replaced air filters, calibrated pressure sensors, and pressure tested lines. System operating at 98% efficiency.',
      totalAmount: 385.00,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            final printerName = btState.connectedPrinter?.name ?? 'No Printer Connected';
            final hasPrinter = btState.connectedPrinter != null;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.print_rounded, color: AppColors.accentEmerald),
                          SizedBox(width: 10),
                          Text(
                            'Print Field Service Report',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasPrinter ? AppColors.accentEmerald : AppColors.accentRose,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasPrinter ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          color: hasPrinter ? AppColors.accentEmerald : AppColors.accentRose,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Target Printer: $printerName',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Thermal Receipt Preview:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(14),
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        report.generateReceiptText(),
                        style: const TextStyle(
                          color: AppColors.accentEmerald,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasPrinter ? AppColors.accentEmerald : AppColors.textMuted,
                      ),
                      onPressed: hasPrinter
                          ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.of(ctx).pop();
                              final ok = await btController.printReport(report);
                              if (ok) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Report printed successfully to Bluetooth Printer!'),
                                    backgroundColor: AppColors.accentEmerald,
                                  ),
                                );
                              }
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please connect a Bluetooth printer first!'),
                                  backgroundColor: AppColors.accentRose,
                                ),
                              );
                            },
                      icon: const Icon(Icons.print_rounded),
                      label: Text(
                        hasPrinter ? 'Print Now via Bluetooth' : 'Connect Printer to Print',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
