// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookieList _$CookieListFromJson(Map<String, dynamic> json) => CookieList(
  cookies: (json['cookies'] as List<dynamic>?)
      ?.map((e) => CookieInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$CookieListToJson(CookieList instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'cookies': instance.cookies};
