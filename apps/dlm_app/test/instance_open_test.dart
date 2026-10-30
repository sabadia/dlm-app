import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/add/add_dialog.dart';
import 'package:dlm_app/src/platform/instance_open.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  test(
    'a torrent is read, and one that is missing or too big is not',
    () async {
      final dir = io.Directory.systemTemp.createTempSync('dlm_torrent');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = io.File('${dir.path}/movie.torrent')
        ..writeAsBytesSync([1, 2, 3]);
      final ready = await readOpenedTorrent(file.path, maxBytes: 4);
      expect(ready, isA<OpenedTorrentReady>());
      expect((ready as OpenedTorrentReady).name, 'movie.torrent');
      expect(ready.bytes, [1, 2, 3]);

      expect(
        await readOpenedTorrent(file.path, maxBytes: 2),
        isA<OpenedTorrentTooBig>(),
      );
      expect(
        await readOpenedTorrent('${dir.path}/missing.torrent'),
        isA<OpenedTorrentMissing>(),
      );
    },
  );

  appTest('a launch and a later open are presented', (tester) async {
    final later = StreamController<HandedOpen>();
    final native = StreamController<List<String>>();
    addTearDown(() {
      unawaited(later.close());
      unawaited(native.close());
    });
    final seen = <HandedOpen>[];
    await pumpApp(
      tester,
      overrides: [
        openingsProvider.overrideWithValue(
          Openings(
            launch: const HandedOpen(links: ['magnet:?xt=urn:btih:abc']),
            later: later.stream,
            native: native.stream,
          ),
        ),
        handedPresenterProvider.overrideWithValue((context, ref, open) async {
          seen.add(open);
        }),
      ],
    );
    expect(seen, const [
      HandedOpen(links: ['magnet:?xt=urn:btih:abc']),
    ]);

    later.add(const HandedOpen(links: ['ed2k://|file|a|1|/']));
    native.add(const ['other.torrent']);
    await settle(tester);
    expect(seen, const [
      HandedOpen(links: ['magnet:?xt=urn:btih:abc']),
      HandedOpen(links: ['ed2k://|file|a|1|/']),
      HandedOpen(torrents: ['other.torrent']),
    ]);
  });

  appTest('an opened magnet is filled into the add dialog', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        openingsProvider.overrideWithValue(
          const Openings(
            launch: HandedOpen(links: ['magnet:?xt=urn:btih:abc']),
          ),
        ),
        addRepositoryProvider.overrideWithValue(_QuietAdd()),
      ],
    );
    await settle(tester);
    expect(find.text('Add downloads'), findsOneWidget);
    expect(find.textContaining('magnet:?xt=urn:btih:abc'), findsWidgets);
  });

  appTest('an opened torrent is named in the add dialog', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        openingsProvider.overrideWithValue(
          const Openings(launch: HandedOpen(torrents: ['movie.torrent'])),
        ),
        openedTorrentReaderProvider.overrideWithValue(
          (path, {int maxBytes = maxTorrentBytes}) async =>
              OpenedTorrentReady('movie.torrent', Uint8List(1)),
        ),
        addRepositoryProvider.overrideWithValue(_QuietAdd()),
      ],
    );
    await settle(tester);
    expect(find.text('movie.torrent'), findsOneWidget);
  });
}

/// Answers a preview and does nothing else. The dialog looks a link up as it
/// opens; the test must not open a socket.
class _QuietAdd implements AddRepository {
  @override
  Future<Task> addTorrent(
    Uint8List bytes, {
    String? queueId,
    String? name,
    String? dir,
    bool paused = false,
    bool allowDuplicate = false,
  }) async => throw UnimplementedError();

  ResolveResult _resolved(String url) => ResolveResult(
    engine: 'http',
    expiresAt: DateTime.utc(2030),
    name: 'file.bin',
    resolveId: 'r1',
    resource: const Resource(name: 'file.bin', rangeSupported: true, size: 1),
    source: Source(currentUrl: url, fingerprint: const Fingerprint(size: 1)),
  );

  @override
  Future<ResolveResult> resolve(String url, {String? queueId}) async =>
      _resolved(url);

  @override
  Future<ExpandedPattern> expand(String pattern, {int preview = 5}) async =>
      const ExpandedPattern(count: 1, urls: ['https://example.com/a']);

  @override
  Future<Task> create(CreateTaskBody body) => throw UnimplementedError();

  @override
  Future<List<BatchItem>> importList(
    String content,
    ImportTasksBodyFormat format, {
    String? queueId,
    bool paused = false,
    bool dryRun = false,
    bool allowDuplicate = false,
  }) => throw UnimplementedError();

  @override
  Future<ExportedTasks> exportTasks(
    Format2 format, {
    String? queueId,
    Set<String> statuses = const {},
  }) => throw UnimplementedError();

  @override
  Future<FsListing> browse(String? path) => throw UnimplementedError();

  @override
  Future<FsFree> freeSpace(String? path) => throw UnimplementedError();

  @override
  Future<List<BatchItem>> createMany(
    List<CreateTaskBody> items, {
    bool expandPatterns = true,
  }) => throw UnimplementedError();
}
