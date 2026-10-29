// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveResult _$ResolveResultFromJson(Map<String, dynamic> json) =>
    ResolveResult(
      engine: json['engine'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      name: json['name'] as String,
      resolveId: json['resolveId'] as String,
      resource: Resource.fromJson(json['resource'] as Map<String, dynamic>),
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      schema: json[r'$schema'] as String?,
      duplicateOf: json['duplicateOf'] == null
          ? null
          : DuplicateHint.fromJson(json['duplicateOf'] as Map<String, dynamic>),
      formats: (json['formats'] as List<dynamic>?)
          ?.map((e) => Format.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$ResolveResultToJson(ResolveResult instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'duplicateOf': instance.duplicateOf,
      'engine': instance.engine,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'formats': instance.formats?.map((e) => _$FormatEnumMap[e]!).toList(),
      'name': instance.name,
      'resolveId': instance.resolveId,
      'resource': instance.resource,
      'source': instance.source,
    };

const _$FormatEnumMap = {
  Format.valueJson: 'json',
  Format.netscape: 'netscape',
  Format.$unknown: r'$unknown',
};
