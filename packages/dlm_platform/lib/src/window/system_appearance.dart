import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// What the operating system reports beyond what Flutter already knows
/// (brightness, text scale): the accent colour and the accessibility display
/// options. Everything is optional; a platform that cannot report a value
/// leaves the default.
class SystemAppearance {
  /// Creates a snapshot.
  const SystemAppearance({
    this.accent,
    this.highContrast = false,
    this.reduceMotion = false,
    this.reduceTransparency = false,
  });

  /// Decodes the map the native side sends.
  factory SystemAppearance.fromMap(Map<Object?, Object?>? map) {
    if (map == null) return none;
    final accent = map['accent'];
    return SystemAppearance(
      accent: accent is int ? Color(accent) : null,
      highContrast: map['highContrast'] == true,
      reduceMotion: map['reduceMotion'] == true,
      reduceTransparency: map['reduceTransparency'] == true,
    );
  }

  /// Nothing reported.
  static const SystemAppearance none = SystemAppearance();

  /// The system accent colour, or null when the OS has none.
  final Color? accent;

  /// Increase-contrast is on.
  final bool highContrast;

  /// Reduce-motion is on.
  final bool reduceMotion;

  /// Reduce-transparency is on.
  final bool reduceTransparency;

  @override
  bool operator ==(Object other) =>
      other is SystemAppearance &&
      other.accent == accent &&
      other.highContrast == highContrast &&
      other.reduceMotion == reduceMotion &&
      other.reduceTransparency == reduceTransparency;

  @override
  int get hashCode =>
      Object.hash(accent, highContrast, reduceMotion, reduceTransparency);
}

/// Reads the system appearance and reports changes.
abstract interface class SystemAppearanceReader {
  /// The appearance now.
  Future<SystemAppearance> read();

  /// Emits whenever the system changes it (broadcast stream).
  Stream<SystemAppearance> get changes;

  /// Releases listeners.
  void dispose();
}

/// Reports nothing and never changes.
class UnsupportedSystemAppearance implements SystemAppearanceReader {
  /// Creates the no-op reader.
  const UnsupportedSystemAppearance();

  @override
  Future<SystemAppearance> read() async => SystemAppearance.none;

  @override
  Stream<SystemAppearance> get changes => const Stream.empty();

  @override
  void dispose() {}
}

/// The macOS reader, backed by `DlmPlatformPlugin`.
class MethodChannelSystemAppearance implements SystemAppearanceReader {
  /// Creates the reader; tests pass their own [channel].
  MethodChannelSystemAppearance({
    MethodChannel channel = const MethodChannel('dlm/system_appearance'),
  }) : _channel = channel;

  final MethodChannel _channel;
  bool _listening = false;

  /// Starts receiving pushed changes. Done on first use, not in the
  /// constructor, so creating the reader before the Flutter binding exists
  /// (in `main`) is safe.
  void _listen() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'changed' && !_changes.isClosed) {
        _changes.add(
          SystemAppearance.fromMap(call.arguments as Map<Object?, Object?>?),
        );
      }
    });
  }

  final StreamController<SystemAppearance> _changes =
      StreamController<SystemAppearance>.broadcast();

  @override
  Future<SystemAppearance> read() async {
    _listen();
    try {
      return SystemAppearance.fromMap(
        await _channel.invokeMethod<Map<Object?, Object?>>('read'),
      );
    } on MissingPluginException {
      return SystemAppearance.none;
    }
  }

  @override
  Stream<SystemAppearance> get changes {
    _listen();
    return _changes.stream;
  }

  @override
  void dispose() {
    if (_listening) _channel.setMethodCallHandler(null);
    unawaited(_changes.close());
  }
}

/// The system appearance reader of the running platform.
SystemAppearanceReader platformSystemAppearance() => Platform.isMacOS
    ? MethodChannelSystemAppearance()
    : const UnsupportedSystemAppearance();
