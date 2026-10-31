import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/add/add_dialog.dart';
import 'package:dlm_app/src/add/add_input.dart';
import 'package:dlm_app/src/add/add_results.dart';
import 'package:dlm_app/src/manage/logins_screen.dart';
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
  FakeAdd({this.duplicate, this.patternCount = 20, this.failUrl, this.files});

  final List<File>? files;

  final DuplicateHint? duplicate;
  final int patternCount;
  final String? failUrl;
  final List<CreateTaskBody> created = [];
  final List<(String, bool)> imports = [];
  final Map<String?, List<String>> folders = {
    null: ['/data'],
    '/data': ['/data/a', '/data/b'],
  };
  final List<List<CreateTaskBody>> batches = [];

  @override
  Future<ResolveResult> resolve(String url, {String? queueId}) async =>
      ResolveResult(
        duplicateOf: duplicate,
        engine: 'http',
        expiresAt: DateTime.utc(2030),
        name: 'ubuntu.iso',
        resolveId: 'r1',
        resource: Resource(
          name: 'ubuntu.iso',
          rangeSupported: true,
          size: 2048,
          files: files,
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
  Future<ExportedTasks> exportTasks(
    Format2 format, {
    String? queueId,
    Set<String> statuses = const {},
  }) async => ExportedTasks(content: 'x', count: 1, format: format.json ?? '');

  @override
  Future<FsListing> browse(String? path) async => FsListing(
    path: path ?? '',
    parent: path == null || path == '/data' ? null : '/data',
    entries: [
      for (final f in folders[path] ?? const <String>[])
        FsEntry(name: f.split('/').last, path: f),
    ],
  );

  @override
  Future<FsFree> freeSpace(String? path) async =>
      FsFree(freeBytes: 1 << 30, path: path ?? '');

  @override
  Future<List<BatchItem>> importList(
    String content,
    ImportTasksBodyFormat format, {
    String? queueId,
    bool paused = false,
    bool dryRun = false,
    bool allowDuplicate = false,
  }) async {
    imports.add((content, dryRun));
    return [
      for (final (i, url) in content.split('\n').indexed)
        if (url.startsWith('bad'))
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
            task: dryRun ? null : task('i$i', name: 'i$i'),
          ),
    ];
  }

  @override
  Future<Task> create(CreateTaskBody body) async {
    created.add(body);
    return task('new', name: 'ubuntu.iso');
  }

  final List<({Uint8List bytes, String? queueId})> torrents = [];

  @override
  Future<Task> addTorrent(
    Uint8List bytes, {
    String? queueId,
    String? name,
    String? dir,
    bool paused = false,
    bool allowDuplicate = false,
  }) async {
    torrents.add((bytes: bytes, queueId: queueId));
    return task('tor', name: 'pack');
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

  Future<AppHarness> pump(
    WidgetTester tester,
    FakeAdd add, {
    List<Category> categories = const [],
    List<Credential> logins = const [],
    List<CookieInfo> cookies = const [],
  }) => pumpApp(
    tester,
    queues: [queue('main', 'Default')],
    categories: categories,
    logins: logins,
    cookies: cookies,
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

  appTest('a link that fails is listed with its reason', (tester) async {
    final add = FakeAdd(failUrl: 'bad://x');
    await pump(tester, add);
    await openDialog(tester);
    await type(tester, 'http://h/a\nbad://x');
    await tester.tap(addButton());
    await settle(tester);
    // The sheet says which link failed and why.
    expect(find.text('What happened'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AddResultsSheet),
        matching: find.text('bad://x'),
      ),
      findsOneWidget,
    );
    expect(find.text('unsupported scheme'), findsOneWidget);
    expect(find.text('1 added, 1 not added.'), findsOneWidget);
  });

  appTest('the advanced options describe the source of the task', (
    tester,
  ) async {
    final add = FakeAdd();
    await pump(tester, add);
    await openDialog(tester);
    await type(tester, 'http://h/page');
    await tester.tap(find.text('More options'));
    await settle(tester);
    Future<void> fill(String label, String text) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byType(AddDownloadDialog),
              matching: find.byWidgetPredicate(
                (w) => w is DlmTextField && w.semanticLabel == label,
              ),
            )
            .first,
        text,
      );
      await tester.pump();
    }

    await fill('Headers', 'X-Token: abc');
    await fill('Mirrors', 'http://m/f');
    await tester.tap(find.text('Add'));
    await settle(tester);
    final body = add.created.single;
    expect(body.url, isNull);
    expect(body.source?.currentUrl, 'http://h/page');
    expect(body.source?.headers, {'X-Token': 'abc'});
    expect(body.source?.mirrors, ['http://m/f']);
  });

  appTest('a wrong header line stops the add', (tester) async {
    final add = FakeAdd();
    await pump(tester, add);
    await openDialog(tester);
    await type(tester, 'http://h/page');
    await tester.tap(find.text('More options'));
    await settle(tester);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(AddDownloadDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmTextField && w.semanticLabel == 'Headers',
            ),
          )
          .first,
      'nonsense',
    );
    await tester.pump();
    expect(enabled(tester), isFalse);
    expect(
      find.text('Every line needs a name, a colon and a value.'),
      findsOneWidget,
    );
  });

  appTest('a list file is previewed, then added', (tester) async {
    final add = FakeAdd();
    await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      overrides: [
        addRepositoryProvider.overrideWithValue(add),
        addFilePickerProvider.overrideWithValue(
          () async => (name: 'list.txt', content: 'http://h/a\nbad://x'),
        ),
      ],
    );
    await openDialog(tester);
    await tester.tap(find.text('Import list…'));
    await settle(tester);
    expect(find.text('Import list.txt'), findsOneWidget);
    expect(find.text('1 added, 1 not added.'), findsOneWidget);
    expect(find.text('Already in the list'), findsOneWidget);
    await tester.tap(find.text('Add 1 download'));
    await settle(tester);
    expect(add.imports.map((i) => i.$2), [true, false]);
  });

  appTest('a torrent file is uploaded as a file, not embedded in a link', (
    tester,
  ) async {
    final add = FakeAdd();
    await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      overrides: [
        addRepositoryProvider.overrideWithValue(add),
        addTorrentPickerProvider.overrideWithValue(
          () async =>
              (name: 'pack.torrent', bytes: Uint8List.fromList([1, 2, 3])),
        ),
      ],
    );
    await openDialog(tester);
    await tester.tap(find.text('Torrent file…'));
    await tester.pump(addLookupDelay + const Duration(milliseconds: 50));
    await settle(tester);
    expect(find.text('pack.torrent'), findsOneWidget);
    await tester.tap(addButton());
    await settle(tester);
    // The bytes travel as the request body: a link inside JSON is capped at 1 MiB.
    expect(add.created, isEmpty);
    expect(add.torrents.single.bytes, [1, 2, 3]);
  });

  appTest('a folder is picked from the daemon\'s own list', (tester) async {
    final add = FakeAdd();
    await pump(tester, add);
    final semantics = tester.ensureSemantics();
    await openDialog(tester);
    await tester.tap(find.bySemanticsLabel('Browse folders'));
    await settle(tester);
    await tester.tap(find.text('data'));
    await settle(tester);
    expect(find.text('a'), findsOneWidget);
    await tester.tap(find.text('Choose this folder'));
    await settle(tester);
    final field = tester.widget<DlmTextField>(
      find.byWidgetPredicate(
        (w) => w is DlmTextField && w.semanticLabel == 'Folder',
      ),
    );
    expect(field.controller?.text, '/data');
    semantics.dispose();
  });

  appTest('a changed file choice is set while paused, then resumed', (
    tester,
  ) async {
    final add = FakeAdd(
      files: const [
        File(index: 0, name: 'a.bin', path: 'a.bin', selected: true, size: 1),
        File(index: 1, name: 'b.bin', path: 'b.bin', selected: true, size: 2),
      ],
    );
    final detail = _RecordingDetail();
    final h = await pumpApp(
      tester,
      queues: [queue('main', 'Default')],
      overrides: [
        addRepositoryProvider.overrideWithValue(add),
        taskDetailRepositoryProvider.overrideWithValue(detail),
      ],
    );
    await openDialog(tester);
    await type(tester, 'magnet:?xt=urn:btih:abc');
    expect(find.text('2 of 2 files selected'), findsOneWidget);
    // The first box is the dialog's checkbox of file a.bin.
    await tester.tap(find.byType(DlmCheckbox).first);
    await settle(tester);
    expect(find.text('1 of 2 files selected'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await settle(tester);
    expect(add.created.single.paused, isTrue);
    expect(detail.chosen, [
      [1],
    ]);
    expect(h.tasks.calls, isEmpty, reason: 'resume goes through the actions');
  });

  appTest('the category a file would be sorted into is previewed', (
    tester,
  ) async {
    await pump(
      tester,
      FakeAdd(),
      categories: const [
        Category(
          dir: '/media/images',
          id: 'c1',
          name: 'Disk images',
          position: 0,
          extensions: ['iso'],
        ),
      ],
    );
    await openDialog(tester);
    await type(tester, 'http://h/ubuntu.iso');
    expect(
      find.text('Will be sorted into Disk images: /media/images'),
      findsOneWidget,
    );
  });

  appTest('a folder typed by hand replaces the category preview', (
    tester,
  ) async {
    await pump(
      tester,
      FakeAdd(),
      categories: const [
        Category(
          dir: '/media/images',
          id: 'c1',
          name: 'Disk images',
          position: 0,
          extensions: ['iso'],
        ),
      ],
    );
    await openDialog(tester);
    await type(tester, 'http://h/ubuntu.iso');
    await tester.enterText(
      find
          .descendant(
            of: find.byType(AddDownloadDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmTextField && w.semanticLabel == 'Folder',
            ),
          )
          .first,
      '/mine',
    );
    await tester.pump();
    expect(find.textContaining('Will be sorted into'), findsNothing);
  });

  appTest('the site of the link: a login can be added, cookies are counted', (
    tester,
  ) async {
    final h = await pump(tester, FakeAdd());
    await openDialog(tester);
    await type(tester, 'http://files.example.com/ubuntu.iso');
    expect(find.text('No cookies are stored for this site'), findsOneWidget);
    expect(
      find.text('No login is stored for files.example.com'),
      findsOneWidget,
    );
    await tester.tap(find.text('Add a login'));
    await settle(tester);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(LoginDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmTextField && w.semanticLabel == 'User name',
            ),
          )
          .first,
      'ada',
    );
    await tester.enterText(
      find
          .descendant(
            of: find.byType(LoginDialog),
            matching: find.byWidgetPredicate(
              (w) => w is DlmPasswordField && w.semanticLabel == 'Password',
            ),
          )
          .first,
      'pw',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Save'));
    await settle(tester);
    final fake =
        h.container.read(credentialsProvider.notifier) as FakeCredentials;
    expect(fake.calls.single, 'create files.example.com ada pw auto');
    expect(
      find.text('A login is stored for files.example.com'),
      findsOneWidget,
    );
  });

  appTest('a stored login and cookies are recognised, parents included', (
    tester,
  ) async {
    await pump(
      tester,
      FakeAdd(),
      logins: [
        Credential(
          createdAt: DateTime.utc(2026),
          host: '*.example.com',
          id: 'k',
          scheme: 'auto',
          updatedAt: DateTime.utc(2026),
          username: 'ada',
        ),
      ],
      cookies: [
        CookieInfo(
          createdAt: DateTime.utc(2026),
          domain: '.example.com',
          hostOnly: false,
          httpOnly: false,
          id: 'c',
          name: 'sid',
          path: '/',
          secure: false,
          updatedAt: DateTime.utc(2026),
        ),
      ],
    );
    await openDialog(tester);
    await type(tester, 'http://files.example.com/a.iso');
    expect(
      find.text('A login is stored for files.example.com'),
      findsOneWidget,
    );
    expect(find.text('1 cookie is stored for this site'), findsOneWidget);
  });
}

class _RecordingDetail implements TaskDetailRepository {
  final List<List<int>> chosen = [];

  @override
  Future<List<Segment>> segments(String id) async => const [];

  @override
  Future<TorrentInfo?> torrent(String id) async => null;

  @override
  Future<Task> setFiles(String id, List<int> selected) async {
    chosen.add(selected);
    return task(id, status: 'paused', name: 'ubuntu.iso');
  }
}
