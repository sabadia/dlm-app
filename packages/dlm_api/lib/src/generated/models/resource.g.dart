// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resource _$ResourceFromJson(Map<String, dynamic> json) => Resource(
  name: json['name'] as String,
  rangeSupported: json['rangeSupported'] as bool,
  size: (json['size'] as num).toInt(),
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => File.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ResourceToJson(Resource instance) => <String, dynamic>{
  'files': instance.files,
  'name': instance.name,
  'rangeSupported': instance.rangeSupported,
  'size': instance.size,
};
