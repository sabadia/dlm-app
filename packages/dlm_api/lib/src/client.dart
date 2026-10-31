import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'generated/models/page_result.dart';
import 'generated/models/resolve_page_body.dart';
import 'generated/models/task.dart';
import 'generated/rest_client.dart';
import 'problem.dart';
import 'tls_pinning.dart';

/// Where and how to reach one daemon.
class DlmEndpoint {
  /// Creates an endpoint.
  const DlmEndpoint({
    required this.baseUrl,
    this.token,
    this.connectTimeout = const Duration(seconds: 5),
    this.receiveTimeout = const Duration(seconds: 30),
    this.userAgent = 'dlm-app',
    this.adapter,
  });

  /// An endpoint that trusts exactly the certificate with [pin] (see
  /// [pinnedAdapter]).
  factory DlmEndpoint.pinned({
    required String baseUrl,
    required String pin,
    String? token,
    String userAgent = 'dlm-app',
  }) => DlmEndpoint(
    baseUrl: baseUrl,
    token: token,
    userAgent: userAgent,
    adapter: pinnedAdapter(pin),
  );

  /// Base URL, for example `http://127.0.0.1:50321`.
  final String baseUrl;

  /// Bearer token; null for public operations only.
  final String? token;

  /// How long to wait for the connection.
  final Duration connectTimeout;

  /// How long to wait for a response.
  final Duration receiveTimeout;

  /// `User-Agent` header.
  final String userAgent;

  /// HTTP adapter, for TLS pinning (F1.4) and tests.
  final HttpClientAdapter? adapter;
}

final _cancelKey = Object();

/// The daemon's REST API: the generated operations behind a [Dio] that adds
/// the bearer token, applies timeouts, supports cancellation and turns every
/// failure into an [ApiFailure].
///
/// Calls throw [ApiProblem] (the daemon refused), [ApiConnectionFailure]
/// (unreachable, timeout) or [ApiCancelled]. Wrap calls in [cancellable] to
/// cancel them from outside.
class DlmApi {
  /// Creates a client for [endpoint].
  DlmApi(DlmEndpoint endpoint) {
    _dio = _buildDio(endpoint, _etags);
    // After the interceptor above: it sees the failure with the response kept.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) {
          if (err.response?.statusCode == 401) onUnauthorized?.call();
          handler.next(err);
        },
      ),
    );
    rest = RestClient(_dio);
  }

  /// Called when the daemon answers 401: the token this client holds is no
  /// longer valid (it was rotated or revoked while the app was running).
  void Function()? onUnauthorized;

  late final Dio _dio;
  final _etags = <String, String>{};

  /// The `ETag` the daemon last sent for [path] (for example `/v1/settings`).
  /// The generated operations return bodies only; send this as `If-Match` to
  /// make an update fail with 412 when somebody else changed the resource.
  String? etagFor(String path) => _etags[path];

  /// The generated operations, grouped by tag (`rest.tasks.getTask(...)`).
  late final RestClient rest;

  /// The Dio underneath, for the event stream reader and tests.
  Dio get dio => _dio;

  /// Runs [body]; every API call it starts is cancelled when [token] is.
  Future<T> cancellable<T>(CancelToken token, Future<T> Function() body) {
    return runZoned(body, zoneValues: {_cancelKey: token});
  }

  /// Creates a task from the bytes of a `.torrent` file (`POST /v1/tasks/torrent`,
  /// up to 16 MiB). The generated operation takes a `dart:io` file; the app has
  /// the bytes already, and a `data:` link in a JSON body is limited to 1 MiB.
  Future<Task> addTorrentBytes(
    Uint8List bytes, {
    String? queueId,
    String? name,
    String? dir,
    bool paused = false,
    bool allowDuplicate = false,
  }) => guard(() async {
    final response = await _dio.post<Map<String, Object?>>(
      '/v1/tasks/torrent',
      data: Stream<List<int>>.value(bytes),
      queryParameters: {
        'queueId': ?queueId,
        'name': ?name,
        'dir': ?dir,
        if (paused) 'paused': true,
        if (allowDuplicate) 'allowDuplicate': true,
      },
      options: Options(
        contentType: 'application/x-bittorrent',
        headers: {Headers.contentLengthHeader: bytes.length},
        sendTimeout: const Duration(minutes: 2),
      ),
    );
    return Task.fromJson(response.data!);
  });

  /// Opens a page in the daemon's headless browser (`POST /v1/browser/resolve`).
  /// The daemon may take twice [waitSeconds] (the page settles, then the
  /// downloads do) plus the browser's start-up, which is longer than the
  /// receive timeout of an ordinary call, so this one waits as long as needed.
  Future<PageResult> resolvePage(String url, {int? waitSeconds}) =>
      guard(() async {
        final wait = waitSeconds ?? 20;
        final response = await _dio.post<Map<String, Object?>>(
          '/v1/browser/resolve',
          data: ResolvePageBody(url: url, waitSeconds: waitSeconds).toJson(),
          options: Options(receiveTimeout: Duration(seconds: wait * 2 + 30)),
        );
        return PageResult.fromJson(response.data!);
      });

  /// Releases the connections.
  void close({bool force = false}) => _dio.close(force: force);

  static Dio _buildDio(DlmEndpoint e, Map<String, String> etags) {
    final dio = Dio(
      BaseOptions(
        baseUrl: e.baseUrl,
        connectTimeout: e.connectTimeout,
        receiveTimeout: e.receiveTimeout,
        headers: {'User-Agent': e.userAgent, 'Accept': 'application/json'},
        // Problem bodies are JSON too; let Dio decode them.
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
    if (e.adapter != null) dio.httpClientAdapter = e.adapter!;
    final token = e.token;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.cancelToken ??= Zone.current[_cancelKey] as CancelToken?;
          handler.next(options);
        },
        onResponse: (response, handler) {
          final etag = response.headers.value('etag');
          if (etag != null && response.requestOptions.method == 'GET') {
            etags[response.requestOptions.path] = etag;
          }
          handler.next(response);
        },
        onError: (err, handler) {
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: failureOf(err),
              message: err.message,
            ),
          );
        },
      ),
    );
    return dio;
  }
}

/// Runs an API call and throws only [ApiFailure]s.
///
/// Generated clients throw [DioException]; the interceptor stores the decoded
/// failure in [DioException.error]. Use this around every call:
/// `await guard(() => api.rest.tasks.getTask(id: id))`.
Future<T> guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final inner = e.error;
    throw inner is ApiFailure ? inner : failureOf(e);
  }
}
