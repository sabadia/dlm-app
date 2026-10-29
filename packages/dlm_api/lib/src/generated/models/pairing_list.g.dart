// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingList _$PairingListFromJson(Map<String, dynamic> json) => PairingList(
  pairings: (json['pairings'] as List<dynamic>?)
      ?.map((e) => Pairing.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$PairingListToJson(PairingList instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'pairings': instance.pairings,
    };
