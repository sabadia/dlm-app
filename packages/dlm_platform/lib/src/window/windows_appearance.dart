import 'dart:async';
import 'dart:ui' show Brightness, Color;

import 'package:win32_registry/win32_registry.dart';

import 'system_appearance.dart';

/// Reads values of the current user's registry, behind an interface so the
/// reader is tested without Windows.
abstract interface class UserRegistry {
  /// The integer (DWORD) at [path] named [name], or null.
  int? readInt(String path, String name);

  /// The string at [path] named [name], or null.
  String? readString(String path, String name);
}

/// [UserRegistry] over the Windows registry (HKCU).
class Win32UserRegistry implements UserRegistry {
  /// Creates the registry access.
  const Win32UserRegistry();

  T? _with<T>(String path, T? Function(RegistryKey key) read) {
    RegistryKey? root;
    RegistryKey? key;
    try {
      root = RegistryKey.openCurrentUser();
      key = root.open(path);
      return read(key);
    } on Object {
      // A missing key or value simply means the setting is not present.
      return null;
    } finally {
      key?.close();
      root?.close();
    }
  }

  @override
  int? readInt(String path, String name) => _with(path, (k) => k.getInt(name));

  @override
  String? readString(String path, String name) =>
      _with(path, (k) => k.getString(name));
}

/// Reads the accent colour, colour scheme, transparency, high-contrast and
/// animation settings from the registry (the values behind Windows' Settings
/// pages) and polls for changes: a registry change notification would need a
/// native thread for little gain.
class WindowsAppearanceReader implements SystemAppearanceReader {
  /// Creates a reader; tests pass a fake [registry] and a short [interval].
  WindowsAppearanceReader({
    UserRegistry registry = const Win32UserRegistry(),
    this.interval = const Duration(seconds: 3),
  }) : _registry = registry;

  /// How often the registry is re-read for changes.
  final Duration interval;
  final UserRegistry _registry;
  final StreamController<SystemAppearance> _changes =
      StreamController<SystemAppearance>.broadcast();
  Timer? _timer;
  SystemAppearance? _last;

  static const _dwm = r'Software\Microsoft\Windows\DWM';
  static const _personalize =
      r'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';
  static const _highContrast = r'Control Panel\Accessibility\HighContrast';
  static const _desktop = r'Control Panel\Desktop\WindowMetrics';

  /// The appearance as the registry has it right now.
  SystemAppearance snapshot() {
    // AccentColor is ABGR in a DWORD.
    final abgr = _registry.readInt(_dwm, 'AccentColor');
    Color? accent;
    if (abgr != null) {
      accent = Color.fromARGB(
        255,
        abgr & 0xFF,
        (abgr >> 8) & 0xFF,
        (abgr >> 16) & 0xFF,
      );
    }
    final apps = _registry.readInt(_personalize, 'AppsUseLightTheme');
    final transparency = _registry.readInt(_personalize, 'EnableTransparency');
    // HCF_HIGHCONTRASTON is bit 0 of the Flags string.
    final flags = int.tryParse(
      _registry.readString(_highContrast, 'Flags') ?? '',
    );
    final minAnimate = _registry.readString(_desktop, 'MinAnimate');
    return SystemAppearance(
      accent: accent,
      brightness: apps == null
          ? null
          : (apps == 0 ? Brightness.dark : Brightness.light),
      highContrast: flags != null && flags & 1 == 1,
      reduceMotion: minAnimate == '0',
      reduceTransparency: transparency == 0,
    );
  }

  @override
  Future<SystemAppearance> read() async {
    _startPolling();
    final now = snapshot();
    _last = now;
    return now;
  }

  void _startPolling() {
    _timer ??= Timer.periodic(interval, (_) {
      final now = snapshot();
      if (now != _last && !_changes.isClosed) {
        _last = now;
        _changes.add(now);
      }
    });
  }

  @override
  Stream<SystemAppearance> get changes {
    _startPolling();
    return _changes.stream;
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_changes.close());
  }
}
