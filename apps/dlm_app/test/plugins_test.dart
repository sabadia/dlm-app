import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/plugins_screen.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

final _on = Plugin(
  enabled: true,
  installedAt: DateTime.utc(2026),
  name: 'mega',
  source: '/plugins/mega',
  updatedAt: DateTime.utc(2026),
  version: '1.2.0',
  title: 'Mega resolver',
  description: 'Resolves mega links',
  hooks: const ['resolve', 'refresh'],
  net: const ['mega.nz'],
);
final _off = Plugin(
  enabled: false,
  installedAt: DateTime.utc(2026),
  name: 'broken',
  source: '/plugins/broken',
  updatedAt: DateTime.utc(2026),
  version: '0.0.1',
  error: 'script threw: oops',
  hooks: const [],
);

Finder switchOf(String label) =>
    find.byWidgetPredicate((w) => w is DlmSwitch && w.semanticLabel == label);

void main() {
  Future<AppHarness> open(
    WidgetTester tester, {
    List<Plugin> plugins = const [],
    List<Record> records = const [],
  }) async {
    final h = await pumpApp(
      tester,
      overrides: [
        pluginsProvider.overrideWith(
          () => FakePlugins(plugins, records: records),
        ),
      ],
    );
    h.container.read(routerProvider).go('/manage/plugins');
    await settle(tester);
    return h;
  }

  FakePlugins fake(AppHarness h) =>
      h.container.read(pluginsProvider.notifier) as FakePlugins;

  appTest('the list shows each plugin with its version and any error', (
    tester,
  ) async {
    await open(tester, plugins: [_on, _off]);
    expect(find.text('Mega resolver  1.2.0'), findsOneWidget);
    expect(find.text('Resolves mega links'), findsOneWidget);
    expect(find.text('script threw: oops'), findsOneWidget);
  });

  appTest('a new plugin is installed off and reviewed before it runs', (
    tester,
  ) async {
    final h = await open(tester);
    expect(find.text('No plugins installed'), findsOneWidget);
    await tester.tap(find.text('Install a plugin').first);
    await settle(tester);
    expect(
      tester
          .widget<DlmButton>(find.widgetWithText(DlmButton, 'Install'))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find
          .descendant(
            of: find.byType(InstallPluginDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmTextField && w.semanticLabel == 'Where from',
            ),
          )
          .first,
      'https://github.com/x/fresh',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Install'));
    await settle(tester);
    expect(
      fake(h).calls.single,
      'install https://github.com/x/fresh null null true',
    );
    // The review lists what it may do.
    expect(find.text('What Fresh plugin may do'), findsOneWidget);
    expect(find.text('download.completed'), findsOneWidget);
    expect(find.text('api.example.com'), findsOneWidget);
    expect(
      find.textContaining('Only switch on plugins you trust'),
      findsOneWidget,
    );
    // Keeping it off leaves it off.
    await tester.tap(find.text('Keep it off'));
    await settle(tester);
    expect(fake(h).calls, hasLength(1));
  });

  appTest('the review can switch the plugin on', (tester) async {
    final h = await open(tester);
    await tester.tap(find.text('Install a plugin').first);
    await settle(tester);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(InstallPluginDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmTextField && w.semanticLabel == 'Where from',
            ),
          )
          .first,
      '/plugins/fresh',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Install'));
    await settle(tester);
    await tester.tap(find.text('Switch it on'));
    await settle(tester);
    expect(fake(h).calls.last, 'enabled fresh true');
  });

  appTest('switching a plugin on shows its permissions first', (tester) async {
    final h = await open(tester, plugins: [_off]);
    await tester.tap(switchOf('Run broken'));
    await settle(tester);
    expect(find.text('What broken may do'), findsOneWidget);
    expect(fake(h).calls, isEmpty, reason: 'nothing granted yet');
    await tester.tap(find.text('Switch it on'));
    await settle(tester);
    expect(fake(h).calls.single, 'enabled broken true');
  });

  appTest('switching a plugin off needs no review', (tester) async {
    final h = await open(tester, plugins: [_on]);
    await tester.tap(switchOf('Run Mega resolver'));
    await settle(tester);
    expect(fake(h).calls.single, 'enabled mega false');
  });

  appTest('the permissions of a running plugin can be read', (tester) async {
    await open(tester, plugins: [_on]);
    await tester.tap(find.text('Permissions'));
    await settle(tester);
    expect(find.text('mega.nz'), findsOneWidget);
    expect(find.text('resolve'), findsOneWidget);
    expect(find.text('Switch it on'), findsNothing);
  });

  appTest('the log shows records and can be filtered by level', (tester) async {
    final h = await open(
      tester,
      plugins: [_on],
      records: [
        Record(
          id: 1,
          level: RecordLevel.info,
          message: 'started',
          time: DateTime.utc(2026, 5, 4, 10),
        ),
        Record(
          id: 2,
          level: RecordLevel.error,
          message: 'hook failed',
          time: DateTime.utc(2026, 5, 4, 11),
          attrs: const {'hook': 'resolve'},
        ),
      ],
    );
    await tester.tap(find.text('Log'));
    await settle(tester);
    expect(find.textContaining('started'), findsOneWidget);
    expect(find.textContaining('hook failed'), findsOneWidget);
    expect(find.textContaining('hook=resolve'), findsOneWidget);
    expect(fake(h).calls.last, 'logs mega null null');
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmDropdown && w.semanticLabel == 'Level',
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Errors only'));
    await settle(tester);
    expect(fake(h).calls.last, 'logs mega error null');
  });

  appTest('removing asks first', (tester) async {
    final h = await open(tester, plugins: [_on]);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmIconButton && w.semanticLabel == 'Remove Mega resolver',
      ),
    );
    await settle(tester);
    expect(find.text('Remove Mega resolver?'), findsOneWidget);
    await tester.tap(find.text('Remove plugin'));
    await settle(tester);
    expect(fake(h).calls.single, 'remove mega');
  });
}
