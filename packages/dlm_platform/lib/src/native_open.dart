import 'dart:async';

import 'package:flutter/services.dart';

/// Files and URLs the system hands the already-running app.
///
/// macOS sends an Apple event instead of starting a second process. Linux and
/// Windows start a second process, which the instance endpoint hands off, so a
/// missing channel is normal there.
class NativeOpenEvents {
  /// Creates the listener. [channel] exists for tests.
  NativeOpenEvents({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('dlm/open_targets');

  final MethodChannel _channel;
  final StreamController<List<String>> _events =
      StreamController<List<String>>();

  /// The raw arguments, in the order the system delivered them. Buffered until
  /// someone listens, so a URL that arrived during launch is not lost.
  Stream<List<String>> get events => _events.stream;

  /// Starts listening and emits anything already waiting.
  Future<void> start() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'opened') _add(call.arguments);
    });
    try {
      _add(await _channel.invokeMethod<Object?>('pending'));
    } on MissingPluginException {
      // No native handler on this system.
    } on PlatformException {
      // The handler was not ready. Later events still arrive.
    }
  }

  void _add(Object? raw) {
    if (raw is! List || _events.isClosed) return;
    final items = [
      for (final v in raw)
        if (v is String && v.isNotEmpty) v,
    ];
    if (items.isNotEmpty) _events.add(items);
  }

  /// Stops listening.
  Future<void> close() => _events.close();
}
