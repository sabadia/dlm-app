// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'capture_body_priority.dart';
import 'capture_cookie.dart';
import 'media_candidate_body.dart';
import 'settings.dart';

part 'capture_body.g.dart';

@JsonSerializable()
class CaptureBody {
  const CaptureBody({
    this.schema,
    this.allowDuplicate,
    this.cookies,
    this.dir,
    this.filename,
    this.finalUrl,
    this.headers,
    this.labels,
    this.mediaCandidates,
    this.mime,
    this.pageUrl,
    this.paused,
    this.priority,
    this.queueId,
    this.referrer,
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

  /// Content type the browser saw.
  final String? mime;

  /// Web page the link was found on.
  final String? pageUrl;

  /// Create the task paused instead of queued.
  final bool? paused;
  final CaptureBodyPriority? priority;

  /// Queue ID or name (default: the Main queue).
  final String? queueId;

  /// Referer the browser sent (default pageUrl).
  final String? referrer;

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
