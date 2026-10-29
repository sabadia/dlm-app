// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class Entry {
  const Entry({
    required this.defaultValue,
    required this.key,
    required this.readOnly,
    required this.restartRequired,
    required this.secret,
    required this.source,
    required this.type,
    required this.value,
    this.pending,
  });

  factory Entry.fromJson(Map<String, Object?> json) => _$EntryFromJson(json);

  /// The name has been replaced because it contains a keyword. Original name: `default`.
  @JsonKey(name: 'default')
  final dynamic defaultValue;
  final String key;
  final dynamic pending;
  final bool readOnly;
  final bool restartRequired;
  final bool secret;
  final String source;
  final String type;
  final dynamic value;

  Map<String, Object?> toJson() => _$EntryToJson(this);
}
