// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'tool_status_name.dart';
import 'tool_status_source.dart';

part 'tool_status.g.dart';

@JsonSerializable()
class ToolStatus {
  const ToolStatus({
    required this.autoDownload,
    required this.available,
    required this.name,
    this.error,
    this.path,
    this.source,
    this.version,
  });

  factory ToolStatus.fromJson(Map<String, Object?> json) =>
      _$ToolStatusFromJson(json);

  /// Whether dlm downloads the tool when it is missing and needed.
  final bool autoDownload;

  /// Whether a usable build was found (without downloading one).
  final bool available;

  /// Why no usable build was found.
  final String? error;

  /// Which tool.
  final ToolStatusName name;

  /// Executable path.
  final String? path;

  /// Where the build comes from.
  final ToolStatusSource? source;

  /// Version the tool reports, when known.
  final String? version;

  Map<String, Object?> toJson() => _$ToolStatusToJson(this);
}
