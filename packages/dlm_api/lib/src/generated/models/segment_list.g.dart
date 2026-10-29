// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentList _$SegmentListFromJson(Map<String, dynamic> json) => SegmentList(
  segments: (json['segments'] as List<dynamic>?)
      ?.map((e) => Segment.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$SegmentListToJson(SegmentList instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'segments': instance.segments,
    };
