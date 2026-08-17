import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../bluetooth/domain/bluetooth_device_model.dart';
import '../../../bluetooth/presentation/controllers/bluetooth_providers.dart';
import '../../domain/payment_invoice_model.dart';
import '../controllers/payment_providers.dart';

class PaymentGatewayScreen extends ConsumerStatefulWidget {
  final FieldInvoice invoice;

  const PaymentGatewayScreen({super.key, required this.invoice});

  @override
  ConsumerState<PaymentGatewayScreen> createState() =>
      _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState
    extends ConsumerState<PaymentGatewayScreen> {
  PaymentGatewayType _selectedGateway = PaymentGatewayType.stripe;

  // Form Controllers
  final _cardNumberCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _cardExpiryCtrl = TextEditingController(text: '12/28');
  final _cardCvcCtrl = TextEditingController(text: '882');
  final _upiCtrl = TextEditingController(text: 'customer@upi');
  final _mobileAccountCtrl = TextEditingController(text: '0322 1234567');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);
    final paymentController = ref.read(paymentControllerProvider.notifier);

    final currentInvoice = paymentState.invoices.firstWhere(
      (inv) => inv.id == widget.invoice.id,
      orElse: () => widget.invoice,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.payment_rounded, color: AppColors.accentEmerald, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice ${currentInvoice.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Enterprise Payment Gateway',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accentEmerald,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentInvoice.customerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentInvoice.isPaid
                              ? AppColors.accentEmerald
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          currentInvoice.isPaid ? 'PAID' : 'DUE NOW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TOTAL INVOICE AMOUNT',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${currentInvoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subtotal: \$${currentInvoice.subtotal.toStringAsFixed(2)} + Tax (5%): \$${currentInvoice.taxAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // If already paid
            if (currentInvoice.isPaid) ...[
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentEmerald),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.accentEmerald, size: 52),
                    const SizedBox(height: 10),
                    const Text(
                      'Payment Completed Successfully',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Transaction ID: ${currentInvoice.paymentTransactionId ?? "TXN-99824"}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Text(
                      'Paid via ${currentInvoice.paidViaGateway?.displayName ?? "Demo Gateway"}',
                      style: const TextStyle(color: AppColors.accentEmerald, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentEmerald),
                      onPressed: () => _printPaymentReceipt(currentInvoice),
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Print Payment Receipt via Bluetooth'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Gateway Selector Header
              const Text(
                'Select Payment Gateway',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Gateway Options List
              Column(
                children: PaymentGatewayType.values.map((gateway) {
                  final isSelected = _selectedGateway == gateway;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGateway = gateway;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.accentEmerald : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.accentEmerald : AppColors.textMuted,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.accentEmerald,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  gateway.displayName,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              gateway.iconLabel,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Dynamic Payment Gateway Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedGateway == PaymentGatewayType.stripe) ...[
                        const Text(
                          'Stripe Card Processing',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _cardNumberCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Card Number',
                            prefixIcon: Icon(Icons.credit_card_rounded, color: AppColors.accent),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cardExpiryCtrl,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _cardCvcCtrl,
                                obscureText: true,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'CVC'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (_selectedGateway == PaymentGatewayType.razorpay) ...[
                        const Text(
                          'Razorpay UPI / NetBanking',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _upiCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Virtual Payment Address (VPA / UPI ID)',
                            hintText: 'user@upi',
                            prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.adminRole),
                          ),
                        ),
                      ] else ...[
                        Text(
                          '${_selectedGateway.displayName} Account',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _mobileAccountCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Mobile Account Number',
                            hintText: '0322 1234567',
                            prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.accentEmerald),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Pay Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentEmerald,
                          ),
                          onPressed: paymentState.isProcessingPayment
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final ok = await paymentController.processPayment(
                                    invoiceId: currentInvoice.id,
                                    gateway: _selectedGateway,
                                    details: {'account': _mobileAccountCtrl.text},
                                  );

                                  if (ok) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Invoice ${currentInvoice.id} paid via ${_selectedGateway.displayName}!',
                                        ),
                                        backgroundColor: AppColors.accentEmerald,
                                      ),
                                    );
                                  }
                                },
                          icon: paymentState.isProcessingPayment
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(Icons.lock_outline_rounded),
                          label: Text(
                            paymentState.isProcessingPayment
                                ? (paymentState.activePaymentStatusMessage ?? 'Processing...')
                                : 'Pay \$${currentInvoice.totalAmount.toStringAsFixed(2)} Now',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Itemized Invoice Breakdown
            const Text(
              'Itemized Line Items',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentInvoice.items.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 16),
                itemBuilder: (context, index) {
                  final item = currentInvoice.items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Qty: ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printPaymentReceipt(FieldInvoice inv) {
    final report = FieldServiceReport(
      reportId: inv.id,
      jobTitle: 'Payment Receipt for Job ${inv.jobId}',
      customerName: inv.customerName,
      technicianName: 'Field Service Agent',
      location: inv.customerAddress,
      timestamp: inv.paidAt ?? DateTime.now(),
      summary: 'Payment completed via ${inv.paidViaGateway?.displayName ?? "Gateway"}. Transaction ID: ${inv.paymentTransactionId}',
      totalAmount: inv.totalAmount,
    );

    final btController = ref.read(bluetoothControllerProvider.notifier);
    btController.printReport(report);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt sent to connected Bluetooth Thermal Printer!'),
        backgroundColor: AppColors.accentEmerald,
      ),
    );
  }
}
