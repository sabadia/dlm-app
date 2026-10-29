import 'dart:async';

import 'package:window_manager/window_manager.dart';

/// Showing, hiding and closing the one window, and hearing that the user
/// asked to close it.
abstract interface class WindowControl {
  /// Emits each time the user asks to close the window while closing is held
  /// back by [holdClose].
  Stream<void> get closeRequests;

  /// Whether closing the window is held back: it reports on [closeRequests]
  /// and the window stays.
  Future<void> holdClose({required bool hold});

  /// Brings the window forward, showing it if it was hidden.
  Future<void> show();

  /// Hides the window; the app keeps running.
  Future<void> hide();

  /// Closes the window for good, which ends the app.
  Future<void> quit();
}

/// Nothing to control: closing the window just closes it.
class UnsupportedWindowControl implements WindowControl {
  /// Creates the no-op control.
  const UnsupportedWindowControl();

  @override
  Stream<void> get closeRequests => const Stream.empty();

  @override
  Future<void> holdClose({required bool hold}) async {}

  @override
  Future<void> show() async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> quit() async {}
}

/// [WindowControl] over `window_manager`.
class WindowManagerControl with WindowListener implements WindowControl {
  /// Creates the control; call [WindowManagerControl.ensureInitialized] first
  /// in `main`.
  WindowManagerControl() {
    windowManager.addListener(this);
  }

  /// Prepares the plugin; once, before the first window call.
  static Future<void> ensureInitialized() => windowManager.ensureInitialized();

  final StreamController<void> _requests = StreamController.broadcast();

  @override
  Stream<void> get closeRequests => _requests.stream;

  @override
  void onWindowClose() => _requests.add(null);

  @override
  Future<void> holdClose({required bool hold}) =>
      windowManager.setPreventClose(hold);

  @override
  Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  Future<void> hide() => windowManager.hide();

  @override
  Future<void> quit() async {
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
}
