// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cookie_info_same_site.dart';

part 'cookie_info.g.dart';

@JsonSerializable()
class CookieInfo {
  const CookieInfo({
    required this.createdAt,
    required this.domain,
    required this.hostOnly,
    required this.httpOnly,
    required this.id,
    required this.name,
    required this.path,
    required this.secure,
    required this.updatedAt,
    this.expiresAt,
    this.partitionKey,
    this.sameSite,
  });

  factory CookieInfo.fromJson(Map<String, Object?> json) =>
      _$CookieInfoFromJson(json);

  final DateTime createdAt;

  /// Domain the cookie was set for, lower-case without a leading dot.
  final String domain;

  /// Absent for session cookies.
  final DateTime? expiresAt;

  /// True when only the exact host receives the cookie, not its subdomains.
  final bool hostOnly;
  final bool httpOnly;

  /// Cookie ID.
  final String id;
  final String name;

  /// Top-level site of a partitioned (CHIPS) cookie; empty for ordinary cookies.
  final String? partitionKey;
  final String path;
  final CookieInfoSameSite? sameSite;
  final bool secure;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$CookieInfoToJson(this);
}
