// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timeline _$TimelineFromJson(Map<String, dynamic> json) => Timeline(
  bucket: json['bucket'] as String,
  from: DateTime.parse(json['from'] as String),
  groupBy: json['groupBy'] as String,
  points: (json['points'] as List<dynamic>?)
      ?.map((e) => TimelinePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  to: DateTime.parse(json['to'] as String),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$TimelineToJson(Timeline instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'bucket': instance.bucket,
  'from': instance.from.toIso8601String(),
  'groupBy': instance.groupBy,
  'points': instance.points,
  'to': instance.to.toIso8601String(),
};
