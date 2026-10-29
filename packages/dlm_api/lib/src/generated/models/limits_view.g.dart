// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limits_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LimitsView _$LimitsViewFromJson(Map<String, dynamic> json) => LimitsView(
  global: ScopeLimits.fromJson(json['global'] as Map<String, dynamic>),
  queues: (json['queues'] as List<dynamic>?)
      ?.map((e) => ScopeLimits.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
  override: json['override'] == null
      ? null
      : SpeedOverride.fromJson(json['override'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LimitsViewToJson(LimitsView instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'global': instance.global,
      'override': instance.override,
      'queues': instance.queues,
    };
