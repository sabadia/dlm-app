// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
  done: (json['done'] as num).toInt(),
  end: (json['end'] as num).toInt(),
  index: (json['index'] as num).toInt(),
  start: (json['start'] as num).toInt(),
);

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
  'done': instance.done,
  'end': instance.end,
  'index': instance.index,
  'start': instance.start,
};
