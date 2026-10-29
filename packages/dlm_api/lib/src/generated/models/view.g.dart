// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

View _$ViewFromJson(Map<String, dynamic> json) => View(
  entries: (json['entries'] as List<dynamic>?)
      ?.map((e) => Entry.fromJson(e as Map<String, dynamic>))
      .toList(),
  file: json['file'] as String,
  fileExists: json['fileExists'] as bool,
  restartPending: json['restartPending'] as bool,
  schema: json[r'$schema'] as String?,
  fileError: json['fileError'] as String?,
);

Map<String, dynamic> _$ViewToJson(View instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'entries': instance.entries,
  'file': instance.file,
  'fileError': instance.fileError,
  'fileExists': instance.fileExists,
  'restartPending': instance.restartPending,
};
