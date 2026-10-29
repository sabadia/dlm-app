// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'candidate.g.dart';

@JsonSerializable()
class Candidate {
  const Candidate({
    required this.foundAt,
    required this.index,
    required this.kind,
    required this.size,
    required this.source,
    required this.url,
    this.file,
    this.filename,
    this.headers,
    this.mime,
    this.page,
  });

  factory Candidate.fromJson(Map<String, Object?> json) =>
      _$CandidateFromJson(json);

  final String? file;
  final String? filename;
  final DateTime foundAt;
  final Map<String, String>? headers;
  final int index;
  final String kind;
  final String? mime;
  final String? page;
  final int size;
  final String source;
  final String url;

  Map<String, Object?> toJson() => _$CandidateToJson(this);
}
