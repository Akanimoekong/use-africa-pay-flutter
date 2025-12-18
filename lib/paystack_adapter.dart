import 'dart:js_interop';

import 'package:use_africa_pay_flutter/adapter_config.dart';
import 'package:use_africa_pay_flutter/adapter_interface.dart';
import 'package:use_africa_pay_flutter/payment_response.dart';
import 'package:use_africa_pay_flutter/script_loader.dart';

@JS('PaystackPop.setup')
external PaystackPopup _paystackSetup(PaystackOptions options);

@JS()
@anonymous
extension type PaystackOptions._(JSObject _) {
  external factory PaystackOptions({
    JSString key,
    JSString email,
    JSNumber amount,
    JSString currency,
    JSString ref,
    JSAny? metadata,
    JSArray<JSString>? channels,
    JSFunction callback,
    JSFunction onClose,
  });
}

@JS()
@anonymous
extension type PaystackPopup._(JSObject _) {
  external void openIframe();
}

class PaystackAdapter implements AdapterInterface {
  @override
  Future<void> loadScript({bool testMode = true}) async {
    await loadScript('https://js.paystack.co/v1/inline.js');
  }

  @override
  void initialize(AdapterConfig config) {
    final handler = _paystackSetup(
      PaystackOptions(
        key: config.publicKey.toJS,
        email: config.user.email.toJS,
        amount: config.amount.toJS, // Paystack expects amount in kobo
        currency: config.currency.toJS,
        ref: config.reference.toJS,
        metadata: config.metadata?.toJSBox,
        channels: config.channels?.map((c) => c.toJS).toList().toJS,
        callback: (JSAny response) {
          final responseAsObject = response as JSObject;

          // Break down the logic into simple steps to help the static analyzer.
          final refJs = responseAsObject['reference'.toJS];
          final refDart = refJs?.toDart;

          JSAny? txIdJs = responseAsObject['trans'.toJS];
          if (txIdJs == null || txIdJs.isUndefinedOrNull) {
            txIdJs = responseAsObject['transaction'.toJS];
          }
          final txIdDart = txIdJs?.toDart;

          final paymentResponse = PaymentResponse(
            status: 'success',
            message: 'Payment completed successfully',
            reference: refDart as String?,
            transactionId: txIdDart as String?,
            amount: config.amount,
            currency: config.currency,
            paidAt: DateTime.now().toIso8601String(),
            customer: Customer(
              email: config.user.email,
              name: config.user.name,
              phone: config.user.phonenumber ?? config.user.phone,
            ),
            provider: 'paystack',
            metadata: config.metadata,
            raw: response.toDart,
          );
          config.onSuccess(paymentResponse);
        }.toJS,
        onClose: config.onClose.toJS,
      ),
    );
    handler.openIframe();
  }

  @override
  JSAny? getInstance() {
    return JSAny.global['PaystackPop'];
  }
}
