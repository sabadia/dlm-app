import 'dart:typed_data';

import 'package:dlm_api/dlm_api.dart';

/// What the app asks of the daemon to add downloads: look at a link before
/// adding it, expand a pattern, and create the tasks.
abstract interface class AddRepository {
  /// Looks at [url] without creating a task: name, size, files, and the task
  /// it duplicates, if any.
  Future<ResolveResult> resolve(String url, {String? queueId});

  /// The links a pattern such as `http://x/img[1-20].jpg` stands for; at most
  /// [preview] of them are listed, [ExpandedPattern.count] is the total.
  Future<ExpandedPattern> expand(String pattern, {int preview = 5});

  /// Creates one task.
  Future<Task> create(CreateTaskBody body);

  /// Creates a torrent task from the bytes of a `.torrent` file. The file
  /// travels as the request body, not inside JSON, so one up to 16 MiB works.
  Future<Task> addTorrent(
    Uint8List bytes, {
    String? queueId,
    String? name,
    String? dir,
    bool paused = false,
    bool allowDuplicate = false,
  });

  /// Adds the tasks listed in an exported file ([format] says how to read
  /// [content]). With [dryRun] nothing is created and each result says whether
  /// the entry would be added.
  Future<List<BatchItem>> importList(
    String content,
    ImportTasksBodyFormat format, {
    String? queueId,
    bool paused = false,
    bool dryRun = false,
    bool allowDuplicate = false,
  });

  /// The tasks matching the filters as a list file: [format] says which kind.
  /// Captured headers and cookies are never included.
  Future<ExportedTasks> exportTasks(
    Format2 format, {
    String? queueId,
    Set<String> statuses = const {},
  });

  /// The folders below [path] on the daemon's machine (the roots when null);
  /// only places the daemon is allowed to show.
  Future<FsListing> browse(String? path);

  /// The free space of the disk holding [path].
  Future<FsFree> freeSpace(String? path);

  /// Creates several tasks; a failure of one does not stop the others. With
  /// [expandPatterns] every item whose link is a pattern becomes many tasks.
  Future<List<BatchItem>> createMany(
    List<CreateTaskBody> items, {
    bool expandPatterns = true,
  });
}

/// The REST implementation.
class ApiAddRepository implements AddRepository {
  /// Creates the repository over [api].
  ApiAddRepository(DlmApi api)
    : _api = api,
      _client = api.rest.tasks,
      _system = api.rest.system;

  final DlmApi _api;
  final TasksClient _client;
  final SystemClient _system;

  @override
  Future<ResolveResult> resolve(String url, {String? queueId}) => guard(
    () => _client.resolveTask(
      body: ResolveTaskBody(url: url, queueId: queueId),
    ),
  );

  @override
  Future<ExpandedPattern> expand(String pattern, {int preview = 5}) => guard(
    () => _client.expandTasks(
      body: ExpandTasksBody(pattern: pattern, preview: preview),
    ),
  );

  @override
  Future<Task> create(CreateTaskBody body) =>
      guard(() => _client.createTask(body: body));

  @override
  Future<Task> addTorrent(
    Uint8List bytes, {
    String? queueId,
    String? name,
    String? dir,
    bool paused = false,
    bool allowDuplicate = false,
  }) => _api.addTorrentBytes(
    bytes,
    queueId: queueId,
    name: name,
    dir: dir,
    paused: paused,
    allowDuplicate: allowDuplicate,
  );

  @override
  Future<List<BatchItem>> importList(
    String content,
    ImportTasksBodyFormat format, {
    String? queueId,
    bool paused = false,
    bool dryRun = false,
    bool allowDuplicate = false,
  }) async {
    final out = await guard(
      () => _client.importTasks(
        body: ImportTasksBody(
          content: content,
          format: format,
          queueId: queueId,
          paused: paused ? true : null,
          dryRun: dryRun ? true : null,
          allowDuplicate: allowDuplicate ? true : null,
        ),
      ),
    );
    return out.results ?? const [];
  }

  @override
  Future<ExportedTasks> exportTasks(
    Format2 format, {
    String? queueId,
    Set<String> statuses = const {},
  }) => guard(
    () => _client.exportTasks(
      format: format,
      queueId: queueId,
      status: [
        for (final s in statuses) ...Status.values.where((v) => v.json == s),
      ],
    ),
  );

  @override
  Future<FsListing> browse(String? path) =>
      guard(() => _system.getFsBrowse(path: path));

  @override
  Future<FsFree> freeSpace(String? path) =>
      guard(() => _system.getFsFree(path: path));

  @override
  Future<List<BatchItem>> createMany(
    List<CreateTaskBody> items, {
    bool expandPatterns = true,
  }) async {
    final out = await guard(
      () => _client.createTasks(
        body: CreateTasksBody(items: items, expandPatterns: expandPatterns),
      ),
    );
    return out.results ?? const [];
  }
}
