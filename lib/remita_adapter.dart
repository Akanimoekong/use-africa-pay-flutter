import 'dart:js_interop';

import 'package:use_africa_pay_flutter/adapter_config.dart';
import 'package:use_africa_pay_flutter/adapter_interface.dart';
import 'package:use_africa_pay_flutter/payment_response.dart';
import 'package:use_africa_pay_flutter/script_loader.dart';

@JS('RmPaymentEngine.init')
external RemitaPaymentEngine _remitaInit(RemitaOptions options);

@JS()
@anonymous
extension type RemitaOptions._(JSObject _) {
  external factory RemitaOptions({
    JSString key,
    JSString merchantId,
    JSString serviceTypeId,
    JSNumber amount,
    JSString currency,
    JSString transactionId,
    JSString customerId,
    JSString firstName,
    JSString lastName,
    JSString email,
    JSString narration,
    JSFunction onSuccess,
    JSFunction onError,
    JSFunction onClose,
  });
}

@JS()
@anonymous
extension type RemitaPaymentEngine._(JSObject _) {
  external void showPaymentWidget();
}

class RemitaAdapter implements AdapterInterface {
  @override
  Future<void> loadScript({bool testMode = true}) async {
    final url = testMode
        ? 'https://remitademo.net/payment/v1/remita-pay-inline.bundle.js'
        : 'https://login.remita.net/payment/v1/remita-pay-inline.bundle.js';
    await loadScript(url);
  }

  @override
  void initialize(AdapterConfig config) {
    if (config.merchantId == null) {
      throw Exception('Merchant ID is required for Remita');
    }
    if (config.serviceTypeId == null) {
      throw Exception('Service Type ID is required for Remita');
    }

    final paymentEngine = _remitaInit(
      RemitaOptions(
        key: config.publicKey.toJS,
        merchantId: config.merchantId!.toJS,
        serviceTypeId: config.serviceTypeId!.toJS,
        amount: (config.amount / 100).toJS,
        currency: config.currency.toJS,
        transactionId: config.reference.toJS,
        customerId: config.user.email.toJS,
        firstName: (config.user.name?.split(' ').first ?? '').toJS,
        lastName: (config.user.name?.split(' ').sublist(1).join(' ') ?? '').toJS,
        email: config.user.email.toJS,
        narration: (config.metadata?['description'] ?? 'Payment').toJS,
        onSuccess: (JSAny response) {
          final responseAsObject = response as JSObject;

          // Break down the logic into simple steps to help the static analyzer.
          JSAny? txIdJs = responseAsObject['transactionId'.toJS];
          if (txIdJs == null || txIdJs.isUndefinedOrNull) {
            txIdJs = responseAsObject['RRR'.toJS];
          }
          final txIdDart = txIdJs?.toDart;

          final paymentResponse = PaymentResponse(
            status: 'success',
            message: 'Payment completed successfully',
            reference: config.reference,
            transactionId: txIdDart as String?,
            amount: config.amount,
            currency: config.currency,
            paidAt: DateTime.now().toIso8601String(),
            customer: Customer(
              email: config.user.email,
              name: config.user.name,
              phone: config.user.phonenumber ?? config.user.phone,
            ),
            provider: 'remita',
            metadata: config.metadata,
            raw: response.toDart,
          );
          config.onSuccess(paymentResponse);
        }.toJS,
        onError: (JSAny response) {
          print('Remita payment error: $response');
        }.toJS,
        onClose: config.onClose.toJS,
      ),
    );

    paymentEngine.showPaymentWidget();
  }

  @override
  JSAny? getInstance() {
    return JSAny.global['RmPaymentEngine'];
  }
}
