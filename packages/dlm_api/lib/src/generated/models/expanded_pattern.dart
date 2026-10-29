// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'expanded_pattern.g.dart';

@JsonSerializable()
class ExpandedPattern {
  const ExpandedPattern({required this.count, required this.urls, this.schema});

  factory ExpandedPattern.fromJson(Map<String, Object?> json) =>
      _$ExpandedPatternFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// How many URLs the pattern stands for (a pattern without ranges: 1).
  final int count;

  /// The first URLs, up to preview.
  final List<String>? urls;

  Map<String, Object?> toJson() => _$ExpandedPatternToJson(this);
}
