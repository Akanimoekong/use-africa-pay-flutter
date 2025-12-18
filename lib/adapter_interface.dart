import 'dart:js_interop';


import 'adapter_config.dart';

abstract class AdapterInterface {
  Future<void> loadScript({bool testMode = true});
  void initialize(AdapterConfig config);
  JSAny? getInstance();
}
