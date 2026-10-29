// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expanded_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpandedPattern _$ExpandedPatternFromJson(Map<String, dynamic> json) =>
    ExpandedPattern(
      count: (json['count'] as num).toInt(),
      urls: (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$ExpandedPatternToJson(ExpandedPattern instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'count': instance.count,
      'urls': instance.urls,
    };
