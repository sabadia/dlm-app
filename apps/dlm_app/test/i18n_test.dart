import 'dart:async';

import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/manage_screen.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// The pseudo-locale (`en_XA`) turns every message into `[Àccéñtéd tèxt~~~]`,
/// a third longer. A message that is still plain English was not read from the
/// ARB file, and a layout that cannot take the longer text overflows, which
/// fails the test.
void main() {
  Future<AppHarness> openPseudo(WidgetTester tester) async {
    final h = await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      tasks: [
        task('a', name: 'one.iso', engine: 'http', status: 'running'),
        task('b', name: 'two.iso', status: 'completed'),
      ],
    );
    // Real file I/O never completes inside the test's fake-async zone.
    unawaited(h.container.read(languageProvider.notifier).set('en_XA'));
    await settle(tester);
    return h;
  }

  appTest('the shell and the downloads list show pseudo-text and fit', (
    tester,
  ) async {
    await openPseudo(tester);
    expect(find.textContaining('[Âll'), findsWidgets, reason: 'sidebar entry');
    expect(find.text('All downloads'), findsNothing);
    expect(find.textContaining('~'), findsWidgets);
  });

  for (final page in ['preferences', 'about', 'categories', 'logins']) {
    appTest('the $page page fits its longer text', (tester) async {
      final h = await openPseudo(tester);
      h.container.read(routerProvider).go('/manage/$page');
      await settle(tester);
      expect(find.byType(ManageScreen), findsOneWidget);
      expect(find.textContaining('~'), findsWidgets);
    });
  }

  appTest('a language that is only for testing is not offered', (tester) async {
    final h = await pumpApp(tester);
    h.container.read(routerProvider).go('/manage/preferences');
    await settle(tester);
    expect(find.text('en_XA'), findsNothing);
    expect(localeOfCode('en_XA'), const Locale('en', 'XA'));
    expect(localeOfCode('de'), const Locale('de'));
  });
}
