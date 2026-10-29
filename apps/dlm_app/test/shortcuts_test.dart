import 'dart:async';

import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/shell/shortcuts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  test('primary is Control off a Mac and Command on one', () {
    final win = AppShortcut.decode(
      defaultShortcutCodes['download.add']!,
      primaryIsMeta: false,
    )!;
    final mac = AppShortcut.decode(
      defaultShortcutCodes['download.add']!,
      primaryIsMeta: true,
    )!;
    expect(win.control, isTrue);
    expect(win.meta, isFalse);
    expect(win.key, LogicalKeyboardKey.keyN);
    expect(mac.meta, isTrue);
    expect(mac.control, isFalse);
  });

  test('a chord already used by another command is a conflict', () {
    final code = defaultShortcutCodes['window.focusSearch']!;
    expect(
      shortcutConflict(const {}, 'download.add', code, primaryIsMeta: false),
      'window.focusSearch',
    );
    final own = defaultShortcutCodes['download.add']!;
    expect(
      shortcutConflict(const {}, 'download.add', own, primaryIsMeta: false),
      isNull,
    );
  });

  test('an empty override keeps the built-in chords', () {
    final chords = effectiveShortcuts(const {}, primaryIsMeta: false);
    expect(chords['window.commandPalette']?.key, LogicalKeyboardKey.keyK);
  });

  appTest('the built-in chord still adds a download', (tester) async {
    await pumpApp(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
    expect(find.text('Add downloads'), findsWidgets);
  });

  appTest('a stored chord replaces the built-in one', (tester) async {
    final h = await pumpApp(tester);
    const chord = AppShortcut(key: LogicalKeyboardKey.keyG, control: true);
    final stored = chord.encode();
    unawaited(
      h.container.read(shortcutsProvider.notifier).set({
        'download.add': stored,
      }),
    );
    await settle(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
    expect(find.text('Add downloads'), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
    expect(find.text('Add downloads'), findsWidgets);
  });
}
