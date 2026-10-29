// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/capture_body.dart';
import '../models/capture_output.dart';

part 'capture_client.g.dart';

@RestApi()
abstract class CaptureClient {
  factory CaptureClient(Dio dio, {String? baseUrl}) = _CaptureClient;

  /// Capture a download from the browser extension.
  ///
  /// Creates a task from a download the browser extension intercepted, keeping the context needed to refresh the link later (original and final URL, page, referrer, headers, user agent, cookie domains, media hint). The request's cookies are stored before the task is queued, so the first request already carries them. The extension's origin must be listed in the server's allowed origins.
  @POST('/v1/capture')
  Future<CaptureOutput> captureDownload({@Body() required CaptureBody body});
}
