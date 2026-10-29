// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_cookie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptureCookie _$CaptureCookieFromJson(Map<String, dynamic> json) =>
    CaptureCookie(
      domain: json['domain'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      hostOnly: json['hostOnly'] as bool?,
      httpOnly: json['httpOnly'] as bool?,
      partitionKey: json['partitionKey'] as String?,
      path: json['path'] as String?,
      sameSite: json['sameSite'] == null
          ? null
          : CaptureCookieSameSite.fromJson(json['sameSite'] as String),
      secure: json['secure'] as bool?,
    );

Map<String, dynamic> _$CaptureCookieToJson(CaptureCookie instance) =>
    <String, dynamic>{
      'domain': instance.domain,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'hostOnly': instance.hostOnly,
      'httpOnly': instance.httpOnly,
      'name': instance.name,
      'partitionKey': instance.partitionKey,
      'path': instance.path,
      'sameSite': _$CaptureCookieSameSiteEnumMap[instance.sameSite],
      'secure': instance.secure,
      'value': instance.value,
    };

const _$CaptureCookieSameSiteEnumMap = {
  CaptureCookieSameSite.lax: 'lax',
  CaptureCookieSameSite.strict: 'strict',
  CaptureCookieSameSite.none: 'none',
  CaptureCookieSameSite.$unknown: r'$unknown',
};
