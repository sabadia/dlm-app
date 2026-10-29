import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

const _levels = ['global', 'queue', 'task'];

const _schema = Schema(
  fields: [
    const FieldSchema(
      description: 'Parallel connections per task',
      group: 'speed',
      path: 'maxConnections',
      type: FieldSchemaType.integer,
      min: 1,
      max: 64,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Speed limit; 0 means unlimited',
      group: 'speed',
      path: 'speedLimit',
      type: FieldSchemaType.integer,
      unit: 'bytes/s',
      min: 0,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'What to do when the target file exists',
      group: 'general',
      path: 'fileExistsPolicy',
      type: FieldSchemaType.string,
      enumValue: ['rename', 'overwrite'],
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Maximum retries',
      group: 'retry',
      path: 'retry.maxAttempts',
      type: FieldSchemaType.integer,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Proxy to use',
      group: 'network',
      path: 'proxy',
      type: FieldSchemaType.object,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Headers sent with every request',
      group: 'network',
      path: 'headers',
      type: FieldSchemaType.object,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Extra tracker announce URLs',
      group: 'torrent',
      path: 'torrent.trackers',
      type: FieldSchemaType.array,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Strategies tried in order',
      group: 'refresh',
      path: 'refresh.strategies',
      type: FieldSchemaType.array,
      enumValue: ['origin-redirect', 'page-reload', 'manual'],
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Actions run after a download completes',
      group: 'post-processing',
      path: 'postActions',
      type: FieldSchemaType.array,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Traffic quota',
      group: 'speed',
      path: 'quota',
      type: FieldSchemaType.object,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Time-of-day speed limits',
      group: 'speed',
      path: 'speedProfiles',
      type: FieldSchemaType.array,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Proxies for some hosts',
      group: 'network',
      path: 'proxyRules',
      type: FieldSchemaType.array,
      levels: _levels,
    ),
    const FieldSchema(
      description: 'Something structured with no editor',
      group: 'speed',
      path: 'schedule',
      type: FieldSchemaType.object,
      levels: _levels,
    ),
  ],
);

void main() {
  editorTests();
  FakeGlobalSettings settings(AppHarness h) =>
      h.container.read(globalSettingsProvider.notifier) as FakeGlobalSettings;

  Future<AppHarness> open(
    WidgetTester tester, {
    String group = 'speed',
    FakeGlobalSettings Function()? make,
  }) async {
    final h = await pumpApp(
      tester,
      overrides: [
        settingsSchemaProvider.overrideWith((ref) async => _schema),
        globalSettingsProvider.overrideWith(
          make ??
              () => FakeGlobalSettings(
                stored: const Settings(speedLimit: 1048576),
                defaults: const Settings(
                  maxConnections: 8,
                  speedLimit: 0,
                  fileExistsPolicy: 'rename',
                ),
              ),
        ),
      ],
    );
    h.container.read(routerProvider).go('/settings/$group');
    await settle(tester);
    return h;
  }

  Finder numberField(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is DlmNumberField && w.semanticLabel == label,
    ),
    matching: find.byType(EditableText),
  );

  Finder save() => find.widgetWithText(DlmButton, 'Save');
  bool canSave(WidgetTester tester) =>
      tester.widget<DlmButton>(save()).onPressed != null;

  appTest('a page lists the fields of its group and where each value comes '
      'from', (tester) async {
    await open(tester);
    expect(find.text('Max connections'), findsOneWidget);
    expect(find.text('Speed limit'), findsOneWidget);
    expect(find.text('Parallel connections per task'), findsOneWidget);
    // maxConnections is the built-in value, speedLimit is set globally.
    expect(
      find.text('Default'),
      findsNWidgets(3),
      reason: 'maxConnections, quota, profiles',
    );
    expect(find.text('Global'), findsOneWidget);
    // Other groups and structured values are not on this page.
    expect(find.text('Retry: max attempts'), findsNothing);
    expect(find.text('Proxy'), findsNothing);
    // A structured setting without an editor is not offered.
    expect(find.text('Schedule'), findsNothing);
    expect(canSave(tester), isFalse);
  });

  appTest('an edit is saved as a merge patch', (tester) async {
    final h = await open(tester);
    await tester.enterText(numberField('Max connections'), '4');
    await tester.pump();
    expect(canSave(tester), isTrue);
    expect(find.text('Unsaved changes'), findsOneWidget);
    await tester.tap(save());
    await settle(tester);
    expect(settings(h).patches, [
      {'maxConnections': 4},
    ]);
    expect(find.text('Settings saved'), findsOneWidget);
    expect(canSave(tester), isFalse);
    // The value is now set at this level.
    expect(find.text('Global'), findsNWidgets(2));
  });

  appTest('reset-to-inherit removes the override', (tester) async {
    final h = await open(tester);
    final semantics = tester.ensureSemantics();
    await tester.tap(
      find.bySemanticsLabel('Reset Speed limit to the inherited value'),
    );
    await tester.pump();
    expect(canSave(tester), isTrue);
    await tester.tap(save());
    await settle(tester);
    expect(settings(h).patches, [
      {'speedLimit': null},
    ]);
    semantics.dispose();
  });

  appTest('revert drops the edits', (tester) async {
    await open(tester);
    await tester.enterText(numberField('Max connections'), '4');
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Revert'));
    await tester.pump();
    expect(canSave(tester), isFalse);
  });

  appTest('the daemon\'s field errors show under their field', (tester) async {
    final h = await open(
      tester,
      make: () => FakeGlobalSettings(
        stored: const Settings(),
        defaults: const Settings(maxConnections: 8, speedLimit: 0),
        failWith: const ApiProblem(
          status: 422,
          code: 'settings.invalid',
          errors: [
            ProblemDetail(
              message: 'must be at most 64',
              location: 'body.maxConnections',
            ),
          ],
        ),
      ),
    );
    await tester.enterText(numberField('Max connections'), '60');
    await tester.pump();
    await tester.tap(save());
    await settle(tester);
    expect(find.text('must be at most 64'), findsOneWidget);
    expect(canSave(tester), isTrue, reason: 'the edit is kept');
    // Editing the field clears its error.
    await tester.enterText(numberField('Max connections'), '10');
    await tester.pump();
    expect(find.text('must be at most 64'), findsNothing);
    expect(settings(h).patches.length, 1);
  });

  appTest('search narrows the fields', (tester) async {
    await open(tester);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(DlmSearchField),
            matching: find.byType(EditableText),
          )
          .last,
      'unlimited',
    );
    await tester.pump();
    expect(find.text('Speed limit'), findsOneWidget);
    expect(find.text('Max connections'), findsNothing);
  });

  appTest('leaving with unsaved edits asks first', (tester) async {
    await open(tester);
    await tester.enterText(numberField('Max connections'), '4');
    await tester.pump();
    await tester.tap(find.text('General').first);
    await settle(tester);
    expect(find.text('Leave without saving?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await settle(tester);
    expect(find.text('Max connections'), findsOneWidget, reason: 'stayed');
    await tester.tap(find.text('General').first);
    await settle(tester);
    await tester.tap(find.text('Leave'));
    await settle(tester);
    expect(find.text('What to do when the target file exists'), findsOneWidget);
  });

  appTest('a download\'s Settings tab edits its own overrides', (tester) async {
    final h = await pumpApp(
      tester,
      tasks: [
        task('a', name: 'one.iso', settings: const Settings(maxConnections: 2)),
      ],
      overrides: [
        settingsSchemaProvider.overrideWith((ref) async => _schema),
        settingsRepositoryProvider.overrideWithValue(
          _TaskSettings(const Settings(maxConnections: 2), {
            'maxConnections': 'task',
            'speedLimit': 'global',
          }, const Settings(maxConnections: 2, speedLimit: 1048576)),
        ),
      ],
    );
    await tester.tap(find.text('one.iso'));
    await settle(tester);
    final tab = find.descendant(
      of: find.byWidgetPredicate((w) => w is DlmTabBar),
      matching: find.text('Settings'),
    );
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await settle(tester);
    expect(find.text('This download'), findsOneWidget, reason: 'its override');
    expect(find.text('Global'), findsOneWidget, reason: 'inherited');
    await tester.enterText(numberField('Max connections'), '6');
    await tester.pump();
    await tester.tap(save());
    await settle(tester);
    expect(h.tasks.calls, ['settings:a:{"maxConnections":6}']);
  });
}

void editorTests() {
  FakeGlobalSettings settings(AppHarness h) =>
      h.container.read(globalSettingsProvider.notifier) as FakeGlobalSettings;

  Future<AppHarness> open(WidgetTester tester, String group) async {
    final h = await pumpApp(
      tester,
      overrides: [
        settingsSchemaProvider.overrideWith((ref) async => _schema),
        globalSettingsProvider.overrideWith(
          () => FakeGlobalSettings(
            stored: const Settings(),
            defaults: const Settings(),
          ),
        ),
      ],
    );
    h.container.read(routerProvider).go('/settings/$group');
    await settle(tester);
    return h;
  }

  Finder parsed(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is DlmParsedField && w.semanticLabel == label,
    ),
    matching: find.byType(EditableText),
  );

  Future<void> choose(
    WidgetTester tester,
    String label,
    String option, {
    bool last = false,
  }) async {
    final dropdowns = find.byWidgetPredicate(
      (w) => w is DlmDropdown && w.semanticLabel == label,
    );
    await tester.tap(last ? dropdowns.last : dropdowns);
    await settle(tester);
    await tester.tap(find.text(option).last);
    await settle(tester);
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(DlmButton, 'Save'));
    await settle(tester);
  }

  appTest('headers are edited as name and value rows', (tester) async {
    final h = await open(tester, 'network');
    await tester.tap(find.text('Add'));
    await settle(tester);
    await tester.enterText(parsed('Name'), 'X-Token');
    await tester.pump();
    await tester.enterText(parsed('Value'), 'abc');
    await tester.pump();
    await save(tester);
    expect(settings(h).patches, [
      {
        'headers': {'X-Token': 'abc'},
      },
    ]);
  });

  appTest('a custom proxy has an address, the system one does not', (
    tester,
  ) async {
    final h = await open(tester, 'network');
    await choose(tester, 'Proxy', 'A proxy I choose');
    await tester.enterText(parsed('Proxy address'), 'http://p:3128');
    await tester.pump();
    await save(tester);
    expect(settings(h).patches.single, {
      'proxy': {'mode': 'custom', 'url': 'http://p:3128'},
    });
  });

  appTest('tracker addresses are one per line', (tester) async {
    final h = await open(tester, 'torrent');
    await tester.enterText(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is DlmTextField && w.semanticLabel == 'One entry per line',
        ),
        matching: find.byType(EditableText),
      ),
      'udp://a:1\n\nudp://b:2',
    );
    await tester.pump();
    await save(tester);
    expect(settings(h).patches.single, {
      'torrent': {
        'trackers': ['udp://a:1', 'udp://b:2'],
      },
    });
  });

  appTest('refresh strategies keep the order they were added in', (
    tester,
  ) async {
    final h = await open(tester, 'refresh');
    await choose(tester, 'Add', 'Manual');
    await choose(tester, 'Add', 'Origin redirect');
    expect(find.text('1. Manual'), findsOneWidget);
    expect(find.text('2. Origin redirect'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Move up').last);
    await settle(tester);
    expect(find.text('1. Origin redirect'), findsOneWidget);
    await save(tester);
    expect(settings(h).patches.single, {
      'refresh': {
        'strategies': ['origin-redirect', 'manual'],
      },
    });
    semantics.dispose();
  });

  appTest('a program action warns and needs a program', (tester) async {
    final h = await open(tester, 'post-processing');
    await choose(tester, 'Add an action', 'Run a program');
    expect(
      find.textContaining('Only use a program you trust.'),
      findsOneWidget,
    );
    await tester.enterText(parsed('Program'), '/usr/bin/notify');
    await tester.pump();
    await tester.enterText(parsed('Time limit'), '2m');
    await tester.pump();
    await save(tester);
    expect(settings(h).patches.single, {
      'postActions': [
        {
          'kind': 'command',
          'params': {'cmd': '/usr/bin/notify', 'timeout': '2m'},
        },
      ],
    });
  });

  appTest('a virus scan says what happens to an infected file', (tester) async {
    await open(tester, 'post-processing');
    await choose(tester, 'Add an action', 'Scan for viruses');
    expect(find.textContaining('is deleted'), findsOneWidget);
    expect(find.text('Delete the file'), findsOneWidget);
  });

  appTest('an archive action keeps its own options', (tester) async {
    final h = await open(tester, 'post-processing');
    await choose(tester, 'Add an action', 'Unpack archives');
    await tester.tap(find.text('Delete the file afterwards'));
    await settle(tester);
    await save(tester);
    expect(settings(h).patches.single, {
      'postActions': [
        {
          'kind': 'extract',
          'params': {'delete': 'true'},
        },
      ],
    });
  });

  appTest('a speed profile has a limit and its hours', (tester) async {
    final h = await open(tester, 'speed');
    await tester.tap(find.text('Add a profile'));
    await settle(tester);
    await tester.enterText(parsed('Limit while active'), '2 M');
    await tester.pump();
    await save(tester);
    expect(settings(h).patches.single, {
      'speedProfiles': [
        {'speedLimit': 2 * 1024 * 1024, 'windows': <Object>[]},
      ],
    });
  });

  appTest('a proxy rule sends some hosts through another proxy', (
    tester,
  ) async {
    final h = await open(tester, 'network');
    await tester.tap(find.text('Add a rule'));
    await settle(tester);
    await tester.enterText(parsed('Hosts'), 'a.com, *.b.net');
    await tester.pump();
    await choose(tester, 'Proxy', 'A proxy I choose', last: true);
    await tester.enterText(parsed('Proxy address'), 'http://r:1');
    await tester.pump();
    await save(tester);
    expect(settings(h).patches.single, {
      'proxyRules': [
        {
          'hosts': ['a.com', '*.b.net'],
          'proxy': {'mode': 'custom', 'url': 'http://r:1'},
        },
      ],
    });
  });

  appTest('a quota is an amount per period', (tester) async {
    final h = await open(tester, 'speed');
    await tester.enterText(parsed('Amount'), '10 G');
    await tester.pump();
    await tester.enterText(parsed('Period'), '720h');
    await tester.pump();
    await save(tester);
    expect(settings(h).patches.single, {
      'quota': {'bytes': 10 * 1024 * 1024 * 1024, 'period': '720h'},
    });
  });
}

/// A settings service that answers the effective settings of any task.
class _TaskSettings implements SettingsRepository {
  _TaskSettings(this.stored, this.sources, this.effective);

  final Settings stored;
  final Map<String, String> sources;
  final Settings effective;

  @override
  Future<EffectiveSettings> effectiveForTask(String id) async =>
      EffectiveSettings.of(Effective(settings: effective, sources: sources));

  @override
  Future<EffectiveSettings> effectiveForQueue(String id) =>
      throw UnimplementedError();

  @override
  Future<GlobalSettings> load() => throw UnimplementedError();

  @override
  Future<GlobalSettings> patch(
    Map<String, Object?> mergePatch, {
    String? etag,
  }) => throw UnimplementedError();

  @override
  Future<Schema> schema() async => _schema;
}
