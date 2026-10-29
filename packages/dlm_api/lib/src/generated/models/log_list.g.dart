// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogList _$LogListFromJson(Map<String, dynamic> json) => LogList(
  bootId: json['bootId'] as String,
  hasMore: json['hasMore'] as bool,
  lastId: (json['lastId'] as num).toInt(),
  records: (json['records'] as List<dynamic>?)
      ?.map((e) => Record.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$LogListToJson(LogList instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'bootId': instance.bootId,
  'hasMore': instance.hasMore,
  'lastId': instance.lastId,
  'records': instance.records,
};
