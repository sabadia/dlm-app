// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'resolve_page_body.g.dart';

@JsonSerializable()
class ResolvePageBody {
  const ResolvePageBody({required this.url, this.schema, this.waitSeconds});

  factory ResolvePageBody.fromJson(Map<String, Object?> json) =>
      _$ResolvePageBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Absolute http(s) URL of the page to open.
  final String url;

  /// How long the page may keep producing downloads before it counts as settled (default 20).
  final int? waitSeconds;

  Map<String, Object?> toJson() => _$ResolvePageBodyToJson(this);
}
