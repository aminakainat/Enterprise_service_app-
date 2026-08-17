import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/payment_invoice_model.dart';
import '../controllers/payment_providers.dart';
import 'payment_gateway_screen.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);
    final paymentController = ref.read(paymentControllerProvider.notifier);

    final filteredInvoices = paymentState.invoices.where((inv) {
      if (_statusFilter == 'Pending') return inv.status == InvoiceStatus.pending;
      if (_statusFilter == 'Paid') return inv.status == InvoiceStatus.paid;
      if (_statusFilter == 'Overdue') return inv.status == InvoiceStatus.overdue;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppColors.accentEmerald, size: 24),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoices & Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Payment Status & Gateway History',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accentEmerald,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded, color: AppColors.accentEmerald),
            tooltip: 'Generate New Invoice',
            onPressed: () => _showCreateInvoiceModal(context, paymentController),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Paid', 'Overdue'].map((filter) {
                  final isSelected = _statusFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.accentEmerald,
                      backgroundColor: AppColors.surfaceCard,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _statusFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Invoices List
            if (filteredInvoices.isEmpty)
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
                    Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'No Invoices Found',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredInvoices.length,
                itemBuilder: (context, index) {
                  final inv = filteredInvoices[index];
                  return _buildInvoiceCard(context, inv);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, FieldInvoice inv) {
    Color statusColor;
    if (inv.status == InvoiceStatus.paid) {
      statusColor = AppColors.accentEmerald;
    } else if (inv.status == InvoiceStatus.overdue) {
      statusColor = AppColors.accentRose;
    } else {
      statusColor = AppColors.accentAmber;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inv.status == InvoiceStatus.overdue ? AppColors.accentRose.withValues(alpha: 0.6) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                inv.id,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  inv.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            inv.customerName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Associated Job: ${inv.jobId}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '\$${inv.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: inv.isPaid ? AppColors.surfaceDark : AppColors.accentEmerald,
                  foregroundColor: inv.isPaid ? AppColors.accentEmerald : Colors.white,
                  side: inv.isPaid ? const BorderSide(color: AppColors.accentEmerald) : null,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentGatewayScreen(invoice: inv),
                    ),
                  );
                },
                icon: Icon(inv.isPaid ? Icons.check_circle_outline : Icons.payment_rounded, size: 16),
                label: Text(inv.isPaid ? 'View Receipt' : 'Pay Invoice'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateInvoiceModal(BuildContext context, PaymentController controller) {
    final customerCtrl = TextEditingController(text: 'Horizon Financial Center');
    final addressCtrl = TextEditingController(text: '450 Tech Plaza');
    final descCtrl = TextEditingController(text: 'Water Leak Sensor Maintenance');
    final amountCtrl = TextEditingController(text: '280.00');

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
                'Generate New Invoice',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: customerCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Customer Address'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Service Description'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Amount (\$)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentEmerald),
                  onPressed: () {
                    final price = double.tryParse(amountCtrl.text) ?? 150.0;
                    controller.createInvoice(
                      jobId: 'JOB-2046',
                      customerName: customerCtrl.text,
                      customerAddress: addressCtrl.text,
                      items: [
                        InvoiceItem(description: descCtrl.text, quantity: 1, unitPrice: price),
                      ],
                    );
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New invoice generated successfully!'),
                        backgroundColor: AppColors.accentEmerald,
                      ),
                    );
                  },
                  child: const Text('Generate Invoice'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
