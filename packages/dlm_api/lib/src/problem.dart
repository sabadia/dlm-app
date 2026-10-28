import 'package:dio/dio.dart';

/// One field-level error of a problem response.
class ProblemDetail {
  /// Creates a detail.
  const ProblemDetail({required this.message, this.location});

  /// What is wrong.
  final String message;

  /// Where, for example `body.maxConnections` or `body.settings.retry.maxAttempts`.
  final String? location;
}

/// A failure of an API call.
sealed class ApiFailure implements Exception {
  const ApiFailure();
}

/// The daemon answered with an RFC 9457 problem. [code] is the stable machine
/// code clients localise (`task.not_found`, `settings.invalid`, ...); [params]
/// are the values of the message.
class ApiProblem extends ApiFailure {
  /// Creates a problem.
  const ApiProblem({
    required this.status,
    required this.code,
    this.title = '',
    this.detail = '',
    this.params = const {},
    this.errors = const [],
  });

  /// Decodes a problem body ([json] may be anything the daemon or a proxy sent).
  factory ApiProblem.fromJson(int status, Object? json) {
    if (json is! Map<String, Object?>) {
      return ApiProblem(status: status, code: _codeForStatus(status));
    }
    final params = json['params'];
    final errors = json['errors'];
    return ApiProblem(
      status: status,
      code: json['code'] is String
          ? json['code']! as String
          : _codeForStatus(status),
      title: json['title'] is String ? json['title']! as String : '',
      detail: json['detail'] is String ? json['detail']! as String : '',
      params: params is Map<String, Object?>
          ? {
              for (final e in params.entries)
                if (e.value is String) e.key: e.value! as String,
            }
          : const {},
      errors: errors is List<Object?>
          ? [
              for (final e in errors)
                if (e is Map<String, Object?> && e['message'] is String)
                  ProblemDetail(
                    message: e['message']! as String,
                    location: e['location'] is String
                        ? e['location']! as String
                        : null,
                  ),
            ]
          : const [],
    );
  }

  /// HTTP status.
  final int status;

  /// Stable machine-readable code.
  final String code;

  /// Short English summary of the status.
  final String title;

  /// English description; a fallback for codes the app does not know.
  final String detail;

  /// Values to put in the localised message.
  final Map<String, String> params;

  /// Field errors of validation failures.
  final List<ProblemDetail> errors;

  /// Whether this is a lost-update refusal (`If-Match` did not match).
  bool get isPreconditionFailed => status == 412;

  @override
  String toString() => 'ApiProblem($status $code: $detail)';
}

/// The daemon could not be reached or the connection broke.
class ApiConnectionFailure extends ApiFailure {
  /// Creates a connection failure.
  const ApiConnectionFailure(this.message, {this.timedOut = false});

  /// What went wrong (never contains credentials).
  final String message;

  /// Whether a timeout caused it.
  final bool timedOut;

  @override
  String toString() => 'ApiConnectionFailure($message)';
}

/// The request was cancelled by the caller.
class ApiCancelled extends ApiFailure {
  /// Creates the failure.
  const ApiCancelled();

  @override
  String toString() => 'ApiCancelled()';
}

/// Turns a [DioException] into an [ApiFailure].
ApiFailure failureOf(DioException e) {
  switch (e.type) {
    case DioExceptionType.cancel:
      return const ApiCancelled();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const ApiConnectionFailure(
        'the daemon did not answer in time',
        timedOut: true,
      );
    case DioExceptionType.badResponse:
      final response = e.response;
      if (response != null) {
        return ApiProblem.fromJson(response.statusCode ?? 0, response.data);
      }
      return const ApiConnectionFailure('the daemon sent no response');
    case DioExceptionType.badCertificate:
      return const ApiConnectionFailure(
        'the daemon certificate is not trusted',
      );
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return ApiConnectionFailure(
        'the daemon is not reachable: ${e.error ?? e.message ?? 'unknown error'}',
      );
  }
}

String _codeForStatus(int status) => switch (status) {
  400 => 'bad_request',
  401 => 'unauthorized',
  403 => 'forbidden',
  404 => 'not_found',
  409 => 'conflict',
  412 => 'settings.changed',
  422 => 'invalid_argument',
  429 => 'rate_limited',
  >= 500 && < 600 => 'server_error',
  _ => 'http_$status',
};
