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
  ApiAddRepository(DlmApi api) : _client = api.rest.tasks;

  final TasksClient _client;

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
