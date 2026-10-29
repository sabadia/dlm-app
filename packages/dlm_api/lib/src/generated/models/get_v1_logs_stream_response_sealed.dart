// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'record_level.dart';
import 'reset_data_reason.dart';
import 'record.dart';
import 'reset_data.dart';

part 'get_v1_logs_stream_response_sealed.g.dart';

@JsonSerializable(createFactory: false)
sealed class GetV1LogsStreamResponseSealed {
  const GetV1LogsStreamResponseSealed();

  factory GetV1LogsStreamResponseSealed.fromJson(Map<String, dynamic> json) =>
      GetV1LogsStreamResponseSealedDeserializer.tryDeserialize(json);

  Map<String, dynamic> toJson();
}

extension GetV1LogsStreamResponseSealedDeserializer
    on GetV1LogsStreamResponseSealed {
  static GetV1LogsStreamResponseSealed tryDeserialize(
    Map<String, dynamic> json,
  ) {
    try {
      return GetV1LogsStreamResponseSealedRecord.fromJson(json);
    } catch (_) {}
    try {
      return GetV1LogsStreamResponseSealedResetData.fromJson(json);
    } catch (_) {}

    throw FormatException(
      'Could not determine the correct type for GetV1LogsStreamResponseSealed from: $json',
    );
  }
}

@JsonSerializable()
class GetV1LogsStreamResponseSealedRecord extends GetV1LogsStreamResponseSealed
    implements Record {
  @override
  final Map<String, dynamic>? attrs;
  @override
  final int id;
  @override
  final RecordLevel level;
  @override
  final String message;
  @override
  final DateTime time;

  const GetV1LogsStreamResponseSealedRecord({
    required this.attrs,
    required this.id,
    required this.level,
    required this.message,
    required this.time,
  });

  factory GetV1LogsStreamResponseSealedRecord.fromJson(
    Map<String, dynamic> json,
  ) => _$GetV1LogsStreamResponseSealedRecordFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GetV1LogsStreamResponseSealedRecordToJson(this);
}

@JsonSerializable()
class GetV1LogsStreamResponseSealedResetData
    extends GetV1LogsStreamResponseSealed
    implements ResetData {
  @override
  final ResetDataReason reason;

  const GetV1LogsStreamResponseSealedResetData({required this.reason});

  factory GetV1LogsStreamResponseSealedResetData.fromJson(
    Map<String, dynamic> json,
  ) => _$GetV1LogsStreamResponseSealedResetDataFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GetV1LogsStreamResponseSealedResetDataToJson(this);
}
