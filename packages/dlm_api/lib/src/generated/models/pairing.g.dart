// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pairing _$PairingFromJson(Map<String, dynamic> json) => Pairing(
  browser: json['browser'] as String,
  code: json['code'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  id: json['id'] as String,
  name: json['name'] as String,
  status: json['status'] as String,
  schema: json[r'$schema'] as String?,
  clientId: json['clientId'] as String?,
  clientVersion: json['clientVersion'] as String?,
  tokenId: json['tokenId'] as String?,
);

Map<String, dynamic> _$PairingToJson(Pairing instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'browser': instance.browser,
  'clientId': instance.clientId,
  'clientVersion': instance.clientVersion,
  'code': instance.code,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'id': instance.id,
  'name': instance.name,
  'status': instance.status,
  'tokenId': instance.tokenId,
};
