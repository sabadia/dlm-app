// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'error_detail.g.dart';

@JsonSerializable()
class ErrorDetail {
  const ErrorDetail({this.location, this.message, this.value});

  factory ErrorDetail.fromJson(Map<String, Object?> json) =>
      _$ErrorDetailFromJson(json);

  /// Where the error occurred, e.g. 'body.items[3].tags' or 'path.thing-id'
  final String? location;

  /// Error message text
  final String? message;

  /// The value at the given location
  final dynamic value;

  Map<String, Object?> toJson() => _$ErrorDetailToJson(this);
}
