// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResult _$PageResultFromJson(Map<String, dynamic> json) => PageResult(
  candidates: (json['candidates'] as List<dynamic>?)
      ?.map((e) => Candidate.fromJson(e as Map<String, dynamic>))
      .toList(),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  finalUrl: json['finalUrl'] as String,
  group: json['group'] as String,
  id: json['id'] as String,
  title: json['title'] as String,
  url: json['url'] as String,
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$PageResultToJson(PageResult instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'candidates': instance.candidates,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'finalUrl': instance.finalUrl,
      'group': instance.group,
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
    };
