// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_requested_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingRequestedData _$PairingRequestedDataFromJson(
  Map<String, dynamic> json,
) => PairingRequestedData(
  browser: json['browser'] as String,
  code: json['code'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  id: json['id'] as String,
  name: json['name'] as String,
  clientId: json['clientId'] as String?,
  clientVersion: json['clientVersion'] as String?,
);

Map<String, dynamic> _$PairingRequestedDataToJson(
  PairingRequestedData instance,
) => <String, dynamic>{
  'browser': instance.browser,
  'clientId': instance.clientId,
  'clientVersion': instance.clientVersion,
  'code': instance.code,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'id': instance.id,
  'name': instance.name,
};
