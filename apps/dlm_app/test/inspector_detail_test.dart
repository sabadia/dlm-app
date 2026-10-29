import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// The segments, swarm and file choice of tasks in memory.
class FakeDetail implements TaskDetailRepository {
  FakeDetail(this.tasks, {this.segmentList = const [], this.info});

  final FakeTaskRepository tasks;
  final List<Segment> segmentList;
  final TorrentInfo? info;
  final List<(String, List<int>)> chosen = [];

  @override
  Future<List<Segment>> segments(String id) async => segmentList;

  @override
  Future<TorrentInfo?> torrent(String id) async => info;

  @override
  Future<Task> setFiles(String id, List<int> selected) async {
    chosen.add((id, selected));
    final t = tasks.tasks.firstWhere((t) => t.id == id);
    final files = t.resource!.files!;
    return task(
      id,
      status: t.status,
      name: t.name,
      engine: t.engine,
      resource: Resource(
        name: t.resource!.name,
        rangeSupported: true,
        size: t.resource!.size,
        files: [
          for (final f in files)
            File(
              index: f.index,
              name: f.name,
              path: f.path,
              size: f.size,
              selected: selected.contains(f.index),
            ),
        ],
      ),
    );
  }
}

void main() {
  Future<void> select(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await settle(tester);
  }

  Future<void> tab(WidgetTester tester, String label) async {
    final target = find.descendant(
      of: find.byWidgetPredicate((w) => w is DlmTabBar),
      matching: find.text(label),
    );
    await tester.ensureVisible(target);
    await tester.tap(target);
    await settle(tester);
  }

  const files = Resource(
    name: 'pack',
    rangeSupported: true,
    size: 300,
    files: [
      File(
        index: 0,
        name: 'a.txt',
        path: 'docs/a.txt',
        selected: true,
        size: 100,
      ),
      File(
        index: 1,
        name: 'b.txt',
        path: 'docs/b.txt',
        selected: false,
        size: 200,
      ),
    ],
  );

  Future<FakeDetail> open(
    WidgetTester tester,
    Task t, {
    List<Segment> segments = const [],
    TorrentInfo? info,
  }) async {
    final repo = FakeTaskRepository([t]);
    final detail = FakeDetail(repo, segmentList: segments, info: info);
    await pumpApp(
      tester,
      tasks: [t],
      overrides: [taskDetailRepositoryProvider.overrideWithValue(detail)],
    );
    await select(tester, t.name!);
    return detail;
  }

  appTest('the segments map says how much of the file is done', (tester) async {
    await open(
      tester,
      task('a', status: 'paused', name: 'big.iso', engine: 'http'),
      segments: const [
        Segment(index: 0, start: 0, end: 100, done: 100),
        Segment(index: 1, start: 100, end: 200, done: 0),
      ],
    );
    await tab(tester, 'Segments');
    expect(find.text('2 segments, 50% done.'), findsOneWidget);
  });

  appTest('a download without segments says so', (tester) async {
    await open(
      tester,
      task('a', status: 'paused', name: 'big.iso', engine: 'http'),
    );
    await tab(tester, 'Segments');
    expect(
      find.text('This download is not split into segments.'),
      findsOneWidget,
    );
  });

  appTest('a torrent has a swarm tab instead of segments', (tester) async {
    await open(
      tester,
      task('a', status: 'paused', name: 'pack', engine: 'bt'),
      info: const TorrentInfo(
        downloaded: 10,
        infoHash: 'abc123',
        knownPeers: 9,
        peerCount: 3,
        private: false,
        ratio: 1.5,
        seeders: 2,
        seedingSeconds: 0,
        state: 'downloading',
        uploaded: 2048,
        peers: [TorrentPeer(address: '10.0.0.1:6881', downloadRate: 0)],
      ),
    );
    expect(find.text('Segments'), findsNothing);
    await tab(tester, 'Torrent');
    expect(find.text('abc123'), findsOneWidget);
    expect(find.text('3 connected, 9 known, 2 seeders'), findsOneWidget);
    expect(find.text('10.0.0.1:6881'), findsOneWidget);
  });

  appTest('a torrent that never ran has no swarm yet', (tester) async {
    await open(tester, task('a', status: 'paused', name: 'pack', engine: 'bt'));
    await tab(tester, 'Torrent');
    expect(find.textContaining('has not started'), findsOneWidget);
  });

  appTest('the chosen files can be changed while paused', (tester) async {
    final detail = await open(
      tester,
      task('a', status: 'paused', name: 'pack', engine: 'bt', resource: files),
    );
    await tab(tester, 'Files');
    await tester.tap(find.text('Choose files'));
    await settle(tester);
    expect(find.text('1 of 2 files selected'), findsOneWidget);
    // docs/ (box 0), a.txt (1), b.txt (2)
    await tester.tap(find.byType(DlmCheckbox).at(2));
    await settle(tester);
    expect(find.text('2 of 2 files selected'), findsOneWidget);
    await tester.tap(find.text('Save selection'));
    await settle(tester);
    expect(detail.chosen, hasLength(1));
    expect(detail.chosen.single.$1, 'a');
    expect(detail.chosen.single.$2, [0, 1]);
    expect(find.text('Selection saved'), findsOneWidget);
    expect(find.text('Choose files'), findsOneWidget);
  });

  appTest('a running download cannot change its files', (tester) async {
    await open(
      tester,
      task('a', status: 'running', name: 'pack', engine: 'bt', resource: files),
    );
    await tab(tester, 'Files');
    expect(find.text('Choose files'), findsNothing);
    expect(find.textContaining('Pause the download'), findsOneWidget);
  });
}
