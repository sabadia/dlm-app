import 'package:dlm_api/dlm_api.dart';

/// What the app asks of the daemon for the inspector of one task: how its
/// file is split, the swarm of a torrent, and which files are downloaded.
abstract interface class TaskDetailRepository {
  /// The byte ranges of the download and how much of each is done; empty for
  /// engines that do not split the file.
  Future<List<Segment>> segments(String id);

  /// The swarm of a torrent task; null when the task is not a torrent or has
  /// not run yet (404 `task.no_torrent`).
  Future<TorrentInfo?> torrent(String id);

  /// Chooses the files (by index) that are downloaded. The task has to be
  /// paused or not yet started (409 `task.files_locked` otherwise).
  Future<Task> setFiles(String id, List<int> selected);
}

/// The REST implementation.
class ApiTaskDetailRepository implements TaskDetailRepository {
  /// Creates the repository over [api].
  ApiTaskDetailRepository(DlmApi api) : _client = api.rest.tasks;

  final TasksClient _client;

  @override
  Future<List<Segment>> segments(String id) async {
    final out = await guard(() => _client.listTaskSegments(id: id));
    return out.segments ?? const [];
  }

  @override
  Future<TorrentInfo?> torrent(String id) async {
    try {
      return await guard(() => _client.getTaskTorrent(id: id));
    } on ApiProblem catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Task> setFiles(String id, List<int> selected) => guard(
    () => _client.updateTaskFiles(
      id: id,
      body: SetTaskFilesBody(selected: selected),
    ),
  );
}
