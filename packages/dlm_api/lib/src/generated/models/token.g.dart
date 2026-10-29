// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  createdAt: DateTime.parse(json['createdAt'] as String),
  id: json['id'] as String,
  name: json['name'] as String,
  scope: json['scope'] as String,
  browser: json['browser'] as String?,
  clientId: json['clientId'] as String?,
  clientVersion: json['clientVersion'] as String?,
  kind: json['kind'] as String?,
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'browser': instance.browser,
  'clientId': instance.clientId,
  'clientVersion': instance.clientVersion,
  'createdAt': instance.createdAt.toIso8601String(),
  'id': instance.id,
  'kind': instance.kind,
  'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
  'name': instance.name,
  'scope': instance.scope,
};
