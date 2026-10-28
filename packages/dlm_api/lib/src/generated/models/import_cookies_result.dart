// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'import_cookies_result.g.dart';

@JsonSerializable()
class ImportCookiesResult {
  const ImportCookiesResult({
    required this.errors,
    required this.imported,
    required this.skipped,
    this.schema,
  });

  factory ImportCookiesResult.fromJson(Map<String, Object?> json) =>
      _$ImportCookiesResultFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// One entry per rejected cookie, naming its position and the reason.
  final List<String>? errors;

  /// Cookies stored (new or replacing an existing one).
  final int imported;

  /// Valid cookies that were already expired.
  final int skipped;

  Map<String, Object?> toJson() => _$ImportCookiesResultToJson(this);
}
