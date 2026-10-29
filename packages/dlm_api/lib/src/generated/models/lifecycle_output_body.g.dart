// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifecycle_output_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifecycleOutputBody _$LifecycleOutputBodyFromJson(Map<String, dynamic> json) =>
    LifecycleOutputBody(
      status: LifecycleOutputBodyStatus.fromJson(json['status'] as String),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$LifecycleOutputBodyToJson(
  LifecycleOutputBody instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'status': _$LifecycleOutputBodyStatusEnumMap[instance.status]!,
};

const _$LifecycleOutputBodyStatusEnumMap = {
  LifecycleOutputBodyStatus.shuttingDown: 'shutting_down',
  LifecycleOutputBodyStatus.restarting: 'restarting',
  LifecycleOutputBodyStatus.$unknown: r'$unknown',
};
