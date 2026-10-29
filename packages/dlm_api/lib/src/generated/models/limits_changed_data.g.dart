// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limits_changed_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LimitsChangedData _$LimitsChangedDataFromJson(Map<String, dynamic> json) =>
    LimitsChangedData(
      speedLimit: (json['speedLimit'] as num).toInt(),
      override: json['override'] == null
          ? null
          : SpeedOverride.fromJson(json['override'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LimitsChangedDataToJson(LimitsChangedData instance) =>
    <String, dynamic>{
      'override': instance.override,
      'speedLimit': instance.speedLimit,
    };
