// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'delete_cookies_result.g.dart';

@JsonSerializable()
class DeleteCookiesResult {
  const DeleteCookiesResult({required this.deleted, this.schema});

  factory DeleteCookiesResult.fromJson(Map<String, Object?> json) =>
      _$DeleteCookiesResultFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Number of cookies removed.
  final int deleted;

  Map<String, Object?> toJson() => _$DeleteCookiesResultToJson(this);
}
