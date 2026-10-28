// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetrySettings _$RetrySettingsFromJson(Map<String, dynamic> json) =>
    RetrySettings(
      initialBackoff: json['initialBackoff'] as String?,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt(),
      maxBackoff: json['maxBackoff'] as String?,
      respectRetryAfter: json['respectRetryAfter'] as bool?,
    );

Map<String, dynamic> _$RetrySettingsToJson(RetrySettings instance) =>
    <String, dynamic>{
      'initialBackoff': instance.initialBackoff,
      'maxAttempts': instance.maxAttempts,
      'maxBackoff': instance.maxBackoff,
      'respectRetryAfter': instance.respectRetryAfter,
    };
