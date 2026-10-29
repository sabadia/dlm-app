import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/add/add_dialog.dart';
import 'package:dlm_app/src/add/add_input.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// The add service in memory: it records what is asked and answers from the
/// given fixtures.
class FakeAdd implements AddRepository {
  FakeAdd({this.duplicate, this.patternCount = 20, this.failUrl});

  final DuplicateHint? duplicate;
  final int patternCount;
  final String? failUrl;
  final List<CreateTaskBody> created = [];
  final List<List<CreateTaskBody>> batches = [];

  @override
  Future<ResolveResult> resolve(String url, {String? queueId}) async =>
      ResolveResult(
        duplicateOf: duplicate,
        engine: 'http',
        expiresAt: DateTime.utc(2030),
        name: 'ubuntu.iso',
        resolveId: 'r1',
        resource: const Resource(
          name: 'ubuntu.iso',
          rangeSupported: true,
          size: 2048,
        ),
        source: Source(
          currentUrl: url,
          fingerprint: const Fingerprint(size: 2048),
        ),
      );

  @override
  Future<ExpandedPattern> expand(String pattern, {int preview = 5}) async =>
      ExpandedPattern(
        count: patternCount,
        urls: [for (var i = 1; i <= preview; i++) 'http://h/img$i.jpg'],
      );

  @override
  Future<Task> create(CreateTaskBody body) async {
    created.add(body);
    return task('new', name: 'ubuntu.iso');
  }

  @override
  Future<List<BatchItem>> createMany(
    List<CreateTaskBody> items, {
    bool expandPatterns = true,
  }) async {
    batches.add(items);
    return [
      for (final (i, item) in items.indexed)
        if (item.url == failUrl)
          BatchItem(
            ok: false,
            url: item.url,
            error: const Problem(
              code: 'task.invalid',
              type: 'urn:dlm:problem:task.invalid',
              detail: 'unsupported scheme',
            ),
          )
        else
          BatchItem(
            ok: true,
            url: item.url,
            task: task('n$i', name: 'n$i'),
          ),
    ];
  }
}

void main() {
  Future<void> openDialog(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(
      find
          .descendant(
            of: find.byType(AddDownloadDialog),
            matching: find.byType(EditableText),
          )
          .first,
      text,
    );
    await tester.pump(addLookupDelay + const Duration(milliseconds: 50));
    await settle(tester);
  }

  Finder addButton() => find.widgetWithText(DlmButton, 'Add');
  bool enabled(WidgetTester tester) =>
      tester.widget<DlmButton>(addButton()).onPressed != null;

  Future<void> pump(WidgetTester tester, FakeAdd add) => pumpApp(
    tester,
    queues: [queue('main', 'Default')],
    overrides: [addRepositoryProvider.overrideWithValue(add)],
  );

  test('links are one per line, without blanks, comments and repeats', () {
    expect(parseLinks('a\n\n  b \r\n# c\na\n'), ['a', 'b']);
    expect(isPattern('http://h/img[1-20].jpg'), isTrue);
    expect(isPattern('http://h/{a,b}.zip'), isTrue);
    expect(isPattern('http://h/file[1].zip'), isFalse);
    expect(isPattern('http://h/plain.zip'), isFalse);
  });

  appTest('one link is looked at, then added with its resolution', (
    tester,
  ) async {
    final add = FakeAdd();
    await pump(tester, add);
    await openDialog(tester);
    expect(enabled(tester), isFalse);
    await type(tester, 'http://h/ubuntu.iso');
    expect(find.text('ubuntu.iso'), findsOneWidget);
    expect(enabled(tester), isTrue);
    await tester.tap(addButton());
    await settle(tester);
    expect(add.created, hasLength(1));
    expect(add.created.single.url, 'http://h/ubuntu.iso');
    expect(add.created.single.resolveId, 'r1');
    expect(find.text('Added ubuntu.iso'), findsOneWidget);
  });

  appTest('a duplicate needs "add it anyway"', (tester) async {
    final add = FakeAdd(
      duplicate: const DuplicateHint(
        name: 'ubuntu.iso',
        status: 'completed',
        taskId: 't0',
      ),
    );
    await pump(tester, add);
    await openDialog(tester);
    await type(tester, 'http://h/ubuntu.iso');
    expect(find.text('Already in the list: ubuntu.iso'), findsOneWidget);
    expect(enabled(tester), isFalse);
    await tester.tap(find.text('Add it anyway'));
    await settle(tester);
    expect(enabled(tester), isTrue);
    await tester.tap(addButton());
    await settle(tester);
    expect(add.created.single.allowDuplicate, isTrue);
  });

  appTest('a pattern shows how many downloads it makes', (tester) async {
    final add = FakeAdd();
    await pump(tester, add);
    await openDialog(tester);
    await type(tester, 'http://h/img[1-20].jpg');
    expect(find.text('20 downloads'), findsOneWidget);
    expect(find.text('http://h/img1.jpg'), findsOneWidget);
    await tester.tap(addButton());
    await settle(tester);
    expect(add.batches.single.single.url, 'http://h/img[1-20].jpg');
  });

  appTest('a link that fails stays in the dialog with its reason', (
    tester,
  ) async {
    final add = FakeAdd(failUrl: 'bad://x');
    await pump(tester, add);
    await openDialog(tester);
    await type(tester, 'http://h/a\nbad://x');
    await tester.tap(addButton());
    await settle(tester);
    expect(find.textContaining('bad://x: unsupported scheme'), findsOneWidget);
    expect(find.text('Add downloads'), findsWidgets);
  });
}
