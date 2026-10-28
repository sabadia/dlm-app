import 'package:dlm_api/dlm_api.dart';

/// Where a failure is shown. One policy for the whole app:
///
/// * [toast]: a passing notice for something that did not work, no action
///   needed (a download that is gone, a refused move);
/// * [banner]: a state of the connection, stays until it is over;
/// * [dialog]: needs a decision (login rejected, settings changed elsewhere);
/// * [field]: belongs next to the input that caused it.
enum Surface {
  /// Passing notice.
  toast,

  /// Persistent strip.
  banner,

  /// Blocking decision.
  dialog,

  /// Next to a form field.
  field,
}

/// What to tell the user about a failure, in terms the UI can localise.
class FailurePresentation {
  /// Creates a presentation.
  const FailurePresentation({
    required this.messageKey,
    required this.surface,
    this.params = const {},
    this.fallback = '',
    this.fieldErrors = const {},
    this.retryable = false,
  });

  /// Identifies the message: a daemon problem code from
  /// [knownProblemCodes], or an app-defined key (`connection.lost`).
  final String messageKey;

  /// Where to show it.
  final Surface surface;

  /// Values for the message (`{id}`, `{status}`).
  final Map<String, String> params;

  /// The daemon's English text, shown when the app has no message for
  /// [messageKey] (a code a newer daemon introduced).
  final String fallback;

  /// For [Surface.field]: messages by settings path (`retry.maxAttempts`),
  /// in the daemon's English; the form shows them under the fields.
  final Map<String, List<String>> fieldErrors;

  /// Whether trying again may help (connection trouble, daemon busy).
  final bool retryable;
}

/// Problem codes the app has a message for. A test in the app checks that each
/// one is localised; the daemon documents them in docs/API.md.
const knownProblemCodes = <String>{
  // Not found, one per kind of entity.
  'task.not_found',
  'queue.not_found',
  'category.not_found',
  'webhook.not_found',
  'credential.not_found',
  'plugin.not_found',
  'cookie.not_found',
  'engine.not_found',
  'browser_profile.not_found',
  'browser_result.not_found',
  'browser_candidate.not_found',
  'refresh_attempt.not_found',
  'resolve_result.not_found',
  // Conflicts.
  'queue.name_taken',
  'category.name_taken',
  'queue.not_empty',
  'task.duplicate',
  'task.file_exists',
  'task.invalid_state',
  'task.invalid_transition',
  'task.locked',
  'task.state_changed',
  'browser.running',
  // Input.
  'category.bad_dir',
  'settings.invalid',
  'validation_failed',
  'invalid_argument',
  // The daemon and its surroundings.
  'settings.changed',
  'browser.unavailable',
  'origin.failed',
  'request.cancelled',
  'service.unavailable',
  // Generic, by status.
  'bad_request',
  'unauthorized',
  'forbidden',
  'not_found',
  'conflict',
  'precondition_failed',
  'too_many_requests',
  'server_error',
};

/// Message keys the app itself defines (not daemon codes).
const appFailureKeys = <String>{
  'connection.lost',
  'connection.timeout',
  'connection.certificate',
  'unknown',
};

/// Decides what to show for [error], or null when nothing should be shown
/// (the user cancelled).
FailurePresentation? presentFailure(Object error) {
  switch (error) {
    case ApiCancelled():
      return null;
    case ApiConnectionFailure(:final message, :final timedOut):
      final cert = message.contains('certificate');
      return FailurePresentation(
        messageKey: cert
            ? 'connection.certificate'
            : timedOut
            ? 'connection.timeout'
            : 'connection.lost',
        surface: Surface.banner,
        fallback: message,
        retryable: !cert,
      );
    case ApiProblem():
      return _problem(error);
    default:
      return const FailurePresentation(
        messageKey: 'unknown',
        surface: Surface.toast,
      );
  }
}

FailurePresentation _problem(ApiProblem p) {
  final key = knownProblemCodes.contains(p.code) ? p.code : _byStatus(p.status);
  final fields = fieldErrorsOf(p);
  if (fields.isNotEmpty) {
    return FailurePresentation(
      messageKey: key,
      surface: Surface.field,
      params: p.params,
      fallback: p.detail,
      fieldErrors: fields,
    );
  }
  final surface = switch (p.status) {
    401 || 403 || 412 => Surface.dialog,
    >= 500 => Surface.banner,
    _ => Surface.toast,
  };
  return FailurePresentation(
    messageKey: key,
    surface: surface,
    params: p.params,
    fallback: p.detail.isEmpty ? p.title : p.detail,
    retryable: p.status >= 500 || p.code == 'service.unavailable',
  );
}

String _byStatus(int status) => switch (status) {
  400 => 'bad_request',
  401 => 'unauthorized',
  403 => 'forbidden',
  404 => 'not_found',
  409 => 'conflict',
  412 => 'precondition_failed',
  422 => 'invalid_argument',
  429 => 'too_many_requests',
  >= 500 => 'server_error',
  _ => 'unknown',
};

/// The field errors of a validation failure, by settings path.
///
/// The daemon locates them as `body.maxConnections` or, for queue and task
/// bodies, `body.settings.retry.maxAttempts`; both become the path of the
/// field in the settings form (`maxConnections`, `retry.maxAttempts`).
Map<String, List<String>> fieldErrorsOf(ApiProblem p) {
  final out = <String, List<String>>{};
  for (final e in p.errors) {
    final loc = e.location;
    if (loc == null) continue;
    final path = normalizeLocation(loc);
    if (path.isEmpty) continue;
    out.putIfAbsent(path, () => []).add(e.message);
  }
  return out;
}

/// `body.settings.retry.maxAttempts` -> `retry.maxAttempts`.
String normalizeLocation(String location) {
  var path = location;
  for (final prefix in const ['body.settings.', 'body.']) {
    if (path.startsWith(prefix)) {
      path = path.substring(prefix.length);
      break;
    }
  }
  return path == 'body' || path == 'body.settings' ? '' : path;
}
