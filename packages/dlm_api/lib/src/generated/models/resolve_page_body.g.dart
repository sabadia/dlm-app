// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_page_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolvePageBody _$ResolvePageBodyFromJson(Map<String, dynamic> json) =>
    ResolvePageBody(
      url: json['url'] as String,
      schema: json[r'$schema'] as String?,
      waitSeconds: (json['waitSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResolvePageBodyToJson(ResolvePageBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'url': instance.url,
      'waitSeconds': instance.waitSeconds,
    };
