// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cookie_info.dart';

part 'cookie_list.g.dart';

@JsonSerializable()
class CookieList {
  const CookieList({required this.cookies, this.schema});

  factory CookieList.fromJson(Map<String, Object?> json) =>
      _$CookieListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Stored cookies ordered by domain, path and name; values are not included.
  final List<CookieInfo>? cookies;

  Map<String, Object?> toJson() => _$CookieListToJson(this);
}
