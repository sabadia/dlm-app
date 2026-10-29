// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  defaultValue: json['default'],
  key: json['key'] as String,
  readOnly: json['readOnly'] as bool,
  restartRequired: json['restartRequired'] as bool,
  secret: json['secret'] as bool,
  source: json['source'] as String,
  type: json['type'] as String,
  value: json['value'],
  pending: json['pending'],
);

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
  'default': instance.defaultValue,
  'key': instance.key,
  'pending': instance.pending,
  'readOnly': instance.readOnly,
  'restartRequired': instance.restartRequired,
  'secret': instance.secret,
  'source': instance.source,
  'type': instance.type,
  'value': instance.value,
};
