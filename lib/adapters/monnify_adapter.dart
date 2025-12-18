// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

import 'package:use_africa_pay_flutter/adapter_config.dart';
import 'package:use_africa_pay_flutter/adapter_interface.dart';
import 'package:use_africa_pay_flutter/models/payment_response.dart';
import 'package:use_africa_pay_flutter/script_loader.dart' as loader;

@JS('MonnifySDK.initialize')
external void _monnifyInitialize(MonnifyOptions options);

@JS()
@anonymous
extension type MonnifyOptions._(JSObject _) implements JSObject {
  external factory MonnifyOptions({
    JSNumber amount,
    JSString currency,
    JSString reference,
    JSString customerName,
    JSString customerEmail,
    JSString apiKey,
    JSString contractCode,
    JSString paymentDescription,
    JSAny? metadata,
    JSFunction onComplete,
    JSFunction onClose,
  });
}

class MonnifyAdapter implements AdapterInterface {
  @override
  Future<void> loadScript({bool testMode = true}) async {
    await loader.loadScript('https://sdk.monnify.com/plugin/monnify.js');
  }

  @override
  void initialize(AdapterConfig config) {
    if (config.contractCode == null) {
      throw Exception('Contract Code is required for Monnify');
    }
    if (config.user.name == null) {
      throw Exception('User name is required for Monnify');
    }

    _monnifyInitialize(
      MonnifyOptions(
        amount: (config.amount / 100).toJS,
        currency: config.currency.toJS,
        reference: config.reference.toJS,
        customerName: config.user.name!.toJS,
        customerEmail: config.user.email.toJS,
        apiKey: config.publicKey.toJS,
        contractCode: config.contractCode!.toJS,
        paymentDescription: (config.metadata?['description'] ?? 'Payment').toJS,
        metadata: config.metadata?.jsify(),
        onComplete: (JSAny response) {
          final responseAsObject = response as JSObject;
          final status = (responseAsObject['status'] as JSString?)?.toDart;

          final isSuccess = status == 'PAID' || status == 'SUCCESS';

          final paymentResponse = PaymentResponse(
            status: isSuccess ? 'success' : 'failed',
            message: isSuccess
                ? 'Payment completed successfully'
                : 'Payment failed',
            reference:
                (responseAsObject['paymentReference'] as JSString?)?.toDart,
            transactionId:
                (responseAsObject['transactionReference'] as JSString?)?.toDart,
            amount: config.amount,
            currency: config.currency,
            paidAt: DateTime.now().toIso8601String(),
            customer: Customer(
              email: config.user.email,
              name: config.user.name,
              phone: config.user.phonenumber ?? config.user.phone,
            ),
            provider: 'monnify',
            metadata: config.metadata,
            raw: response.dartify(),
          );
          if (isSuccess) {
            config.onSuccess(paymentResponse);
          }
        }.toJS,
        onClose: (JSAny data) {
          config.onClose();
        }.toJS,
      ),
    );
  }

  @override
  JSAny? getInstance() {
    return web.window['MonnifySDK'];
  }
}
