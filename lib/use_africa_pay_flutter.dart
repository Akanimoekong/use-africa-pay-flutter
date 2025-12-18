library my_package;

export 'adapter_config.dart';
export 'adapter_interface.dart';
export 'payment_response.dart';
export 'user.dart';

import 'package:use_africa_pay_flutter/adapter_interface.dart';
import 'package:use_africa_pay_flutter/flutterwave_adapter.dart';
import 'package:use_africa_pay_flutter/monnify_adapter.dart';
import 'package:use_africa_pay_flutter/paystack_adapter.dart';
import 'package:use_africa_pay_flutter/remita_adapter.dart';

enum PaymentProvider {
  flutterwave,
  monnify,
  paystack,
  remita,
}

class MyPackage {
  static AdapterInterface create(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.flutterwave:
        return FlutterwaveAdapter();
      case PaymentProvider.monnify:
        return MonnifyAdapter();
      case PaymentProvider.paystack:
        return PaystackAdapter();
      case PaymentProvider.remita:
        return RemitaAdapter();
    }
  }
}
