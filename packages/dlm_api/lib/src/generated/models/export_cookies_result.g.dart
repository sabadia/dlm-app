// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_cookies_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportCookiesResult _$ExportCookiesResultFromJson(Map<String, dynamic> json) =>
    ExportCookiesResult(
      count: (json['count'] as num).toInt(),
      data: json['data'] as String,
      format: ExportCookiesResultFormat.fromJson(json['format'] as String),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$ExportCookiesResultToJson(
  ExportCookiesResult instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'count': instance.count,
  'data': instance.data,
  'format': _$ExportCookiesResultFormatEnumMap[instance.format]!,
};

const _$ExportCookiesResultFormatEnumMap = {
  ExportCookiesResultFormat.valueJson: 'json',
  ExportCookiesResultFormat.netscape: 'netscape',
  ExportCookiesResultFormat.$unknown: r'$unknown',
};
