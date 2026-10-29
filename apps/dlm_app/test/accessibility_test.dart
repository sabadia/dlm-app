import 'dart:async';

import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/shell/settings_hub.dart';
import 'package:dlm_app/src/shell/shell_state.dart';
import 'package:dlm_app/src/skin_registry.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// A system that reports high contrast.
class _HighContrast implements SystemAppearanceReader {
  @override
  Future<SystemAppearance> read() async =>
      const SystemAppearance(highContrast: true);

  @override
  Stream<SystemAppearance> get changes => const Stream.empty();

  @override
  void dispose() {}
}

/// The automated part of the accessibility pass (docs/accessibility.md): what
/// a screen reader and a keyboard need, checked on the real screens in every
/// skin and both colour schemes. Screen readers themselves are tried by hand
/// (docs/manual-tests.md).
void main() {
  for (final id in skinIds) {
    for (final dark in [false, true]) {
      final name = '$id ${dark ? 'dark' : 'light'}';

      Future<AppHarness> open(WidgetTester tester) async {
        final h = await pumpApp(
          tester,
          queues: [queue('main', 'Default')],
          tasks: [
            task('a', name: 'ubuntu.iso', engine: 'http', status: 'running'),
            task('b', name: 'movie.mkv', status: 'completed'),
            task('c', name: 'broken.zip', status: 'error'),
          ],
          overrides: [skinProvider.overrideWithValue(skins[id]!)],
        );
        // Real file I/O never completes inside the test's fake-async zone.
        unawaited(
          h.container
              .read(themeChoiceProvider.notifier)
              .set(dark ? ThemeChoice.dark : ThemeChoice.light),
        );
        await settle(tester);
        return h;
      }

      appTest('$name: every tappable on the downloads page has a name', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await open(tester);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
      });

      appTest('$name: text on the downloads page has enough contrast', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await open(tester);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }

  group('text at 200 %', () {
    Future<AppHarness> open200(
      WidgetTester tester, {
      Size size = const Size(1400, 900),
    }) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      return pumpApp(
        tester,
        size: size,
        queues: [queue('main', 'Default')],
        tasks: [
          task('a', name: 'ubuntu-26.04-desktop-amd64.iso', engine: 'http'),
          task('b', name: 'movie.mkv', status: 'completed'),
        ],
      );
    }

    appTest('the scale really is applied, and the downloads page fits', (
      tester,
    ) async {
      await open200(tester);
      final context = tester.element(
        find.text('ubuntu-26.04-desktop-amd64.iso'),
      );
      expect(MediaQuery.textScalerOf(context).scale(10), 20);
    });

    for (final page in ['preferences', 'about', 'categories', 'logins']) {
      appTest('the $page page lays out without overflow', (tester) async {
        final h = await open200(tester);
        h.container.read(routerProvider).go('/manage/$page');
        await settle(tester);
      });
    }

    appTest('the add dialog lays out without overflow', (tester) async {
      final h = await open200(tester);
      h.container.read(addRequestProvider.notifier).request();
      await settle(tester);
    });
  });

  for (final id in skinIds) {
    appTest('$id in high contrast: names and text contrast hold', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        queues: [queue('main', 'Default')],
        tasks: [task('a', name: 'ubuntu.iso', status: 'running')],
        overrides: [
          skinProvider.overrideWithValue(skins[id]!),
          systemAppearanceProvider.overrideWithValue(_HighContrast()),
        ],
      );
      await settle(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }

  group('keyboard only', () {
    appTest('Tab walks through many controls and never loses the focus', (
      tester,
    ) async {
      await pumpApp(
        tester,
        queues: [queue('main', 'Default')],
        tasks: [
          task('a', name: 'one.iso'),
          task('b', name: 'two.iso'),
        ],
      );
      final seen = <FocusNode>{};
      for (var i = 0; i < 80; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focus = FocusManager.instance.primaryFocus;
        expect(focus, isNotNull, reason: 'focus was lost at step $i');
        seen.add(focus!);
      }
      expect(seen.length, greaterThanOrEqualTo(12));
    });

    appTest('the gear menu and the settings window work from the keyboard', (
      tester,
    ) async {
      await pumpApp(tester, queues: [queue('main', 'Default')]);
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is DlmMenuButton &&
              w.semanticLabel == 'Tools, manage and settings',
        ),
      );
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(find.byType(SettingsHub), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.byType(SettingsHub), findsNothing);
    });
  });

  group('a narrow window with larger text', () {
    for (final page in ['preferences', 'about', 'categories']) {
      appTest('the $page page at 900 px and 150 %', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final h = await pumpApp(tester, size: const Size(900, 700));
        h.container.read(routerProvider).go('/manage/$page');
        await settle(tester);
      });
    }
  });
}
