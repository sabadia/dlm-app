// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/browser_profiles.dart';
import '../models/download_candidate_body.dart';
import '../models/page_result.dart';
import '../models/resolve_page_body.dart';
import '../models/status.dart';
import '../models/task.dart';

part 'browser_client.g.dart';

@RestApi()
abstract class BrowserClient {
  factory BrowserClient(Dio dio, {String? baseUrl}) = _BrowserClient;

  /// Get the state of the headless browser.
  ///
  /// The browser in use (absent until a page was opened) and the running browsers, one per site group.
  @GET('/v1/browser')
  Future<Status> getBrowserStatus();

  /// List browser profiles.
  ///
  /// Each site group has its own profile, which keeps the logins of the pages opened there.
  @GET('/v1/browser/profiles')
  Future<BrowserProfiles> listBrowserProfiles();

  /// Delete a browser profile.
  ///
  /// Removes the profile (cookies and storage) of a site group. 409 while its browser is running.
  ///
  /// [group] - Site group, as listed by list-browser-profiles.
  @DELETE('/v1/browser/profiles/{group}')
  Future<void> deleteBrowserProfile({@Path('group') required String group});

  /// Open a page in the headless browser and list its downloads.
  ///
  /// Opens the page in the internal headless browser, with the stored cookies of its site, and returns the downloads it led to: HLS and DASH manifests, video and audio files, file downloads and JS-made blob downloads (which the browser saves and the daemon keeps). The cookies the page set are stored. The result and its files are kept for a while: pass its id and a candidate index to download-candidate.
  @POST('/v1/browser/resolve')
  Future<PageResult> resolvePage({@Body() required ResolvePageBody body});

  /// Download a candidate found on a page.
  ///
  /// Creates a task for a candidate of a resolve-page result. Files the browser downloaded itself are imported; other candidates are downloaded from their URL. HLS playlists (.m3u8) are downloaded by the HLS engine; DASH manifests (.mpd) by the DASH engine; a stream whose URL has no .m3u8/.mpd extension is refused (422).
  ///
  /// [id] - resolve-page result ID.
  ///
  /// [index] - Candidate index within the result.
  @POST('/v1/browser/results/{id}/candidates/{index}/download')
  Future<Task> downloadCandidate({
    @Path('id') required String id,
    @Path('index') required int index,
    @Body() required DownloadCandidateBody body,
  });
}
