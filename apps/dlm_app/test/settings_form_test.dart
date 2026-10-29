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
  ],
);

void main() {
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
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);
    // Other groups and structured values are not on this page.
    expect(find.text('Retry: max attempts'), findsNothing);
    expect(find.text('Proxy'), findsNothing);
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
