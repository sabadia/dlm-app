// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_task_files_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTaskFilesBody _$SetTaskFilesBodyFromJson(Map<String, dynamic> json) =>
    SetTaskFilesBody(
      selected: (json['selected'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$SetTaskFilesBodyToJson(SetTaskFilesBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'selected': instance.selected,
    };
