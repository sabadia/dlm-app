// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Problem _$ProblemFromJson(Map<String, dynamic> json) => Problem(
  code: json['code'] as String,
  type: json['type'] as String? ?? 'about:blank',
  schema: json[r'$schema'] as String?,
  detail: json['detail'] as String?,
  errors: (json['errors'] as List<dynamic>?)
      ?.map((e) => ErrorDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  instance: json['instance'] as String?,
  params: (json['params'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  status: (json['status'] as num?)?.toInt(),
  title: json['title'] as String?,
);

Map<String, dynamic> _$ProblemToJson(Problem instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'code': instance.code,
  'detail': instance.detail,
  'errors': instance.errors,
  'instance': instance.instance,
  'params': instance.params,
  'status': instance.status,
  'title': instance.title,
  'type': instance.type,
};
