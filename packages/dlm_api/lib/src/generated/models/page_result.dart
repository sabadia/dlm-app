// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'candidate.dart';

part 'page_result.g.dart';

@JsonSerializable()
class PageResult {
  const PageResult({
    required this.candidates,
    required this.expiresAt,
    required this.finalUrl,
    required this.group,
    required this.id,
    required this.title,
    required this.url,
    this.schema,
  });

  factory PageResult.fromJson(Map<String, Object?> json) =>
      _$PageResultFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final List<Candidate>? candidates;
  final DateTime expiresAt;
  final String finalUrl;
  final String group;
  final String id;
  final String title;
  final String url;

  Map<String, Object?> toJson() => _$PageResultToJson(this);
}
