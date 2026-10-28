// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'export_cookies_result_format.dart';

part 'export_cookies_result.g.dart';

@JsonSerializable()
class ExportCookiesResult {
  const ExportCookiesResult({
    required this.count,
    required this.data,
    required this.format,
    this.schema,
  });

  factory ExportCookiesResult.fromJson(Map<String, Object?> json) =>
      _$ExportCookiesResultFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Cookies in data.
  final int count;

  /// The cookie file content. It contains cookie values: treat it as a secret.
  final String data;
  final ExportCookiesResultFormat format;

  Map<String, Object?> toJson() => _$ExportCookiesResultToJson(this);
}
