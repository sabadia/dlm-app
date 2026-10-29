import 'package:dlm_api/dlm_api.dart';

/// What the app asks of the daemon about traffic and old downloads.
abstract interface class StatsRepository {
  /// Bytes downloaded and uploaded per [bucket] (UTC hour or day), split by
  /// [groupBy], over the default range of the bucket size.
  Future<Timeline> timeline(Bucket bucket, GroupBy groupBy);

  /// Removes (or with [dryRun] only counts) the completed downloads that
  /// finished at least [olderThanDays] days ago; with [files] their files go
  /// too.
  Future<CleanupResult> cleanup({
    required int olderThanDays,
    bool files = false,
    bool dryRun = false,
    String? queueId,
  });
}

/// The REST implementation.
class ApiStatsRepository implements StatsRepository {
  /// Creates the repository over [api].
  ApiStatsRepository(DlmApi api) : _client = api.rest.tasks;

  final TasksClient _client;

  @override
  Future<Timeline> timeline(Bucket bucket, GroupBy groupBy) =>
      guard(() => _client.getStatsTimeline(bucket: bucket, groupBy: groupBy));

  @override
  Future<CleanupResult> cleanup({
    required int olderThanDays,
    bool files = false,
    bool dryRun = false,
    String? queueId,
  }) => guard(
    () => _client.cleanupTasks(
      body: CleanupTasksBody(
        olderThanDays: olderThanDays,
        files: files ? true : null,
        dryRun: dryRun ? true : null,
        queueId: queueId,
      ),
    ),
  );
}
