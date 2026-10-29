// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'media_candidate_body_kind.dart';

part 'media_candidate_body.g.dart';

@JsonSerializable()
class MediaCandidateBody {
  const MediaCandidateBody({
    required this.url,
    this.kind,
    this.mime,
    this.size,
    this.variant,
  });

  factory MediaCandidateBody.fromJson(Map<String, Object?> json) =>
      _$MediaCandidateBodyFromJson(json);

  /// Resource kind; unset counts as file.
  final MediaCandidateBodyKind? kind;
  final String? mime;

  /// Bytes, when known.
  final int? size;

  /// Absolute URL of the resource (manifest or file).
  final String url;

  /// Stream variant such as 1080p; becomes the task's mediaHint.
  final String? variant;

  Map<String, Object?> toJson() => _$MediaCandidateBodyToJson(this);
}
