// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'capture_body_cookie_scope.dart';
import 'capture_body_priority.dart';
import 'capture_body_resolver_kind.dart';
import 'capture_checksum.dart';
import 'capture_cookie.dart';
import 'media_candidate_body.dart';
import 'settings.dart';

part 'capture_body.g.dart';

@JsonSerializable()
class CaptureBody {
  const CaptureBody({
    this.schema,
    this.allowDuplicate,
    this.body,
    this.checksum,
    this.cookieScope,
    this.cookies,
    this.dir,
    this.filename,
    this.finalUrl,
    this.headers,
    this.labels,
    this.mediaCandidates,
    this.method,
    this.mime,
    this.mirrors,
    this.name,
    this.pageUrl,
    this.paused,
    this.priority,
    this.queueId,
    this.referrer,
    this.resolverKind,
    this.settings,
    this.size,
    this.url,
    this.userAgent,
  });

  factory CaptureBody.fromJson(Map<String, Object?> json) =>
      _$CaptureBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Add the task even when another task has the same link; otherwise it is refused with 409.
  final bool? allowDuplicate;

  /// Request body for a non-GET method, base64; at most 256 KiB.
  final String? body;

  /// The hash the file should have; the task fails and re-downloads on a mismatch (task setting checksum).
  final CaptureChecksum? checksum;

  /// task keeps the cookies for this download only (they are not in the cookie store and are removed when the task completes or is deleted, or after 7 days); store adds them to the cookie store like cookies/import. Default: task for a browser-extension token, store for any other.
  final CaptureBodyCookieScope? cookieScope;

  /// Cookies for the download; stored in the cookie store before the task is queued.
  final List<CaptureCookie>? cookies;

  /// Absolute download directory.
  final String? dir;

  /// File name chosen by the browser (directories are dropped).
  final String? filename;

  /// URL after the browser followed redirects; this is what is downloaded.
  final String? finalUrl;

  /// Request headers to repeat; Cookie and Host are ignored.
  final Map<String, String>? headers;
  final Map<String, String>? labels;

  /// Media found on the page. Selects the download when url is absent; when url equals a candidate its variant, mime and size fill in what the request omits.
  final List<MediaCandidateBody>? mediaCandidates;

  /// HTTP method; default GET. For a form that answers with a file.
  final String? method;

  /// Content type the browser saw.
  final String? mime;

  /// Other http(s) links to the same file.
  final List<String>? mirrors;

  /// File name for the task; wins over filename.
  final String? name;

  /// Web page the link was found on.
  final String? pageUrl;

  /// Create the task paused instead of queued.
  final bool? paused;
  final CaptureBodyPriority? priority;

  /// Queue ID or name (default: the Main queue).
  final String? queueId;

  /// Referer the browser sent (default pageUrl).
  final String? referrer;

  /// How the link is turned into a download: direct (a file, the default), ytdlp (a video or audio page yt-dlp can extract) or browser (a page that needs the headless browser).
  final CaptureBodyResolverKind? resolverKind;

  /// Task-level settings overrides.
  final Settings? settings;

  /// Size in bytes the browser saw.
  final int? size;

  /// Link the user clicked; becomes the task's originalUrl. May be omitted when mediaCandidates is set: the best candidate is then downloaded (hls, dash, video, audio, file; larger first).
  final String? url;

  /// User agent the browser used.
  final String? userAgent;

  Map<String, Object?> toJson() => _$CaptureBodyToJson(this);
}
