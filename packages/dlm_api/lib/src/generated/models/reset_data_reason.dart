// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Why the client must refetch its state.
@JsonEnum()
enum ResetDataReason {
  @JsonValue('restart')
  restart('restart'),
  @JsonValue('gap')
  gap('gap'),
  @JsonValue('overflow')
  overflow('overflow'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ResetDataReason(this.json);

  factory ResetDataReason.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<ResetDataReason> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
