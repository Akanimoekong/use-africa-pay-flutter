// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

import 'package:use_africa_pay_flutter/adapter_config.dart';
import 'package:use_africa_pay_flutter/adapter_interface.dart';
import 'package:use_africa_pay_flutter/models/payment_response.dart';
import 'package:use_africa_pay_flutter/script_loader.dart' as loader;

@JS('PaystackPop.setup')
external PaystackPopup _paystackSetup(PaystackOptions options);

@JS()
@anonymous
extension type PaystackOptions._(JSObject _) implements JSObject {
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
extension type PaystackPopup._(JSObject _) implements JSObject {
  external void openIframe();
}

class PaystackAdapter implements AdapterInterface {
  @override
  Future<void> loadScript({bool testMode = true}) async {
    await loader.loadScript('https://js.paystack.co/v1/inline.js');
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
        metadata: config.metadata?.jsify(),
        channels: config.channels?.map((c) => c.toJS).toList().toJS,
        callback: (JSAny response) {
          final responseAsObject = response as JSObject;

          // Break down the logic into simple steps to help the static analyzer.
          final refJs = responseAsObject['reference'] as JSString?;
          final refDart = refJs?.toDart;

          JSAny? txIdJs = responseAsObject['trans'];
          if (txIdJs == null || txIdJs.isUndefinedOrNull) {
            txIdJs = responseAsObject['transaction'];
          }
          // Assuming transaction ID is a string, but handle potential numbers if needed, though usually string.
          final txIdDart = (txIdJs as JSString?)?.toDart;

          final paymentResponse = PaymentResponse(
            status: 'success',
            message: 'Payment completed successfully',
            reference: refDart,
            transactionId: txIdDart,
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
            raw: response.dartify(),
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
    return web.window['PaystackPop'];
  }
}
