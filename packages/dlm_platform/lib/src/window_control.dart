import 'dart:async';

import 'package:flutter/services.dart';
import 'package:screen_retriever/screen_retriever.dart';
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

  /// Whether the window is showing now.
  Future<bool> isVisible();

  /// Closes the window for good, which ends the app.
  Future<void> quit();

  /// Dock or taskbar progress. Below 0 clears it. Above 1 is indeterminate.
  /// A value from 0 to 1 is a fraction.
  Future<void> setProgress(double progress);

  /// The dock badge. Empty clears it. macOS only; other systems ignore it.
  Future<void> setBadge(String label);

  /// The window's frame, or null when this system has no window to measure.
  Future<({double x, double y, double width, double height, bool maximized})?>
  readFrame();

  /// Moves and sizes the window. [maximized] is applied after the frame, so a
  /// maximised window comes back on the display it belonged to.
  Future<void> place({
    required double x,
    required double y,
    required double width,
    required double height,
    required bool maximized,
  });

  /// Fires after the user moves, resizes or maximises the window.
  Stream<void> get frameChanged;

  /// The displays, in logical pixels. Empty when they cannot be read.
  Future<List<Rect>> displays();
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
  Future<bool> isVisible() async => false;

  @override
  Future<void> quit() async {}

  @override
  Future<void> setProgress(double progress) async {}

  @override
  Future<void> setBadge(String label) async {}

  @override
  Future<({double x, double y, double width, double height, bool maximized})?>
  readFrame() async => null;

  @override
  Future<void> place({
    required double x,
    required double y,
    required double width,
    required double height,
    required bool maximized,
  }) async {}

  @override
  Stream<void> get frameChanged => const Stream.empty();

  @override
  Future<List<Rect>> displays() async => const [];
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
  final StreamController<void> _frames = StreamController.broadcast();

  @override
  Stream<void> get closeRequests => _requests.stream;

  @override
  Stream<void> get frameChanged => _frames.stream;

  @override
  void onWindowClose() => _requests.add(null);

  @override
  void onWindowMoved() => _frames.add(null);

  @override
  void onWindowResized() => _frames.add(null);

  @override
  void onWindowMaximize() => _frames.add(null);

  @override
  void onWindowUnmaximize() => _frames.add(null);

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
  Future<bool> isVisible() => windowManager.isVisible();

  @override
  Future<void> quit() async {
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  @override
  Future<void> setProgress(double progress) =>
      windowManager.setProgressBar(progress);

  @override
  Future<void> setBadge(String label) async {
    try {
      await windowManager.setBadgeLabel(label);
    } on MissingPluginException {
      // The dock badge is macOS. Windows and Linux use the progress bar.
    }
  }

  @override
  Future<({double x, double y, double width, double height, bool maximized})?>
  readFrame() async {
    try {
      final bounds = await windowManager.getBounds();
      final maximized = await windowManager.isMaximized();
      return (
        x: bounds.left,
        y: bounds.top,
        width: bounds.width,
        height: bounds.height,
        maximized: maximized,
      );
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> place({
    required double x,
    required double y,
    required double width,
    required double height,
    required bool maximized,
  }) async {
    await windowManager.setBounds(Rect.fromLTWH(x, y, width, height));
    if (maximized) {
      await windowManager.maximize();
    } else if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    }
  }

  @override
  Future<List<Rect>> displays() async {
    try {
      final found = await screenRetriever.getAllDisplays();
      return [
        for (final display in found)
          Rect.fromLTWH(
            display.visiblePosition?.dx ?? 0,
            display.visiblePosition?.dy ?? 0,
            (display.visibleSize ?? display.size).width,
            (display.visibleSize ?? display.size).height,
          ),
      ];
    } on MissingPluginException {
      return const [];
    }
  }
}
