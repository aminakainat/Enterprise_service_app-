enum PaymentGatewayType {
  stripe,
  razorpay,
  jazzcash,
  easypaisa;

  String get displayName {
    switch (this) {
      case PaymentGatewayType.stripe:
        return 'Stripe (Credit / Debit Card)';
      case PaymentGatewayType.razorpay:
        return 'Razorpay (UPI / NetBanking / Cards)';
      case PaymentGatewayType.jazzcash:
        return 'JazzCash Mobile Wallet (Pakistan)';
      case PaymentGatewayType.easypaisa:
        return 'EasyPaisa Account (Pakistan)';
    }
  }

  String get iconLabel {
    switch (this) {
      case PaymentGatewayType.stripe:
        return '💳 Stripe';
      case PaymentGatewayType.razorpay:
        return '💳 Razorpay';
      case PaymentGatewayType.jazzcash:
        return '🇵🇰 JazzCash';
      case PaymentGatewayType.easypaisa:
        return '🇵🇰 EasyPaisa';
    }
  }
}

enum InvoiceStatus {
  pending,
  paid,
  overdue,
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}

class FieldInvoice {
  final String id;
  final String jobId;
  final String customerName;
  final String customerAddress;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  InvoiceStatus status;
  String? paymentTransactionId;
  PaymentGatewayType? paidViaGateway;
  DateTime? paidAt;

  FieldInvoice({
    required this.id,
    required this.jobId,
    required this.customerName,
    required this.customerAddress,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    this.status = InvoiceStatus.pending,
    this.paymentTransactionId,
    this.paidViaGateway,
    this.paidAt,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get taxAmount => subtotal * 0.05; // 5% tax
  double get totalAmount => subtotal + taxAmount;

  bool get isPaid => status == InvoiceStatus.paid;
}
