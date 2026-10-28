// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

File _$FileFromJson(Map<String, dynamic> json) => File(
  index: (json['index'] as num).toInt(),
  name: json['name'] as String,
  selected: json['selected'] as bool,
  size: (json['size'] as num).toInt(),
  path: json['path'] as String?,
);

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
  'index': instance.index,
  'name': instance.name,
  'path': instance.path,
  'selected': instance.selected,
  'size': instance.size,
};
