// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resource_changed_data_kind.dart';
import 'resource_changed_data_op.dart';

part 'resource_changed_data.g.dart';

@JsonSerializable()
class ResourceChangedData {
  const ResourceChangedData({required this.kind, required this.op, this.id});

  factory ResourceChangedData.fromJson(Map<String, Object?> json) =>
      _$ResourceChangedDataFromJson(json);

  final String? id;
  final ResourceChangedDataKind kind;
  final ResourceChangedDataOp op;

  Map<String, Object?> toJson() => _$ResourceChangedDataToJson(this);
}
