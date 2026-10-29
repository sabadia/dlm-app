// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveItem _$ResolveItemFromJson(Map<String, dynamic> json) => ResolveItem(
  ok: json['ok'] as bool,
  error: json['error'] == null
      ? null
      : Problem.fromJson(json['error'] as Map<String, dynamic>),
  result: json['result'] == null
      ? null
      : ResolveResult.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ResolveItemToJson(ResolveItem instance) =>
    <String, dynamic>{
      'error': instance.error,
      'ok': instance.ok,
      'result': instance.result,
    };
