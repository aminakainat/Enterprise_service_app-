import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/payment_invoice_model.dart';

class PaymentState {
  final List<FieldInvoice> invoices;
  final bool isProcessingPayment;
  final String? activePaymentStatusMessage;

  PaymentState({
    required this.invoices,
    this.isProcessingPayment = false,
    this.activePaymentStatusMessage,
  });

  PaymentState copyWith({
    List<FieldInvoice>? invoices,
    bool? isProcessingPayment,
    String? activePaymentStatusMessage,
    bool clearMessage = false,
  }) {
    return PaymentState(
      invoices: invoices ?? this.invoices,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      activePaymentStatusMessage: clearMessage
          ? null
          : (activePaymentStatusMessage ?? this.activePaymentStatusMessage),
    );
  }
}

class PaymentController extends StateNotifier<PaymentState> {
  final FirestoreService _firestoreService;

  PaymentController(this._firestoreService)
      : super(
          PaymentState(
            invoices: [
              FieldInvoice(
                id: 'INV-7041',
                jobId: 'JOB-2041',
                customerName: 'Nexus Tech Plaza',
                customerAddress: '742 Cyber Way, Suite 400',
                issueDate: DateTime.now().subtract(const Duration(days: 1)),
                dueDate: DateTime.now().add(const Duration(days: 14)),
                status: InvoiceStatus.pending,
                items: [
                  InvoiceItem(description: 'HVAC Air Filter Replacement', quantity: 2, unitPrice: 45.0),
                  InvoiceItem(description: 'Technician Labor (2.5 hrs)', quantity: 2, unitPrice: 120.0),
                  InvoiceItem(description: 'Refrigerant Pressure Calibration', quantity: 1, unitPrice: 85.0),
                ],
              ),
              FieldInvoice(
                id: 'INV-7038',
                jobId: 'JOB-2038',
                customerName: 'Metro Health Hospital',
                customerAddress: '88 Wellness Parkway',
                issueDate: DateTime.now().subtract(const Duration(days: 3)),
                dueDate: DateTime.now().subtract(const Duration(days: 1)),
                status: InvoiceStatus.paid,
                paymentTransactionId: 'TXN-STRIPE-994812',
                paidViaGateway: PaymentGatewayType.stripe,
                paidAt: DateTime.now().subtract(const Duration(days: 1)),
                items: [
                  InvoiceItem(description: 'Emergency Generator Sensor Kit', quantity: 1, unitPrice: 320.0),
                  InvoiceItem(description: 'High-Voltage Circuit Inspection', quantity: 1, unitPrice: 150.0),
                ],
              ),
              FieldInvoice(
                id: 'INV-7045',
                jobId: 'JOB-2045',
                customerName: 'Aero Dynamics HQ',
                customerAddress: '120 Innovation Blvd',
                issueDate: DateTime.now().subtract(const Duration(days: 5)),
                dueDate: DateTime.now().subtract(const Duration(days: 2)),
                status: InvoiceStatus.overdue,
                items: [
                  InvoiceItem(description: 'Fiber Optic High-Speed Router', quantity: 1, unitPrice: 490.0),
                  InvoiceItem(description: 'Enterprise Network Setup', quantity: 1, unitPrice: 210.0),
                ],
              ),
            ],
          ),
        );

  Future<bool> processPayment({
    required String invoiceId,
    required PaymentGatewayType gateway,
    required Map<String, String> details,
  }) async {
    state = state.copyWith(
      isProcessingPayment: true,
      activePaymentStatusMessage: 'Connecting to ${gateway.displayName}...',
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    state = state.copyWith(
      activePaymentStatusMessage: 'Authenticating payment credentials...',
    );

    await Future.delayed(const Duration(milliseconds: 1400));

    final txnId = 'TXN-${gateway.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final updatedInvoices = state.invoices.map((inv) {
      if (inv.id == invoiceId) {
        inv.status = InvoiceStatus.paid;
        inv.paymentTransactionId = txnId;
        inv.paidViaGateway = gateway;
        inv.paidAt = DateTime.now();

        // Write directly to Cloud Firestore database!
        _firestoreService.updateInvoicePayment(
          invoiceId: inv.id,
          status: 'paid',
          transactionId: txnId,
          gatewayName: gateway.name,
        );
      }
      return inv;
    }).toList();

    state = state.copyWith(
      isProcessingPayment: false,
      invoices: updatedInvoices,
      clearMessage: true,
    );

    return true;
  }

  void createInvoice({
    required String jobId,
    required String customerName,
    required String customerAddress,
    required List<InvoiceItem> items,
  }) {
    final newInv = FieldInvoice(
      id: 'INV-${7046 + state.invoices.length}',
      jobId: jobId,
      customerName: customerName,
      customerAddress: customerAddress,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      status: InvoiceStatus.pending,
      items: items,
    );

    // Save directly to Cloud Firestore database!
    _firestoreService.saveInvoice(newInv);

    state = state.copyWith(
      invoices: [newInv, ...state.invoices],
    );
  }
}

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, PaymentState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return PaymentController(firestoreService);
});
