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
    : _client = api.rest.tasks,
      _system = api.rest.system;

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
