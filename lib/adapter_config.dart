
import 'package:use_africa_pay_flutter/payment_response.dart';
import 'package:use_africa_pay_flutter/user.dart';

typedef OnSuccessCallback = void Function(PaymentResponse response);
typedef OnCloseCallback = void Function();

class AdapterConfig {
  final String publicKey;
  final String reference;
  final int amount;
  final String currency;
  final User user;
  final OnSuccessCallback onSuccess;
  final OnCloseCallback onClose;
  final Map<String, dynamic>? metadata;
  final String? payment_options;
  final String? contractCode;
  final List<String>? channels;
  final String? merchantId;
  final String? serviceTypeId;
  final bool testMode;

  AdapterConfig({
    required this.publicKey,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.user,
    required this.onSuccess,
    required this.onClose,
    this.metadata,
    this.payment_options,
    this.contractCode,
    this.channels,
    this.merchantId,
    this.serviceTypeId,
    this.testMode = true,
  });
}
