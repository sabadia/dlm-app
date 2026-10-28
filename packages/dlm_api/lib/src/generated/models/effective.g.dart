// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Effective _$EffectiveFromJson(Map<String, dynamic> json) => Effective(
  settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
  sources: Map<String, String>.from(json['sources'] as Map),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$EffectiveToJson(Effective instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'settings': instance.settings,
  'sources': instance.sources,
};
