// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_changed_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceChangedData _$ResourceChangedDataFromJson(Map<String, dynamic> json) =>
    ResourceChangedData(
      kind: ResourceChangedDataKind.fromJson(json['kind'] as String),
      op: ResourceChangedDataOp.fromJson(json['op'] as String),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$ResourceChangedDataToJson(
  ResourceChangedData instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': _$ResourceChangedDataKindEnumMap[instance.kind]!,
  'op': _$ResourceChangedDataOpEnumMap[instance.op]!,
};

const _$ResourceChangedDataKindEnumMap = {
  ResourceChangedDataKind.category: 'category',
  ResourceChangedDataKind.webhook: 'webhook',
  ResourceChangedDataKind.credential: 'credential',
  ResourceChangedDataKind.cookie: 'cookie',
  ResourceChangedDataKind.plugin: 'plugin',
  ResourceChangedDataKind.config: 'config',
  ResourceChangedDataKind.$unknown: r'$unknown',
};

const _$ResourceChangedDataOpEnumMap = {
  ResourceChangedDataOp.created: 'created',
  ResourceChangedDataOp.updated: 'updated',
  ResourceChangedDataOp.deleted: 'deleted',
  ResourceChangedDataOp.$unknown: r'$unknown',
};
