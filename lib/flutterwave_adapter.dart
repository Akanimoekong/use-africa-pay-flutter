import 'dart:js_interop';

import 'package:use_africa_pay_flutter/adapter_config.dart';
import 'package:use_africa_pay_flutter/adapter_interface.dart';
import 'package:use_africa_pay_flutter/payment_response.dart';
import 'package:use_africa_pay_flutter/user.dart';
import 'package:js/js.dart';


@JS('FlutterwaveCheckout')
external void _flutterwaveCheckout(FlutterwaveOptions options);

@JS()
@anonymous
extension type FlutterwaveOptions._(JSObject _) {
  external factory FlutterwaveOptions({
    JSString public_key,
    JSString tx_ref,
    JSNumber amount,
    JSString currency,
    JSString? payment_options,
    CustomerOptions customer,
    JSAny? meta,
    JSFunction callback,
    JSFunction onclose,
    Customizations customizations,
  });
}

@JS()
@anonymous
extension type CustomerOptions._(JSObject _) {
  external factory CustomerOptions({JSString email, JSString? phone_number, JSString? name});
}

@JS()
@anonymous
extension type Customizations._(JSObject _) {
  external factory Customizations({JSString title, JSString description, JSString? logo});
}

class FlutterwaveAdapter implements AdapterInterface {
  @override
  Future<void> loadScript({bool testMode = true}) async {
    await loadScript('https://checkout.flutterwave.com/v3.js');
  }

  @override
  void initialize(AdapterConfig config) {
    if (config.user.phonenumber == null) {
      print('Flutterwave requires a phone number for some payment methods.');
    }

    _flutterwaveCheckout(
      FlutterwaveOptions(
        public_key: config.publicKey.toJS,
        tx_ref: config.reference.toJS,
        amount: (config.amount / 100).toJS,
        currency: config.currency.toJS,
        payment_options: (config.payment_options ?? 'card,mobilemoney,ussd').toJS,
        customer: CustomerOptions(
          email: config.user.email.toJS,
          phone_number: config.user.phonenumber?.toJS,
          name: config.user.name?.toJS,
        ),
        meta: config.metadata?.toJSBox,
        callback: (JSAny response) {
          final responseAsObject = response as JSObject;
          if (responseAsObject['status'.toJS] == 'successful'.toJS) {
            final paymentResponse = PaymentResponse(
              status: 'success',
              message: 'Payment completed successfully',
              reference: responseAsObject['tx_ref'.toJS]?.toDart as String?,
              transactionId: responseAsObject['transaction_id'.toJS]?.toDart.toString(),
              amount: config.amount,
              currency: config.currency,
              paidAt: DateTime.now().toIso8601String(),
              customer: Customer(
                email: config.user.email,
                name: config.user.name,
                phone: config.user.phonenumber ?? config.user.phone,
              ),
              provider: 'flutterwave',
              metadata: config.metadata,
              raw: response.toDart,
            );
            config.onSuccess(paymentResponse);
          }
        }.toJS,
        onclose: config.onClose.toJS,
        customizations: Customizations(
          title: (config.metadata?['title'] ?? 'Payment').toJS,
          description: (config.metadata?['description'] ?? 'Payment').toJS,
          logo: (config.metadata?['logo'] as String?)?.toJS,
        ),
      ),
    );
  }

  @override
  JSAny? getInstance() {
    return JSAny.global['FlutterwaveCheckout'];
  }
}
