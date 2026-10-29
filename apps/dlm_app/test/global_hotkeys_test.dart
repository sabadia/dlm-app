import 'dart:async';

import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/preferences_screen.dart';
import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_app/src/shell/shortcuts.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'integration_binder_test.dart' show RecordingWindow;
import 'support/app_harness.dart';

class FakeHotkeys implements GlobalHotkeys {
  FakeHotkeys({this.supported = true});

  @override
  final bool supported;
  final Map<String, (GlobalChord, void Function())> registered = {};

  @override
  Future<bool> register(
    String id,
    GlobalChord chord,
    void Function() onPressed,
  ) async {
    registered[id] = (chord, onPressed);
    return true;
  }

  @override
  Future<void> unregisterAll() async => registered.clear();
}

void main() {
  Future<AppHarness> open(
    WidgetTester tester,
    FakeHotkeys hotkeys,
    RecordingWindow window, {
    List<Override> extra = const [],
  }) => pumpApp(
    tester,
    overrides: [
      globalHotkeysProvider.overrideWithValue(hotkeys),
      windowControlProvider.overrideWithValue(window),
      ...extra,
    ],
  );

  appTest('a chord set in preferences is registered, and Show/Hide toggles', (
    tester,
  ) async {
    final hotkeys = FakeHotkeys();
    final window = RecordingWindow();
    final h = await open(tester, hotkeys, window);
    expect(hotkeys.registered, isEmpty, reason: 'off until set');
    final code = const AppShortcut(
      key: LogicalKeyboardKey.keyD,
      control: true,
      shift: true,
    ).encode();
    unawaited(
      h.container.read(shortcutsProvider.notifier).set({
        'global.toggleWindow': code,
      }),
    );
    await settle(tester);
    final registered = hotkeys.registered['global.toggleWindow']!;
    expect(registered.$1.key, LogicalKeyboardKey.keyD);
    expect(registered.$1.control && registered.$1.shift, isTrue);
    registered.$2();
    await tester.pump();
    expect(window.hides, 1, reason: 'it was showing');
    registered.$2();
    await tester.pump();
    expect(window.shows, 1, reason: 'it was hidden');
  });

  appTest('add-from-clipboard opens the add request with the links', (
    tester,
  ) async {
    final hotkeys = FakeHotkeys();
    final window = RecordingWindow();
    final h = await open(tester, hotkeys, window);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? {'text': 'see https://a.test/x.iso please\nhttps://b.test/y.zip'}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    unawaited(
      h.container.read(shortcutsProvider.notifier).set({
        'global.addFromClipboard': const AppShortcut(
          key: LogicalKeyboardKey.keyV,
          alt: true,
        ).encode(),
      }),
    );
    await settle(tester);
    final before = h.container.read(addRequestProvider);
    hotkeys.registered['global.addFromClipboard']!.$2();
    await tester.pump();
    await tester.pump();
    expect(window.shows, greaterThanOrEqualTo(1));
    expect(h.container.read(addRequestProvider), before + 1);
  });

  appTest('the preferences list the global shortcuts, unset at first', (
    tester,
  ) async {
    final h = await open(tester, FakeHotkeys(), RecordingWindow());
    h.container.read(routerProvider).go('/manage/preferences');
    await settle(tester);
    await tester.drag(find.byType(PreferencesScreen), const Offset(0, -900));
    await settle(tester);
    expect(find.text('Global shortcuts'), findsOneWidget);
    expect(find.text('Show or hide DLM'), findsOneWidget);
    expect(find.text('Not set'), findsWidgets);
  });

  appTest('where hotkeys are not available, the page says why', (tester) async {
    final h = await open(
      tester,
      FakeHotkeys(supported: false),
      RecordingWindow(),
    );
    h.container.read(routerProvider).go('/manage/preferences');
    await settle(tester);
    await tester.drag(find.byType(PreferencesScreen), const Offset(0, -900));
    await settle(tester);
    expect(find.textContaining('Wayland'), findsOneWidget);
    expect(find.text('Show or hide DLM'), findsNothing);
  });
}
