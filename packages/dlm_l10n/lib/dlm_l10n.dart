import 'src/generated/app_localizations.dart';

export 'package:flutter_localizations/flutter_localizations.dart';

export 'src/generated/app_localizations.dart';

/// The localised text for a problem or failure [key] (a daemon problem code
/// such as `task.not_found`, or an app key such as `connection.lost`), filled
/// with [params]. Null when this build has no text for [key]; show the
/// daemon's own English text then.
String? problemMessage(
  AppLocalizations l,
  String key,
  Map<String, String> params,
) {
  String p(String name) => params[name] ?? '';
  return switch (key) {
    'task.not_found' => l.problem_task_not_found,
    'queue.not_found' => l.problem_queue_not_found,
    'category.not_found' => l.problem_category_not_found,
    'webhook.not_found' => l.problem_webhook_not_found,
    'credential.not_found' => l.problem_credential_not_found,
    'plugin.not_found' => l.problem_plugin_not_found,
    'cookie.not_found' => l.problem_cookie_not_found,
    'engine.not_found' => l.problem_engine_not_found,
    'browser_profile.not_found' => l.problem_browser_profile_not_found,
    'browser_result.not_found' => l.problem_browser_result_not_found,
    'browser_candidate.not_found' => l.problem_browser_candidate_not_found,
    'refresh_attempt.not_found' => l.problem_refresh_attempt_not_found,
    'resolve_result.not_found' => l.problem_resolve_result_not_found,
    'queue.name_taken' => l.problem_queue_name_taken,
    'category.name_taken' => l.problem_category_name_taken,
    'queue.not_empty' => l.problem_queue_not_empty,
    'task.duplicate' => l.problem_task_duplicate(p('status')),
    'task.file_exists' => l.problem_task_file_exists,
    'task.invalid_state' => l.problem_task_invalid_state(
      p('operation'),
      p('status'),
    ),
    'task.invalid_transition' => l.problem_task_invalid_transition,
    'task.locked' => l.problem_task_locked,
    'task.state_changed' => l.problem_task_state_changed,
    'browser.running' => l.problem_browser_running,
    'category.bad_dir' => l.problem_category_bad_dir,
    'settings.invalid' => l.problem_settings_invalid,
    'validation_failed' => l.problem_validation_failed,
    'invalid_argument' => l.problem_invalid_argument,
    'settings.changed' => l.problem_settings_changed,
    'browser.unavailable' => l.problem_browser_unavailable,
    'origin.failed' => l.problem_origin_failed(p('code')),
    'request.cancelled' => l.problem_request_cancelled,
    'service.unavailable' => l.problem_service_unavailable,
    'bad_request' => l.problem_bad_request,
    'unauthorized' => l.problem_unauthorized,
    'forbidden' => l.problem_forbidden,
    'not_found' => l.problem_not_found,
    'conflict' => l.problem_conflict,
    'precondition_failed' => l.problem_precondition_failed,
    'too_many_requests' => l.problem_too_many_requests,
    'server_error' => l.problem_server_error,
    'connection.lost' => l.problem_connection_lost,
    'connection.timeout' => l.problem_connection_timeout,
    'connection.certificate' => l.problem_connection_certificate,
    'unknown' => l.problem_unknown,
    _ => null,
  };
}
