import 'dart:async';

import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/pref_providers.dart';
import '../shell/shortcuts.dart';

/// The commands whose shortcut the preferences page can change.
const List<String> editableShortcutIds = [
  'download.add',
  'window.focusSearch',
  'window.commandPalette',
];

/// The localised name of a shortcut command.
String shortcutCommandLabel(AppLocalizations l, String id) => switch (id) {
  'download.add' => l.cmd_add,
  'window.focusSearch' => l.command_focus_search,
  'window.commandPalette' => l.toolbar_palette,
  _ => id,
};

bool get _mac => defaultTargetPlatform == TargetPlatform.macOS;

/// One shortcut row: the chord, a button that records the next key, and a
/// conflict when that chord is already taken.
class ShortcutEditor extends ConsumerStatefulWidget {
  /// Creates the editor.
  const ShortcutEditor({super.key});

  @override
  ConsumerState<ShortcutEditor> createState() => _ShortcutEditorState();
}

class _ShortcutEditorState extends ConsumerState<ShortcutEditor> {
  String? _listening;
  String? _problem;

  bool _modifier(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.controlLeft ||
      key == LogicalKeyboardKey.controlRight ||
      key == LogicalKeyboardKey.altLeft ||
      key == LogicalKeyboardKey.altRight ||
      key == LogicalKeyboardKey.shiftLeft ||
      key == LogicalKeyboardKey.shiftRight ||
      key == LogicalKeyboardKey.metaLeft ||
      key == LogicalKeyboardKey.metaRight;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final id = _listening;
    if (id == null || event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _listening = null);
      return KeyEventResult.handled;
    }
    if (_modifier(event.logicalKey)) return KeyEventResult.handled;
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    bool held(LogicalKeyboardKey a, LogicalKeyboardKey b) =>
        pressed.contains(a) || pressed.contains(b);
    final chord = AppShortcut(
      key: event.logicalKey,
      control: held(
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.controlRight,
      ),
      alt: held(LogicalKeyboardKey.altLeft, LogicalKeyboardKey.altRight),
      shift: held(LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.shiftRight),
      meta: held(LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.metaRight),
    );
    final stored = ref.read(shortcutsProvider);
    final other = shortcutConflict(
      stored,
      id,
      chord.encode(),
      primaryIsMeta: _mac,
    );
    if (other != null) {
      final l = AppLocalizations.of(context);
      setState(() {
        _problem = l.pref_shortcuts_conflict(shortcutCommandLabel(l, other));
      });
      return KeyEventResult.handled;
    }
    setState(() {
      _listening = null;
      _problem = null;
    });
    unawaited(
      ref.read(shortcutsProvider.notifier).set({...stored, id: chord.encode()}),
    );
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final chords = effectiveShortcuts(
      ref.watch(shortcutsProvider),
      primaryIsMeta: _mac,
    );
    return Focus(
      autofocus: _listening != null,
      onKeyEvent: _onKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final id in editableShortcutIds)
            DlmFormRow(
              label: shortcutCommandLabel(l, id),
              description: _listening == id ? l.pref_shortcuts_press : null,
              control: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chords[id]?.label(mac: _mac) ?? ''),
                  SizedBox(width: theme.metrics.spacing.sm),
                  DlmButton(
                    label: l.pref_shortcuts_change,
                    variant: DlmButtonVariant.plain,
                    onPressed: () => setState(() {
                      _listening = id;
                      _problem = null;
                    }),
                  ),
                ],
              ),
            ),
          if (_problem != null)
            Text(
              _problem!,
              style: theme.typography.caption.copyWith(
                color: theme.colors.danger,
              ),
            ),
          SizedBox(height: theme.metrics.spacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.pref_shortcuts_reset,
              variant: DlmButtonVariant.plain,
              onPressed: () {
                setState(() {
                  _listening = null;
                  _problem = null;
                });
                unawaited(ref.read(shortcutsProvider.notifier).set(const {}));
              },
            ),
          ),
        ],
      ),
    );
  }
}
