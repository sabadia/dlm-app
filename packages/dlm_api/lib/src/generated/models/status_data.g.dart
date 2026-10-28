// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusData _$StatusDataFromJson(Map<String, dynamic> json) => StatusData(
  from: json['from'] as String,
  to: json['to'] as String,
  error: json['error'] == null
      ? null
      : TaskError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StatusDataToJson(StatusData instance) =>
    <String, dynamic>{
      'error': instance.error,
      'from': instance.from,
      'to': instance.to,
    };
