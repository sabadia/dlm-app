import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One in-app shortcut. Global hotkeys are a later decision (F5.7).
class AppShortcut {
  /// Creates a chord.
  const AppShortcut({
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

  /// Meta / Command is held.
  final bool meta;

  /// The Flutter binding.
  SingleActivator activator() => SingleActivator(
    key,
    control: control,
    alt: alt,
    shift: shift,
    meta: meta,
  );

  /// Whether [other] is the same chord.
  bool sameAs(AppShortcut other) =>
      key == other.key &&
      control == other.control &&
      alt == other.alt &&
      shift == other.shift &&
      meta == other.meta;

  /// Stored form: modifiers, then the key id.
  String encode() => [
    if (control) 'ctrl',
    if (alt) 'alt',
    if (shift) 'shift',
    if (meta) 'meta',
    '${key.keyId}',
  ].join('+');

  /// Reads a stored chord. `primary` is Command on a Mac and Control elsewhere.
  static AppShortcut? decode(String raw, {required bool primaryIsMeta}) {
    final parts = raw.split('+');
    if (parts.isEmpty) return null;
    final id = int.tryParse(parts.last);
    if (id == null) return null;
    final key = LogicalKeyboardKey.findKeyByKeyId(id) ?? LogicalKeyboardKey(id);
    var control = false;
    var alt = false;
    var shift = false;
    var meta = false;
    for (final part in parts.take(parts.length - 1)) {
      switch (part) {
        case 'ctrl':
          control = true;
        case 'alt':
          alt = true;
        case 'shift':
          shift = true;
        case 'meta':
          meta = true;
        case 'primary':
          if (primaryIsMeta) {
            meta = true;
          } else {
            control = true;
          }
        default:
          return null;
      }
    }
    return AppShortcut(
      key: key,
      control: control,
      alt: alt,
      shift: shift,
      meta: meta,
    );
  }

  /// How the palette prints the chord.
  String label({required bool mac}) {
    final mods = [
      if (control && mac) '⌃',
      if (control && !mac) 'Ctrl',
      if (alt && mac) '⌥',
      if (alt && !mac) 'Alt',
      if (shift && mac) '⇧',
      if (shift && !mac) 'Shift',
      if (meta && mac) '⌘',
      if (meta && !mac) 'Win',
    ];
    final text = key.keyLabel.isEmpty ? 'key' : key.keyLabel;
    return mac ? '${mods.join()}$text' : [...mods, text].join('+');
  }
}

/// Built-in chords. `primary` follows the platform. An override replaces one.
final Map<String, String> defaultShortcutCodes = {
  'download.add': 'primary+${LogicalKeyboardKey.keyN.keyId}',
  'window.focusSearch': 'primary+${LogicalKeyboardKey.keyF.keyId}',
  'window.commandPalette': 'primary+${LogicalKeyboardKey.keyK.keyId}',
};

/// The chords in force: overrides on top of [defaultShortcutCodes].
Map<String, AppShortcut> effectiveShortcuts(
  Map<String, String> stored, {
  required bool primaryIsMeta,
}) {
  final codes = {...defaultShortcutCodes, ...stored};
  return {
    for (final e in codes.entries)
      if (AppShortcut.decode(e.value, primaryIsMeta: primaryIsMeta)
          case final shortcut?)
        e.key: shortcut,
  };
}

/// The other command that already uses [code], or null when it is free.
String? shortcutConflict(
  Map<String, String> stored,
  String id,
  String code, {
  required bool primaryIsMeta,
}) {
  final candidate = AppShortcut.decode(code, primaryIsMeta: primaryIsMeta);
  if (candidate == null) return null;
  final all = effectiveShortcuts({
    ...stored,
    id: code,
  }, primaryIsMeta: primaryIsMeta);
  for (final e in all.entries) {
    if (e.key != id && e.value.sameAs(candidate)) return e.key;
  }
  return null;
}
