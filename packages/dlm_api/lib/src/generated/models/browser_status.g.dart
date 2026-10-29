// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrowserStatus _$BrowserStatusFromJson(Map<String, dynamic> json) =>
    BrowserStatus(
      max: (json['max'] as num).toInt(),
      running: (json['running'] as List<dynamic>?)
          ?.map((e) => Running.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
      browser: json['browser'] == null
          ? null
          : Installation.fromJson(json['browser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BrowserStatusToJson(BrowserStatus instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'browser': instance.browser,
      'max': instance.max,
      'running': instance.running,
    };
