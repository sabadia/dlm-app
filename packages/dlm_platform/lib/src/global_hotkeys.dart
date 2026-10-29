import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// A chord that works while another program has the focus.
class GlobalChord {
  /// Creates a chord.
  const GlobalChord({
    required this.key,
    this.control = false,
    this.alt = false,
    this.shift = false,
    this.meta = false,
  });

  /// The key.
  final LogicalKeyboardKey key;

  /// Control is held.
  final bool control;

  /// Alt / Option is held.
  final bool alt;

  /// Shift is held.
  final bool shift;

  /// Meta / Command / Windows is held.
  final bool meta;

  /// Whether the system accepts a hotkey with no modifier: it does not, since
  /// that would take a plain key from every program.
  bool get hasModifier => control || alt || shift || meta;
}

/// System-wide shortcuts: macOS, Windows and X11. Wayland sessions do not let
/// an app claim keys for the whole desktop, so [supported] is false there.
abstract interface class GlobalHotkeys {
  /// Whether this system lets the app register global hotkeys.
  bool get supported;

  /// Registers [chord] under [id]; false when the system refused it (another
  /// program owns it, or there is no modifier). An earlier chord of [id] is
  /// replaced.
  Future<bool> register(
    String id,
    GlobalChord chord,
    void Function() onPressed,
  );

  /// Drops every registered hotkey.
  Future<void> unregisterAll();
}

/// No global hotkeys here.
class UnsupportedGlobalHotkeys implements GlobalHotkeys {
  /// Creates the no-op registry.
  const UnsupportedGlobalHotkeys();

  @override
  bool get supported => false;

  @override
  Future<bool> register(
    String id,
    GlobalChord chord,
    void Function() onPressed,
  ) async => false;

  @override
  Future<void> unregisterAll() async {}
}

/// [GlobalHotkeys] over `hotkey_manager`.
class HotkeyManagerGlobalHotkeys implements GlobalHotkeys {
  /// Creates the registry. [environment] and [operatingSystem] exist for tests.
  HotkeyManagerGlobalHotkeys({
    Map<String, String>? environment,
    String? operatingSystem,
  }) : _env = environment ?? Platform.environment,
       _os = operatingSystem ?? Platform.operatingSystem;

  final Map<String, String> _env;
  final String _os;

  @override
  bool get supported => switch (_os) {
    'macos' || 'windows' => true,
    'linux' => !_isWayland(_env),
    _ => false,
  };

  /// Whether the session is Wayland (and so has no X11 to grab keys on).
  static bool _isWayland(Map<String, String> env) {
    final type = env['XDG_SESSION_TYPE'];
    if (type != null && type.isNotEmpty) return type == 'wayland';
    return (env['WAYLAND_DISPLAY'] ?? '').isNotEmpty &&
        (env['DISPLAY'] ?? '').isEmpty;
  }

  @override
  Future<bool> register(
    String id,
    GlobalChord chord,
    void Function() onPressed,
  ) async {
    if (!supported || !chord.hasModifier) return false;
    try {
      await hotKeyManager.register(
        HotKey(
          identifier: id,
          key: chord.key,
          modifiers: [
            if (chord.control) HotKeyModifier.control,
            if (chord.alt) HotKeyModifier.alt,
            if (chord.shift) HotKeyModifier.shift,
            if (chord.meta) HotKeyModifier.meta,
          ],
        ),
        keyDownHandler: (_) => onPressed(),
      );
      return true;
    } on Object {
      // The system or another program already owns the chord.
      return false;
    }
  }

  @override
  Future<void> unregisterAll() async {
    try {
      await hotKeyManager.unregisterAll();
    } on Object {
      // Nothing was registered.
    }
  }
}
