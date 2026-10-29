import 'package:dlm_api/dlm_api.dart';

/// What the app asks of the daemon about a task's link: renew it, wait for a
/// new one, replace it by hand, and what was tried before.
abstract interface class RefreshRepository {
  /// Tries to get a fresh link now.
  Future<Task> refresh(String id);

  /// Puts the task in the state of waiting for a link (one is supplied by the
  /// browser extension or by hand).
  Future<Task> awaitLink(String id);

  /// Replaces the link by hand; the daemon checks it against the task's
  /// fingerprint and, on a mismatch, restarts or fails as [onMismatch] says.
  /// The task has to be paused (409 otherwise).
  Future<Task> setLink(
    String id,
    String url, {
    UpdateTaskSourceBodyOnMismatch? onMismatch,
  });

  /// The attempts to renew the link, newest first as the daemon lists them.
  Future<List<RefreshAttempt>> history(String id);
}

/// The REST implementation.
class ApiRefreshRepository implements RefreshRepository {
  /// Creates the repository over [api].
  ApiRefreshRepository(DlmApi api) : _client = api.rest.refresh;

  final RefreshClient _client;

  @override
  Future<Task> refresh(String id) => guard(() => _client.refreshTask(id: id));

  @override
  Future<Task> awaitLink(String id) =>
      guard(() => _client.awaitTaskLink(id: id));

  @override
  Future<Task> setLink(
    String id,
    String url, {
    UpdateTaskSourceBodyOnMismatch? onMismatch,
  }) => guard(
    () => _client.updateTaskSource(
      id: id,
      body: UpdateTaskSourceBody(currentUrl: url, onMismatch: onMismatch),
    ),
  );

  @override
  Future<List<RefreshAttempt>> history(String id) async {
    final out = await guard(() => _client.listTaskRefreshes(id: id));
    return out.attempts ?? const [];
  }
}
