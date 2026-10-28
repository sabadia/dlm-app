// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_cookies_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteCookiesResult _$DeleteCookiesResultFromJson(Map<String, dynamic> json) =>
    DeleteCookiesResult(
      deleted: (json['deleted'] as num).toInt(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$DeleteCookiesResultToJson(
  DeleteCookiesResult instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'deleted': instance.deleted,
};
