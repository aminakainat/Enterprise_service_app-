import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_field_service/features/payment/domain/payment_invoice_model.dart';

void main() {
  group('FieldInvoice Model Unit Tests', () {
    test('Calculates invoice item total, subtotal, 5% tax, and total amount accurately', () {
      final items = [
        InvoiceItem(description: 'HVAC Sensor Replacement', quantity: 2, unitPrice: 100.0), // 200.0
        InvoiceItem(description: 'Labor Hours', quantity: 3, unitPrice: 50.0), // 150.0
      ];

      final invoice = FieldInvoice(
        id: 'INV-1001',
        jobId: 'JOB-55',
        customerName: 'Acme Corp',
        customerAddress: '100 Main St',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        items: items,
      );

      expect(items[0].totalPrice, equals(200.0));
      expect(items[1].totalPrice, equals(150.0));
      expect(invoice.subtotal, equals(350.0));
      expect(invoice.taxAmount, equals(17.5)); // 5% of 350
      expect(invoice.totalAmount, equals(367.5));
      expect(invoice.isPaid, isFalse);
    });

    test('PaymentGatewayType enum displays correct titles and badges', () {
      expect(PaymentGatewayType.stripe.displayName, contains('Stripe'));
      expect(PaymentGatewayType.jazzcash.iconLabel, contains('JazzCash'));
    });
  });
}
