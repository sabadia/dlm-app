// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueList _$QueueListFromJson(Map<String, dynamic> json) => QueueList(
  queues: (json['queues'] as List<dynamic>?)
      ?.map((e) => Queue.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$QueueListToJson(QueueList instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'queues': instance.queues,
};
