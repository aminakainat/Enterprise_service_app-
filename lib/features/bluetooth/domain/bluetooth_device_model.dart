import 'package:flutter/material.dart';

enum BluetoothDeviceType {
  printer,
  externalGps,
  scanner,
  sensor,
  other;

  String get label {
    switch (this) {
      case BluetoothDeviceType.printer:
        return 'Thermal Printer';
      case BluetoothDeviceType.externalGps:
        return 'High-Precision GPS';
      case BluetoothDeviceType.scanner:
        return 'Barcode / RFID Scanner';
      case BluetoothDeviceType.sensor:
        return 'Telemetry Sensor';
      case BluetoothDeviceType.other:
        return 'Bluetooth Peripheral';
    }
  }

  IconData get icon {
    switch (this) {
      case BluetoothDeviceType.printer:
        return Icons.print_rounded;
      case BluetoothDeviceType.externalGps:
        return Icons.satellite_alt_rounded;
      case BluetoothDeviceType.scanner:
        return Icons.qr_code_scanner_rounded;
      case BluetoothDeviceType.sensor:
        return Icons.sensors_rounded;
      case BluetoothDeviceType.other:
        return Icons.bluetooth_rounded;
    }
  }
}

enum BluetoothConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class BluetoothPeripheralDevice {
  final String id;
  final String name;
  final String macAddress;
  final BluetoothDeviceType type;
  final int rssi; // Signal Strength in dBm (e.g. -55)
  BluetoothConnectionStatus status;
  final int? batteryLevel; // Percentage 0-100
  final Map<String, dynamic>? metadata;

  BluetoothPeripheralDevice({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.type,
    required this.rssi,
    this.status = BluetoothConnectionStatus.disconnected,
    this.batteryLevel,
    this.metadata,
  });

  bool get isConnected => status == BluetoothConnectionStatus.connected;
  bool get isConnecting => status == BluetoothConnectionStatus.connecting;

  String get signalQuality {
    if (rssi >= -60) return 'Excellent';
    if (rssi >= -75) return 'Good';
    if (rssi >= -88) return 'Fair';
    return 'Weak';
  }

  Color get signalColor {
    if (rssi >= -60) return const Color(0xFF10B981); // Emerald
    if (rssi >= -75) return const Color(0xFF38BDF8); // Sky
    if (rssi >= -88) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Rose
  }
}

class FieldServiceReport {
  final String reportId;
  final String jobTitle;
  final String customerName;
  final String technicianName;
  final String location;
  final DateTime timestamp;
  final String summary;
  final double totalAmount;

  FieldServiceReport({
    required this.reportId,
    required this.jobTitle,
    required this.customerName,
    required this.technicianName,
    required this.location,
    required this.timestamp,
    required this.summary,
    required this.totalAmount,
  });

  String generateReceiptText() {
    return '''
================================
  ENTERPRISE FIELD SERVICE REPORT
================================
Report ID : $reportId
Date/Time : ${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}
Tech ID   : $technicianName
Customer  : $customerName
Location  : $location

JOB DETAILS:
Title: $jobTitle
Summary: $summary

BILLING DETAILS:
Service Fee : \$${totalAmount.toStringAsFixed(2)}
Tax (0%)    : \$0.00
--------------------------------
TOTAL DUE   : \$${totalAmount.toStringAsFixed(2)}
================================
   THANK YOU FOR YOUR BUSINESS!
================================
''';
  }
}
