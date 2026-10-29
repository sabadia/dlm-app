// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_cookies_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportCookiesResult _$ImportCookiesResultFromJson(Map<String, dynamic> json) =>
    ImportCookiesResult(
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imported: (json['imported'] as num).toInt(),
      skipped: (json['skipped'] as num).toInt(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$ImportCookiesResultToJson(
  ImportCookiesResult instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'errors': instance.errors,
  'imported': instance.imported,
  'skipped': instance.skipped,
};
