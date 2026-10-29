// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'expand_tasks_body.g.dart';

@JsonSerializable()
class ExpandTasksBody {
  const ExpandTasksBody({required this.pattern, this.schema, this.preview});

  factory ExpandTasksBody.fromJson(Map<String, Object?> json) =>
      _$ExpandTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// A URL with ranges: file[001-100].jpg, img[a-e].png, p[1-9][1-3].html; [first-last:step] steps.
  final String pattern;

  /// How many of the URLs to list (default 20); count always has the full number.
  final int? preview;

  Map<String, Object?> toJson() => _$ExpandTasksBodyToJson(this);
}
