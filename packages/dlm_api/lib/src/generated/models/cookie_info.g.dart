// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookieInfo _$CookieInfoFromJson(Map<String, dynamic> json) => CookieInfo(
  createdAt: DateTime.parse(json['createdAt'] as String),
  domain: json['domain'] as String,
  hostOnly: json['hostOnly'] as bool,
  httpOnly: json['httpOnly'] as bool,
  id: json['id'] as String,
  name: json['name'] as String,
  path: json['path'] as String,
  secure: json['secure'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  partitionKey: json['partitionKey'] as String?,
  sameSite: json['sameSite'] == null
      ? null
      : CookieInfoSameSite.fromJson(json['sameSite'] as String),
);

Map<String, dynamic> _$CookieInfoToJson(CookieInfo instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'domain': instance.domain,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'hostOnly': instance.hostOnly,
      'httpOnly': instance.httpOnly,
      'id': instance.id,
      'name': instance.name,
      'partitionKey': instance.partitionKey,
      'path': instance.path,
      'sameSite': _$CookieInfoSameSiteEnumMap[instance.sameSite],
      'secure': instance.secure,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CookieInfoSameSiteEnumMap = {
  CookieInfoSameSite.lax: 'lax',
  CookieInfoSameSite.strict: 'strict',
  CookieInfoSameSite.none: 'none',
  CookieInfoSameSite.$unknown: r'$unknown',
};
