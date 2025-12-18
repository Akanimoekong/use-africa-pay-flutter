import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

Future<void> loadScript(String url) {
  final completer = Completer<void>();
  final script = document.createElement('script') as HTMLScriptElement
    ..src = url
    ..type = 'text/javascript';

  script.onload = (Event event) {
    completer.complete();
  }.toJS;

  script.onerror = (JSAny error) {
    completer.completeError('Failed to load script: $url');
  }.toJS;

  document.head!.appendChild(script);

  return completer.future;
}
