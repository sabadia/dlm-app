// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_cookies_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportCookiesBody _$ImportCookiesBodyFromJson(Map<String, dynamic> json) =>
    ImportCookiesBody(
      data: json['data'] as String,
      schema: json[r'$schema'] as String?,
      format: json['format'] == null
          ? null
          : ImportCookiesBodyFormat.fromJson(json['format'] as String),
    );

Map<String, dynamic> _$ImportCookiesBodyToJson(ImportCookiesBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'data': instance.data,
      'format': _$ImportCookiesBodyFormatEnumMap[instance.format],
    };

const _$ImportCookiesBodyFormatEnumMap = {
  ImportCookiesBodyFormat.valueJson: 'json',
  ImportCookiesBodyFormat.netscape: 'netscape',
  ImportCookiesBodyFormat.$unknown: r'$unknown',
};
