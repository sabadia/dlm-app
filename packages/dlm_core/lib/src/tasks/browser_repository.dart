import 'package:dlm_api/dlm_api.dart';

/// What the app asks of the daemon's headless browser: open a page and list
/// the downloads it leads to, download one of them, and the browser profiles
/// (one per site group, holding that site's logins).
abstract interface class BrowserRepository {
  /// Opens [url] in the browser and returns the downloads it found. The result
  /// is kept by the daemon for a while ([PageResult.expiresAt]).
  Future<PageResult> resolve(String url, {int? waitSeconds});

  /// Creates a task for candidate [index] of the result [resultId].
  Future<Task> download(String resultId, int index);

  /// The site groups that have a browser profile.
  Future<List<String>> profiles();

  /// Deletes the profile (cookies and storage) of [group]; the daemon refuses
  /// while that group's browser runs.
  Future<void> deleteProfile(String group);
}

/// The REST implementation.
class ApiBrowserRepository implements BrowserRepository {
  /// Creates the repository over [api].
  ApiBrowserRepository(DlmApi api) : _api = api, _client = api.rest.browser;

  final DlmApi _api;
  final BrowserClient _client;

  @override
  Future<PageResult> resolve(String url, {int? waitSeconds}) =>
      _api.resolvePage(url, waitSeconds: waitSeconds);

  @override
  Future<Task> download(String resultId, int index) => guard(
    () => _client.downloadCandidate(
      id: resultId,
      index: index,
      body: const DownloadCandidateBody(),
    ),
  );

  @override
  Future<List<String>> profiles() async =>
      (await guard(_client.listBrowserProfiles)).profiles ?? const [];

  @override
  Future<void> deleteProfile(String group) =>
      guard(() => _client.deleteBrowserProfile(group: group));
}
