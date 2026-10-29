// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshSettings _$RefreshSettingsFromJson(Map<String, dynamic> json) =>
    RefreshSettings(
      auto: json['auto'] as bool?,
      awaitTimeout: json['awaitTimeout'] as String?,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt(),
      onMismatch: json['onMismatch'] as String?,
      strategies: (json['strategies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RefreshSettingsToJson(RefreshSettings instance) =>
    <String, dynamic>{
      'auto': instance.auto,
      'awaitTimeout': instance.awaitTimeout,
      'maxAttempts': instance.maxAttempts,
      'onMismatch': instance.onMismatch,
      'strategies': instance.strategies,
    };
