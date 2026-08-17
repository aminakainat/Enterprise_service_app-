import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/bluetooth_device_model.dart';

class BluetoothState {
  final bool isBluetoothEnabled;
  final bool isScanning;
  final List<BluetoothPeripheralDevice> discoveredDevices;
  final BluetoothPeripheralDevice? connectedPrinter;
  final BluetoothPeripheralDevice? connectedGps;
  final String? activePrintJobStatus;

  BluetoothState({
    this.isBluetoothEnabled = true,
    this.isScanning = false,
    required this.discoveredDevices,
    this.connectedPrinter,
    this.connectedGps,
    this.activePrintJobStatus,
  });

  BluetoothState copyWith({
    bool? isBluetoothEnabled,
    bool? isScanning,
    List<BluetoothPeripheralDevice>? discoveredDevices,
    BluetoothPeripheralDevice? connectedPrinter,
    bool clearConnectedPrinter = false,
    BluetoothPeripheralDevice? connectedGps,
    bool clearConnectedGps = false,
    String? activePrintJobStatus,
    bool clearPrintStatus = false,
  }) {
    return BluetoothState(
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
      isScanning: isScanning ?? this.isScanning,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedPrinter: clearConnectedPrinter
          ? null
          : (connectedPrinter ?? this.connectedPrinter),
      connectedGps: clearConnectedGps ? null : (connectedGps ?? this.connectedGps),
      activePrintJobStatus: clearPrintStatus
          ? null
          : (activePrintJobStatus ?? this.activePrintJobStatus),
    );
  }
}

class BluetoothController extends StateNotifier<BluetoothState> {
  BluetoothController()
      : super(
          BluetoothState(
            isBluetoothEnabled: true,
            isScanning: false,
            discoveredDevices: [
              BluetoothPeripheralDevice(
                id: 'DEV-001',
                name: 'Zebra ZQ520 Thermal Printer',
                macAddress: '00:22:58:3B:19:A4',
                type: BluetoothDeviceType.printer,
                rssi: -52,
                batteryLevel: 92,
              ),
              BluetoothPeripheralDevice(
                id: 'DEV-002',
                name: 'Garmin GLO 2 High-Prec GPS',
                macAddress: 'AC:79:12:F4:88:C1',
                type: BluetoothDeviceType.externalGps,
                rssi: -65,
                batteryLevel: 85,
              ),
              BluetoothPeripheralDevice(
                id: 'DEV-003',
                name: 'Epson Mobile Receipt P20',
                macAddress: '44:D8:32:01:99:EE',
                type: BluetoothDeviceType.printer,
                rssi: -78,
                batteryLevel: 64,
              ),
              BluetoothPeripheralDevice(
                id: 'DEV-004',
                name: 'Bad Elf GPS Pro+',
                macAddress: '00:1A:7D:DA:71:05',
                type: BluetoothDeviceType.externalGps,
                rssi: -84,
                batteryLevel: 45,
              ),
              BluetoothPeripheralDevice(
                id: 'DEV-005',
                name: 'Honeywell Barcode Scanner 1950',
                macAddress: '12:34:56:78:9A:BC',
                type: BluetoothDeviceType.scanner,
                rssi: -70,
                batteryLevel: 80,
              ),
            ],
          ),
        );

  void toggleBluetooth(bool enabled) {
    state = state.copyWith(
      isBluetoothEnabled: enabled,
      isScanning: false,
    );
  }

  Future<void> startScan() async {
    if (!state.isBluetoothEnabled) return;
    state = state.copyWith(isScanning: true);

    await Future.delayed(const Duration(seconds: 2));

    final newDeviceList = List<BluetoothPeripheralDevice>.from(state.discoveredDevices);
    if (!newDeviceList.any((d) => d.id == 'DEV-006')) {
      newDeviceList.insert(
        0,
        BluetoothPeripheralDevice(
          id: 'DEV-006',
          name: 'TSC Alpha-3R Mobile Printer',
          macAddress: 'E8:6B:EA:91:02:11',
          type: BluetoothDeviceType.printer,
          rssi: -48,
          batteryLevel: 98,
        ),
      );
    }

    state = state.copyWith(
      isScanning: false,
      discoveredDevices: newDeviceList,
    );
  }

  Future<bool> connectDevice(BluetoothPeripheralDevice device) async {
    if (!state.isBluetoothEnabled) return false;


    final updatedList = state.discoveredDevices.map((d) {
      if (d.id == device.id) {
        return BluetoothPeripheralDevice(
          id: d.id,
          name: d.name,
          macAddress: d.macAddress,
          type: d.type,
          rssi: d.rssi,
          status: BluetoothConnectionStatus.connecting,
          batteryLevel: d.batteryLevel,
        );
      }
      return d;
    }).toList();

    state = state.copyWith(discoveredDevices: updatedList);

    await Future.delayed(const Duration(seconds: 1));

    final connectedDevice = BluetoothPeripheralDevice(
      id: device.id,
      name: device.name,
      macAddress: device.macAddress,
      type: device.type,
      rssi: device.rssi,
      status: BluetoothConnectionStatus.connected,
      batteryLevel: device.batteryLevel,
    );

    final finalList = state.discoveredDevices.map((d) {
      if (d.id == device.id) return connectedDevice;
      return d;
    }).toList();

    if (device.type == BluetoothDeviceType.printer) {
      state = state.copyWith(
        discoveredDevices: finalList,
        connectedPrinter: connectedDevice,
      );
    } else if (device.type == BluetoothDeviceType.externalGps) {
      state = state.copyWith(
        discoveredDevices: finalList,
        connectedGps: connectedDevice,
      );
    } else {
      state = state.copyWith(discoveredDevices: finalList);
    }

    return true;
  }

  Future<void> disconnectDevice(String deviceId) async {
    final updatedList = state.discoveredDevices.map((d) {
      if (d.id == deviceId) {
        return BluetoothPeripheralDevice(
          id: d.id,
          name: d.name,
          macAddress: d.macAddress,
          type: d.type,
          rssi: d.rssi,
          status: BluetoothConnectionStatus.disconnected,
          batteryLevel: d.batteryLevel,
        );
      }
      return d;
    }).toList();

    bool clearPrinter = state.connectedPrinter?.id == deviceId;
    bool clearGps = state.connectedGps?.id == deviceId;

    state = state.copyWith(
      discoveredDevices: updatedList,
      clearConnectedPrinter: clearPrinter,
      clearConnectedGps: clearGps,
    );
  }

  Future<bool> printReport(FieldServiceReport report) async {
    if (state.connectedPrinter == null) {
      return false;
    }

    state = state.copyWith(activePrintJobStatus: 'Sending receipt data to ${state.connectedPrinter!.name}...');
    await Future.delayed(const Duration(milliseconds: 1200));

    state = state.copyWith(activePrintJobStatus: 'Printing report lines...');
    await Future.delayed(const Duration(milliseconds: 1500));

    state = state.copyWith(clearPrintStatus: true);
    return true;
  }
}

final bluetoothControllerProvider =
    StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  return BluetoothController();
});
