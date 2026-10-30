import 'dart:typed_data';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/add/add_dialog.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/cookies_screen.dart';
import 'package:dlm_app/src/manage/transfer_screen.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// The add service in memory for lists.
class FakeLists implements AddRepository {
  FakeLists({this.unreadable = false});

  final bool unreadable;
  final List<String> calls = [];

  @override
  Future<Task> addTorrent(
    Uint8List bytes, {
    String? queueId,
    String? name,
    String? dir,
    bool paused = false,
    bool allowDuplicate = false,
  }) async => throw UnimplementedError();

  @override
  Future<List<BatchItem>> importList(
    String content,
    ImportTasksBodyFormat format, {
    String? queueId,
    bool paused = false,
    bool dryRun = false,
    bool allowDuplicate = false,
  }) async {
    calls.add(
      'import ${format.json} $queueId $paused $dryRun $allowDuplicate '
      '${content.split('\n').length}',
    );
    if (unreadable) {
      throw const ApiProblem(status: 422, code: 'task.unreadable_list');
    }
    return [
      for (final (i, url) in content.split('\n').indexed)
        if (url.startsWith('dup'))
          BatchItem(
            ok: false,
            url: url,
            error: const Problem(
              code: 'task.duplicate',
              type: 'urn:dlm:problem:task.duplicate',
            ),
          )
        else
          BatchItem(
            ok: true,
            url: url,
            task: dryRun ? null : task('i$i', name: 'item $i'),
          ),
    ];
  }

  @override
  Future<ExportedTasks> exportTasks(
    Format2 format, {
    String? queueId,
    Set<String> statuses = const {},
  }) async {
    calls.add('export ${format.json} $queueId ${statuses.join(',')}');
    return ExportedTasks(
      content: 'http://a/1\nhttp://b/2',
      count: 2,
      format: format.json ?? '',
    );
  }

  @override
  Future<ResolveResult> resolve(String url, {String? queueId}) =>
      throw UnimplementedError();

  @override
  Future<ExpandedPattern> expand(String pattern, {int preview = 5}) =>
      throw UnimplementedError();

  @override
  Future<Task> create(CreateTaskBody body) => throw UnimplementedError();

  @override
  Future<List<BatchItem>> createMany(
    List<CreateTaskBody> items, {
    bool expandPatterns = true,
  }) => throw UnimplementedError();

  @override
  Future<FsListing> browse(String? path) => throw UnimplementedError();

  @override
  Future<FsFree> freeSpace(String? path) => throw UnimplementedError();
}

void main() {
  Future<AppHarness> open(
    WidgetTester tester,
    FakeLists lists, {
    List<Override> overrides = const [],
  }) async {
    final h = await pumpApp(
      tester,
      queues: [queue('main', 'Default'), queue('night', 'Night')],
      overrides: [addRepositoryProvider.overrideWithValue(lists), ...overrides],
    );
    h.container.read(routerProvider).go('/manage/transfer');
    await settle(tester);
    return h;
  }

  // The page's own scrollable (the sidebar has one too).
  final pageScroll = find
      .descendant(
        of: find.byType(TransferScreen),
        matching: find.byType(Scrollable),
      )
      .first;

  Finder listField() => find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is DlmTextField && w.semanticLabel == 'The list',
    ),
    matching: find.byType(EditableText),
  );

  Future<void> paste(WidgetTester tester, String text) async {
    await tester.enterText(listField(), text);
    await tester.pump();
  }

  appTest('nothing can be previewed before there is a list', (tester) async {
    await open(tester, FakeLists());
    expect(
      tester
          .widget<DlmButton>(find.widgetWithText(DlmButton, 'Preview'))
          .onPressed,
      isNull,
    );
  });

  appTest('a list is previewed first, then added', (tester) async {
    final lists = FakeLists();
    final h = await open(tester, lists);
    await paste(tester, 'http://a/1\ndup://x\nhttp://b/2');
    await tester.tap(find.widgetWithText(DlmButton, 'Preview'));
    await settle(tester);
    expect(lists.calls.single, 'import urls null false true false 3');
    expect(find.text('Would add 2, would not add 1.'), findsOneWidget);
    expect(find.text('Already in the list'), findsOneWidget);
    await tester.tap(find.text('Add 2 downloads'));
    await settle(tester);
    expect(lists.calls.last, 'import urls null false false false 3');
    expect(find.text('2 added, 1 not added.'), findsOneWidget);
    expect(h.container.read(taskStoreProvider).tasks['i0'], isNotNull);
    // The import button is gone: the list was added.
    expect(find.text('Add 2 downloads'), findsNothing);
  });

  appTest('changing the list or an option discards the preview', (
    tester,
  ) async {
    await open(tester, FakeLists());
    await paste(tester, 'http://a/1');
    await tester.tap(find.widgetWithText(DlmButton, 'Preview'));
    await settle(tester);
    expect(find.textContaining('Would add 1'), findsOneWidget);
    await paste(tester, 'http://a/1\nhttp://a/2');
    expect(find.textContaining('Would add'), findsNothing);
  });

  appTest('the options go with the import', (tester) async {
    final lists = FakeLists();
    await open(tester, lists);
    await paste(tester, 'http://a/1');
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmSwitch && w.semanticLabel == 'Add without starting',
      ),
    );
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmSwitch && w.semanticLabel == 'Add duplicates too',
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Preview'));
    await settle(tester);
    expect(lists.calls.single, 'import urls null true true true 1');
  });

  appTest('a chosen file fills the list and sets its kind', (tester) async {
    final lists = FakeLists();
    await open(
      tester,
      lists,
      overrides: [
        addFilePickerProvider.overrideWithValue(
          () async => (name: 'export.json', content: '{"tasks":[]}'),
        ),
      ],
    );
    await tester.tap(find.text('Choose a file…'));
    await settle(tester);
    await tester.tap(find.widgetWithText(DlmButton, 'Preview'));
    await settle(tester);
    expect(lists.calls.single, startsWith('import json'));
  });

  appTest('a list that cannot be read is reported', (tester) async {
    await open(tester, FakeLists(unreadable: true));
    await paste(tester, 'garbage');
    await tester.tap(find.widgetWithText(DlmButton, 'Preview'));
    await settle(tester);
    expect(find.textContaining('Would add'), findsNothing);
  });

  appTest('an export shows the list and can be saved', (tester) async {
    final lists = FakeLists();
    final saved = <(String, String)>[];
    await open(
      tester,
      lists,
      overrides: [
        saveTextFileProvider.overrideWithValue((name, content) async {
          saved.add((name, content));
          return true;
        }),
      ],
    );
    Future<void> pick(String label, String option) async {
      final dropdown = find.byWidgetPredicate(
        (w) => w is DlmDropdown && w.semanticLabel == label,
      );
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await settle(tester);
      await tester.tap(find.text(option).last);
      await settle(tester);
    }

    await pick('File kind to export', 'One link per line');
    await pick('Which downloads', 'Completed');
    // The page is a lazy list: scroll until the button is built.
    await tester.scrollUntilVisible(
      find.widgetWithText(DlmButton, 'Export'),
      300,
      scrollable: pageScroll,
    );
    await tester.tap(find.widgetWithText(DlmButton, 'Export'));
    await settle(tester);
    expect(lists.calls.single, 'export urls null completed');
    expect(find.text('2 downloads'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save to a file…'),
      300,
      scrollable: pageScroll,
    );
    await tester.tap(find.text('Save to a file…'));
    await settle(tester);
    expect(saved, [('downloads.txt', 'http://a/1\nhttp://b/2')]);
  });
}
