import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/payment/domain/payment_invoice_model.dart';
import '../../features/technician/presentation/views/technician_dashboard_screen.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveJob(TechnicianJob job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).set({
        'id': job.id,
        'title': job.title,
        'customerName': job.customerName,
        'address': job.address,
        'time': job.time,
        'priority': job.priority,
        'status': job.status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Stream<List<Map<String, dynamic>>> streamJobs() {
    return _firestore
        .collection('jobs')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
  Future<void> saveInvoice(FieldInvoice invoice) async {
    try {
      await _firestore.collection('invoices').doc(invoice.id).set({
        'id': invoice.id,
        'jobId': invoice.jobId,
        'customerName': invoice.customerName,
        'customerAddress': invoice.customerAddress,
        'subtotal': invoice.subtotal,
        'taxAmount': invoice.taxAmount,
        'totalAmount': invoice.totalAmount,
        'status': invoice.status.name,
        'paymentTransactionId': invoice.paymentTransactionId,
        'paidViaGateway': invoice.paidViaGateway?.name,
        'issueDate': invoice.issueDate.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> updateInvoicePayment({
    required String invoiceId,
    required String status,
    required String transactionId,
    required String gatewayName,
  }) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).update({
        'status': status,
        'paymentTransactionId': transactionId,
        'paidViaGateway': gatewayName,
        'paidAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
  Future<void> updateTechnicianTelemetry({
    required String techId,
    required String name,
    required double latitude,
    required double longitude,
    required double speedMph,
    required bool isExternalGps,
  }) async {
    try {
      await _firestore.collection('technicians').doc(techId).set({
        'id': techId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'speedMph': speedMph,
        'isExternalGps': isExternalGps,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
