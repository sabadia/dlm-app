// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'capture_cookie_same_site.dart';

part 'capture_cookie.g.dart';

@JsonSerializable()
class CaptureCookie {
  const CaptureCookie({
    required this.domain,
    required this.name,
    required this.value,
    this.expiresAt,
    this.hostOnly,
    this.httpOnly,
    this.path,
    this.sameSite,
    this.secure,
  });

  factory CaptureCookie.fromJson(Map<String, Object?> json) =>
      _$CaptureCookieFromJson(json);

  /// Cookie domain; a leading dot is ignored.
  final String domain;

  /// Absent for session cookies.
  final DateTime? expiresAt;

  /// True when only the exact host receives the cookie (no Domain attribute).
  final bool? hostOnly;
  final bool? httpOnly;
  final String name;

  /// Default /.
  final String? path;
  final CaptureCookieSameSite? sameSite;
  final bool? secure;
  final String value;

  Map<String, Object?> toJson() => _$CaptureCookieToJson(this);
}
