// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_checksum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptureChecksum _$CaptureChecksumFromJson(Map<String, dynamic> json) =>
    CaptureChecksum(
      algorithm: CaptureChecksumAlgorithm.fromJson(json['algorithm'] as String),
      expected: json['expected'] as String,
    );

Map<String, dynamic> _$CaptureChecksumToJson(CaptureChecksum instance) =>
    <String, dynamic>{
      'algorithm': _$CaptureChecksumAlgorithmEnumMap[instance.algorithm]!,
      'expected': instance.expected,
    };

const _$CaptureChecksumAlgorithmEnumMap = {
  CaptureChecksumAlgorithm.md5: 'md5',
  CaptureChecksumAlgorithm.sha1: 'sha1',
  CaptureChecksumAlgorithm.sha256: 'sha256',
  CaptureChecksumAlgorithm.blake3: 'blake3',
  CaptureChecksumAlgorithm.$unknown: r'$unknown',
};
