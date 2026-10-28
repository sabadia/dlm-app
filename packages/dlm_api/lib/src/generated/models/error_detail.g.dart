// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetail _$ErrorDetailFromJson(Map<String, dynamic> json) => ErrorDetail(
  location: json['location'] as String?,
  message: json['message'] as String?,
  value: json['value'],
);

Map<String, dynamic> _$ErrorDetailToJson(ErrorDetail instance) =>
    <String, dynamic>{
      'location': instance.location,
      'message': instance.message,
      'value': instance.value,
    };
