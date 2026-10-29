// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleanup_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CleanupResult _$CleanupResultFromJson(Map<String, dynamic> json) =>
    CleanupResult(
      bytes: (json['bytes'] as num).toInt(),
      deleted: (json['deleted'] as num).toInt(),
      failed: (json['failed'] as num).toInt(),
      matched: (json['matched'] as num).toInt(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$CleanupResultToJson(CleanupResult instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'bytes': instance.bytes,
      'deleted': instance.deleted,
      'failed': instance.failed,
      'matched': instance.matched,
    };
