import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// The backdrop effect drawn behind a region of the window.
enum WindowEffect {
  /// None: the window is opaque.
  none,

  /// Blurred, tinted backdrop (NSVisualEffectView on macOS).
  vibrancy,

  /// The macOS 26 glass effect.
  glass,
}

/// How the window frame and backdrop should look.
class WindowChromeConfig {
  /// Creates a configuration.
  const WindowChromeConfig({
    this.transparentTitleBar = false,
    this.effect = WindowEffect.none,
    this.brightness,
  });

  /// Content extends under a transparent title bar (traffic lights float).
  final bool transparentTitleBar;

  /// The backdrop effect to request.
  final WindowEffect effect;

  /// Forces the window (and so the effect) light or dark; null follows the
  /// system.
  final Brightness? brightness;
}

/// What the window can do.
class WindowChromeCapabilities {
  /// Creates the capabilities.
  const WindowChromeCapabilities({this.vibrancy = false, this.glass = false});

  /// Nothing is supported.
  static const WindowChromeCapabilities none = WindowChromeCapabilities();

  /// A blurred backdrop is available.
  final bool vibrancy;

  /// The glass backdrop is available.
  final bool glass;
}

/// What was actually applied, which can be less than requested: the app
/// switches its materials to opaque when [effect] is [WindowEffect.none].
class WindowChromeResult {
  /// Creates a result.
  const WindowChromeResult({
    required this.transparentTitleBar,
    required this.effect,
  });

  /// Nothing applied.
  static const WindowChromeResult none = WindowChromeResult(
    transparentTitleBar: false,
    effect: WindowEffect.none,
  );

  /// Whether the title bar is transparent.
  final bool transparentTitleBar;

  /// The backdrop effect in force.
  final WindowEffect effect;

  @override
  bool operator ==(Object other) =>
      other is WindowChromeResult &&
      other.transparentTitleBar == transparentTitleBar &&
      other.effect == effect;

  @override
  int get hashCode => Object.hash(transparentTitleBar, effect);
}

/// The window's native chrome, behind an interface so the UI never touches a
/// native API or a third-party window package.
abstract interface class WindowChrome {
  /// What this window supports.
  Future<WindowChromeCapabilities> capabilities();

  /// Applies [config]; call after the first frame, when the window exists.
  /// Returns what is in force (never more than requested or supported).
  Future<WindowChromeResult> apply(WindowChromeConfig config);

  /// Restricts the backdrop effect to [region] (logical pixels, top-left
  /// origin, in the window's content area); null covers the whole window.
  Future<void> setBackdropRegion(Rect? region);
}

/// The window chrome of platforms without native effects, and of tests.
class UnsupportedWindowChrome implements WindowChrome {
  /// Creates the no-op chrome.
  const UnsupportedWindowChrome();

  @override
  Future<WindowChromeCapabilities> capabilities() async =>
      WindowChromeCapabilities.none;

  @override
  Future<WindowChromeResult> apply(WindowChromeConfig config) async =>
      WindowChromeResult.none;

  @override
  Future<void> setBackdropRegion(Rect? region) async {}
}

/// Thrown when the native side rejects a request (for example the window is
/// not ready yet).
class WindowChromeException implements Exception {
  /// Creates the exception.
  const WindowChromeException(this.code, this.message);

  /// The native error code.
  final String code;

  /// The native message.
  final String? message;

  @override
  String toString() => 'WindowChromeException($code: $message)';
}

/// The macOS implementation, talking to `DlmPlatformPlugin` (Swift).
class MethodChannelWindowChrome implements WindowChrome {
  /// Creates the channel-backed chrome; tests pass their own [channel].
  MethodChannelWindowChrome({
    MethodChannel channel = const MethodChannel('dlm/window_chrome'),
  }) : _channel = channel;

  final MethodChannel _channel;

  Future<T?> _call<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw WindowChromeException(e.code, e.message);
    }
  }

  @override
  Future<WindowChromeCapabilities> capabilities() async {
    try {
      final map = await _call<Map<Object?, Object?>>('capabilities');
      return WindowChromeCapabilities(
        vibrancy: map?['vibrancy'] == true,
        glass: map?['glass'] == true,
      );
    } on MissingPluginException {
      return WindowChromeCapabilities.none;
    }
  }

  @override
  Future<WindowChromeResult> apply(WindowChromeConfig config) async {
    try {
      final map = await _call<Map<Object?, Object?>>('apply', {
        'transparentTitleBar': config.transparentTitleBar,
        'effect': config.effect.name,
        'brightness': config.brightness?.name,
      });
      return WindowChromeResult(
        transparentTitleBar: map?['transparentTitleBar'] == true,
        effect: WindowEffect.values.firstWhere(
          (e) => e.name == map?['effect'],
          orElse: () => WindowEffect.none,
        ),
      );
    } on MissingPluginException {
      return WindowChromeResult.none;
    }
  }

  @override
  Future<void> setBackdropRegion(Rect? region) async {
    try {
      await _call<void>(
        'region',
        region == null
            ? null
            : {
                'x': region.left,
                'y': region.top,
                'width': region.width,
                'height': region.height,
              },
      );
    } on MissingPluginException {
      // No native window effect on this platform.
    }
  }
}

/// The window chrome of the running platform.
WindowChrome platformWindowChrome() => Platform.isMacOS
    ? MethodChannelWindowChrome()
    : const UnsupportedWindowChrome();
