// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/native_host_request.dart';
import '../models/native_host_status.dart';
import '../models/result.dart';

part 'native_host_client.g.dart';

@RestApi()
abstract class NativeHostClient {
  factory NativeHostClient(Dio dio, {String? baseUrl}) = _NativeHostClient;

  /// Browser extension host status.
  ///
  /// Whether the Native Messaging host the browser extension talks to is registered with each browser, for the user the daemon runs as. Only from the machine the daemon runs on (403 native_host.local_only otherwise).
  @GET('/v1/native-host')
  Future<NativeHostStatus> getNativeHost();

  /// Register or remove the browser extension host.
  ///
  /// Writes (install) or removes (uninstall) the Native Messaging host registration of the selected browsers, as `dlm native-host install|uninstall` does. The published DLM extension is always registered; extensionIds and firefoxIds add others (another Chromium extension also needs its origin in server.allowed_origins). Only from the machine the daemon runs on (403 native_host.local_only otherwise).
  @POST('/v1/native-host')
  Future<List<Result>?> updateNativeHost({
    @Body() required NativeHostRequest body,
  });
}
