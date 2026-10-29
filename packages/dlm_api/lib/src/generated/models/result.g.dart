// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
  browser: json['browser'] as String,
  status: json['status'] as String,
  manifest: json['manifest'] as String?,
  reason: json['reason'] as String?,
  registry: json['registry'] as String?,
);

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
  'browser': instance.browser,
  'manifest': instance.manifest,
  'reason': instance.reason,
  'registry': instance.registry,
  'status': instance.status,
};
