// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// What to do when the new link serves different content than the one downloaded so far: restart discards the partial data, fail rejects the link. Default: the task's effective refresh.onMismatch (ask counts as fail).
@JsonEnum()
enum UpdateTaskSourceBodyOnMismatch {
  @JsonValue('restart')
  restart('restart'),
  @JsonValue('fail')
  fail('fail'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const UpdateTaskSourceBodyOnMismatch(this.json);

  factory UpdateTaskSourceBodyOnMismatch.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<UpdateTaskSourceBodyOnMismatch> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
