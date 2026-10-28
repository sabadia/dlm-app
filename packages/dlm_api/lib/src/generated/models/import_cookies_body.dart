// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_cookies_body_format.dart';

part 'import_cookies_body.g.dart';

@JsonSerializable()
class ImportCookiesBody {
  const ImportCookiesBody({required this.data, this.schema, this.format});

  factory ImportCookiesBody.fromJson(Map<String, Object?> json) =>
      _$ImportCookiesBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The cookie file content: a JSON array of cookies (also the export of browser cookie extensions) or a Netscape cookies.txt.
  final String data;

  /// Format of data; detected from the content when absent.
  final ImportCookiesBodyFormat? format;

  Map<String, Object?> toJson() => _$ImportCookiesBodyToJson(this);
}
