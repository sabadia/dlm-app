import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/preferences_screen.dart';
import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_app/src/skin_registry.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

void main() {
  Future<AppHarness> open(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    final h = await pumpApp(tester, overrides: overrides);
    h.container.read(routerProvider).go('/manage/preferences');
    await settle(tester);
    return h;
  }

  Finder dropdown(String label) => find.byWidgetPredicate(
    (w) => w is DlmDropdown && w.semanticLabel == label,
  );

  appTest('the theme is chosen and remembered', (tester) async {
    final h = await open(tester);
    expect(h.container.read(themeChoiceProvider), ThemeChoice.system);
    await tester.tap(find.text('Dark'));
    await settle(tester);
    expect(h.container.read(themeChoiceProvider), ThemeChoice.dark);
    await tester.tap(find.text('Light'));
    await settle(tester);
    expect(h.container.read(themeChoiceProvider), ThemeChoice.light);
  });

  appTest('an accent colour can be chosen and cleared', (tester) async {
    final h = await open(tester);
    expect(h.container.read(accentProvider), isNull);
    await tester.tap(dropdown('Accent colour'));
    await settle(tester);
    await tester.tap(find.text('Green').last);
    await settle(tester);
    expect(h.container.read(accentProvider), accentChoices['green']);
    await tester.tap(dropdown('Accent colour'));
    await settle(tester);
    await tester.tap(find.text("The system's").last);
    await settle(tester);
    expect(h.container.read(accentProvider), isNull);
  });

  appTest('the look and feel can be forced to another skin', (tester) async {
    final h = await open(tester);
    expect(h.container.read(skinOverrideProvider), isNull);
    await tester.tap(dropdown('Look and feel'));
    await settle(tester);
    await tester.tap(find.text('KDE (Breeze)').last);
    await settle(tester);
    expect(h.container.read(skinOverrideProvider), 'breeze');
    expect(skinIds, contains('breeze'));
  });

  appTest('the row height is changed here as in the display menu', (
    tester,
  ) async {
    final h = await open(tester);
    await tester.tap(find.text('Compact').last);
    await settle(tester);
    expect(h.container.read(densityProvider), Density.compact);
  });

  appTest('asking before deleting can be switched off', (tester) async {
    final h = await open(tester);
    expect(h.container.read(confirmDeleteProvider), isTrue);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is DlmSwitch &&
            w.semanticLabel == 'Ask before deleting downloads',
      ),
    );
    await settle(tester);
    expect(h.container.read(confirmDeleteProvider), isFalse);
  });

  Finder toggle(String label) =>
      find.byWidgetPredicate((w) => w is DlmSwitch && w.semanticLabel == label);

  appTest('start at login is turned on and off through the login item', (
    tester,
  ) async {
    final item = FakeLoginItem();
    await open(tester, overrides: [loginItemProvider.overrideWithValue(item)]);
    expect(item.enabled, isFalse);
    await tester.tap(toggle('Start when I log in'));
    await settle(tester);
    expect(item.enabled, isTrue);
    await tester.tap(toggle('Start when I log in'));
    await settle(tester);
    expect(item.enabled, isFalse);
  });

  appTest('a refused login item shows the failure and stays off', (
    tester,
  ) async {
    final item = FakeLoginItem(refuse: true);
    await open(tester, overrides: [loginItemProvider.overrideWithValue(item)]);
    await tester.tap(toggle('Start when I log in'));
    await settle(tester);
    expect(item.enabled, isFalse);
    final sw = tester.widget<DlmSwitch>(toggle('Start when I log in'));
    expect(sw.value, isFalse);
  });

  appTest('start hidden is remembered', (tester) async {
    final h = await open(tester);
    await tester.tap(toggle('Start hidden'));
    await settle(tester);
    expect(h.container.read(startMinimisedProvider), isTrue);
  });

  appTest('the daemon login item only shows when a daemon binary exists', (
    tester,
  ) async {
    await open(tester);
    expect(toggle('Keep downloading without the app'), findsNothing);
  });

  appTest('the daemon login item installs and removes through dlm service', (
    tester,
  ) async {
    final service = FakeDaemonService();
    await open(
      tester,
      overrides: [daemonServiceProvider.overrideWithValue(service)],
    );
    await tester.tap(toggle('Keep downloading without the app'));
    await settle(tester);
    expect(service.calls, ['status', 'install']);
    await tester.tap(toggle('Keep downloading without the app'));
    await settle(tester);
    expect(service.calls, ['status', 'install', 'uninstall']);
  });
}
