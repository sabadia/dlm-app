import 'dart:async';
import 'dart:ui' show Brightness, Color;

import 'package:dbus/dbus.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

import 'system_appearance.dart';

/// The one setting a portal reader needs: read a value, and hear when one
/// changes. Behind an interface so the reader is tested without D-Bus.
abstract interface class PortalSettings {
  /// Reads [key] of [namespace] as plain Dart values (ints, doubles, lists);
  /// null when the portal does not provide it.
  Future<Object?> read(String namespace, String key);

  /// Emits the namespace and key of every setting that changes.
  Stream<({String namespace, String key})> get changed;

  /// Releases the bus connection.
  Future<void> close();
}

/// [PortalSettings] over the session bus (`xdg-desktop-portal`).
class XdgPortalSettings implements PortalSettings {
  /// Creates the adapter; the connection opens on first use.
  XdgPortalSettings();

  XdgDesktopPortalClient? _client;

  XdgDesktopPortalClient get _c => _client ??= XdgDesktopPortalClient();

  @override
  Future<Object?> read(String namespace, String key) async {
    try {
      var value = await _c.settings.read(namespace, key);
      while (value is DBusVariant) {
        value = value.value;
      }
      return value.toNative();
    } on DBusMethodResponseException {
      return null;
    }
  }

  @override
  Stream<({String namespace, String key})> get changed => _c
      .settings
      .settingChanged
      .map((e) => (namespace: e.namespace, key: e.key));

  @override
  Future<void> close() async => _client?.close();
}

/// Reads the colour scheme, accent colour and contrast preference from the
/// `org.freedesktop.appearance` portal namespace (GNOME 42+, KDE, others).
class PortalAppearanceReader implements SystemAppearanceReader {
  /// Creates a reader over [settings].
  PortalAppearanceReader(this._settings);

  static const _namespace = 'org.freedesktop.appearance';

  final PortalSettings _settings;
  final StreamController<SystemAppearance> _changes =
      StreamController<SystemAppearance>.broadcast();
  StreamSubscription<({String namespace, String key})>? _sub;
  SystemAppearance? _last;

  @override
  Future<SystemAppearance> read() async {
    _listen();
    final scheme = await _settings.read(_namespace, 'color-scheme');
    final accent = await _settings.read(_namespace, 'accent-color');
    final contrast = await _settings.read(_namespace, 'contrast');
    final result = SystemAppearance(
      brightness: switch (scheme) {
        1 => Brightness.dark,
        2 => Brightness.light,
        _ => null,
      },
      accent: _color(accent),
      highContrast: contrast == 1,
    );
    _last = result;
    return result;
  }

  /// `accent-color` is three doubles in 0..1; values outside that range mean
  /// "no accent set".
  static Color? _color(Object? value) {
    if (value is! List || value.length < 3) return null;
    final c = value
        .take(3)
        .map((v) => v is num ? v.toDouble() : double.nan)
        .toList();
    if (c.any((v) => v.isNaN || v < 0 || v > 1)) return null;
    int b(double v) => (v * 255).round();
    return Color.fromARGB(255, b(c[0]), b(c[1]), b(c[2]));
  }

  void _listen() {
    if (_sub != null) return;
    _sub = _settings.changed.where((e) => e.namespace == _namespace).listen((
      _,
    ) async {
      final before = _last;
      final now = await read();
      if (now != before && !_changes.isClosed) _changes.add(now);
    });
  }

  @override
  Stream<SystemAppearance> get changes {
    _listen();
    return _changes.stream;
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(_changes.close());
    unawaited(_settings.close());
  }
}
