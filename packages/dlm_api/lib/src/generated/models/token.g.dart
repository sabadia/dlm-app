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
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'id': instance.id,
  'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
  'name': instance.name,
  'scope': instance.scope,
};
