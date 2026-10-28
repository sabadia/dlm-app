// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credential _$CredentialFromJson(Map<String, dynamic> json) => Credential(
  createdAt: DateTime.parse(json['createdAt'] as String),
  host: json['host'] as String,
  id: json['id'] as String,
  scheme: json['scheme'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  username: json['username'] as String,
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'createdAt': instance.createdAt.toIso8601String(),
      'host': instance.host,
      'id': instance.id,
      'scheme': instance.scheme,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'username': instance.username,
    };
