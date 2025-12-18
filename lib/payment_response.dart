class PaymentResponse {
  final String status;
  final String message;
  final String? reference;
  final String? transactionId;
  final int amount;
  final String currency;
  final String paidAt;
  final Customer customer;
  final String provider;
  final Map<String, dynamic>? metadata;
  final dynamic raw;

  PaymentResponse({
    required this.status,
    required this.message,
    this.reference,
    this.transactionId,
    required this.amount,
    required this.currency,
    required this.paidAt,
    required this.customer,
    required this.provider,
    this.metadata,
    this.raw,
  });
}

class Customer {
  final String email;
  final String? name;
  final String? phone;

  Customer({
    required this.email,
    this.name,
    this.phone,
  });
}
