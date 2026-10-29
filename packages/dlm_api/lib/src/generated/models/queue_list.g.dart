// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueList _$QueueListFromJson(Map<String, dynamic> json) => QueueList(
  counts: (json['counts'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
  ),
  queues: (json['queues'] as List<dynamic>?)
      ?.map((e) => Queue.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$QueueListToJson(QueueList instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'counts': instance.counts,
  'queues': instance.queues,
};
