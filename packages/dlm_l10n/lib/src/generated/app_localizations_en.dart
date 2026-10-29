// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get problem_task_not_found =>
      'That download does not exist (any more).';

  @override
  String get problem_queue_not_found => 'That queue does not exist (any more).';

  @override
  String get problem_category_not_found =>
      'That category does not exist (any more).';

  @override
  String get problem_webhook_not_found =>
      'That webhook does not exist (any more).';

  @override
  String get problem_credential_not_found =>
      'That login does not exist (any more).';

  @override
  String get problem_plugin_not_found =>
      'That plugin does not exist (any more).';

  @override
  String get problem_cookie_not_found =>
      'That cookie does not exist (any more).';

  @override
  String get problem_engine_not_found =>
      'That download engine does not exist (any more).';

  @override
  String get problem_browser_profile_not_found =>
      'That browser profile does not exist (any more).';

  @override
  String get problem_browser_result_not_found =>
      'That page result does not exist (any more).';

  @override
  String get problem_browser_candidate_not_found =>
      'That download candidate does not exist (any more).';

  @override
  String get problem_refresh_attempt_not_found =>
      'That link refresh does not exist (any more).';

  @override
  String get problem_resolve_result_not_found =>
      'That link check does not exist (any more).';

  @override
  String get problem_queue_name_taken =>
      'A queue with that name already exists.';

  @override
  String get problem_category_name_taken =>
      'A category with that name already exists.';

  @override
  String get problem_queue_not_empty =>
      'The queue still has downloads. Move or delete them first.';

  @override
  String problem_task_duplicate(String status) {
    return 'This file is already in your downloads ($status).';
  }

  @override
  String get problem_task_file_exists =>
      'A file with that name already exists in the target folder.';

  @override
  String problem_task_invalid_state(String operation, String status) {
    return 'This download cannot be $operation while it is $status.';
  }

  @override
  String get problem_task_invalid_transition =>
      'This download cannot change to that state right now.';

  @override
  String get problem_task_locked =>
      'This download is busy. Try again in a moment.';

  @override
  String get problem_task_state_changed =>
      'This download changed while you were working on it. Check its state and try again.';

  @override
  String get problem_browser_running =>
      'The browser is in use. Close its pages first.';

  @override
  String get problem_category_bad_dir =>
      'That folder is not allowed for a category.';

  @override
  String get problem_settings_invalid =>
      'Some settings are not valid. Check the highlighted fields.';

  @override
  String get problem_validation_failed =>
      'Some values are not valid. Check the highlighted fields.';

  @override
  String get problem_invalid_argument => 'Those values are not valid.';

  @override
  String get problem_settings_changed =>
      'The settings were changed somewhere else. The latest settings have been loaded; review your change and apply it again.';

  @override
  String get problem_browser_unavailable =>
      'No browser is available. Install Chrome, Chromium, Edge or Brave, or allow downloading one in the settings.';

  @override
  String problem_origin_failed(String code) {
    return 'The server of the file did not answer properly ($code).';
  }

  @override
  String get problem_request_cancelled => 'The request was cancelled.';

  @override
  String get problem_service_unavailable =>
      'The download service is not ready yet. Try again in a moment.';

  @override
  String get problem_bad_request => 'The request was not understood.';

  @override
  String get problem_unauthorized =>
      'The access token was rejected. Check the token of this connection.';

  @override
  String get problem_forbidden => 'You are not allowed to do that.';

  @override
  String get problem_not_found => 'That does not exist (any more).';

  @override
  String get problem_conflict =>
      'That conflicts with the current state. Refresh and try again.';

  @override
  String get problem_precondition_failed =>
      'That was changed somewhere else. Refresh and try again.';

  @override
  String get problem_too_many_requests => 'Too many requests. Wait a moment.';

  @override
  String get problem_server_error =>
      'The download service had an internal problem.';

  @override
  String get problem_connection_lost =>
      'The download service cannot be reached.';

  @override
  String get problem_connection_timeout =>
      'The download service did not answer in time.';

  @override
  String get problem_connection_certificate =>
      'The certificate of the download service changed or is not trusted. Do not continue unless you expect this.';

  @override
  String get problem_unknown => 'Something went wrong.';

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String relativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get app_name => 'dlm';

  @override
  String get nav_label => 'Navigation';

  @override
  String get nav_all => 'All Downloads';

  @override
  String get nav_active => 'Active';

  @override
  String get nav_queued => 'Queued';

  @override
  String get nav_paused => 'Paused';

  @override
  String get nav_completed => 'Completed';

  @override
  String get nav_failed => 'Failed';

  @override
  String get nav_queues => 'Queues';

  @override
  String get toolbar_search_placeholder => 'Search downloads';

  @override
  String get toolbar_search_clear => 'Clear search';

  @override
  String get toolbar_inspector_show => 'Show details';

  @override
  String get toolbar_inspector_hide => 'Hide details';

  @override
  String get toolbar_palette => 'Commands';

  @override
  String get toolbar_label => 'Toolbar';

  @override
  String get inspector_empty_title => 'No download selected';

  @override
  String get inspector_empty_message => 'Select a download to see its details.';

  @override
  String get inspector_resize => 'Resize details';

  @override
  String get sidebar_resize => 'Resize sidebar';

  @override
  String get palette_placeholder => 'Type a command';

  @override
  String get palette_no_results => 'No matching command';

  @override
  String get palette_label => 'Command palette';

  @override
  String command_go_to(String destination) {
    return 'Go to $destination';
  }

  @override
  String get command_toggle_inspector => 'Show or hide details';

  @override
  String get command_focus_search => 'Search downloads';

  @override
  String get connection_connecting_title =>
      'Connecting to the download service';

  @override
  String connection_connecting_message(String name) {
    return 'Starting $name…';
  }

  @override
  String get connection_failed_title => 'Cannot reach the download service';

  @override
  String connection_failed_message(String name) {
    return 'The app could not connect to $name.';
  }

  @override
  String get connection_retry => 'Try again';

  @override
  String get connection_token_rejected_title => 'The access token was refused';

  @override
  String connection_token_rejected_message(String name) {
    return '$name did not accept the saved token.';
  }

  @override
  String get connection_incompatible_title =>
      'This version of the app cannot talk to that service';

  @override
  String get connection_incompatible_message =>
      'Update the app or the service so their versions match.';

  @override
  String get connection_trust_title => 'Trust this server?';

  @override
  String connection_trust_message(String name) {
    return '$name presented a certificate the app has not seen before. Check that the fingerprint below matches the one on the server.';
  }

  @override
  String get connection_trust_accept => 'Trust and connect';

  @override
  String get connection_trust_reject => 'Cancel';

  @override
  String get status_connected => 'Connected';

  @override
  String get connection_trust_subject => 'Subject';

  @override
  String get connection_trust_issuer => 'Issuer';

  @override
  String get connection_trust_expires => 'Valid until';

  @override
  String get connection_trust_fingerprint => 'Fingerprint';

  @override
  String get connection_certificate_changed =>
      'The server\'s certificate is different from the one you trusted. Do not continue unless you know it was replaced.';

  @override
  String connection_reason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get col_name => 'Name';

  @override
  String get col_status => 'Status';

  @override
  String get col_progress => 'Progress';

  @override
  String get col_size => 'Size';

  @override
  String get col_speed => 'Speed';

  @override
  String get col_eta => 'Time left';

  @override
  String get col_queue => 'Queue';

  @override
  String get col_added => 'Added';

  @override
  String get task_status_queued => 'Queued';

  @override
  String get task_status_running => 'Downloading';

  @override
  String get task_status_paused => 'Paused';

  @override
  String get task_status_awaiting_link => 'Waiting for a link';

  @override
  String get task_status_refreshing => 'Refreshing link';

  @override
  String get task_status_postprocessing => 'Finishing';

  @override
  String get task_status_completed => 'Completed';

  @override
  String get task_status_error => 'Failed';

  @override
  String get task_status_unknown => 'Unknown';

  @override
  String get task_unnamed => 'Unnamed download';

  @override
  String task_eta(String time) {
    return '$time left';
  }

  @override
  String task_row_label(String name, String status) {
    return '$name, $status';
  }

  @override
  String get table_downloads_label => 'Downloads';

  @override
  String get table_sorted_ascending => 'sorted ascending';

  @override
  String get table_sorted_descending => 'sorted descending';

  @override
  String table_resize_column(String column) {
    return 'Resize $column';
  }

  @override
  String get table_loading_row => 'Loading';

  @override
  String get list_loading => 'Loading downloads';

  @override
  String get list_empty_title => 'No downloads here';

  @override
  String get list_empty_message =>
      'Downloads you add will appear in this list.';

  @override
  String get list_empty_search_title => 'Nothing matches your search';

  @override
  String get list_empty_search_message =>
      'Try different words or clear the search.';

  @override
  String get list_error_title => 'Could not load the downloads';

  @override
  String get list_retry => 'Try again';

  @override
  String get action_pause => 'Pause';

  @override
  String get action_resume => 'Resume';

  @override
  String get action_restart => 'Download again';

  @override
  String get action_delete => 'Delete…';

  @override
  String get action_copy_link => 'Copy link';

  @override
  String get action_undo => 'Undo';

  @override
  String get action_dismiss => 'Dismiss';

  @override
  String toast_paused(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Paused $count downloads',
      one: 'Paused 1 download',
    );
    return '$_temp0';
  }

  @override
  String toast_resumed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Resumed $count downloads',
      one: 'Resumed 1 download',
    );
    return '$_temp0';
  }

  @override
  String toast_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count downloads',
      one: 'Deleted 1 download',
    );
    return '$_temp0';
  }

  @override
  String get toast_restarted => 'Download restarted';

  @override
  String get toast_link_copied => 'Link copied';

  @override
  String toast_some_failed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads could not be changed',
      one: '1 download could not be changed',
    );
    return '$_temp0';
  }

  @override
  String get toast_failure_unknown => 'Something went wrong.';

  @override
  String delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count downloads?',
      one: 'Delete this download?',
    );
    return '$_temp0';
  }

  @override
  String get delete_message =>
      'They are removed from the list. Their files stay on disk unless you choose otherwise.';

  @override
  String get delete_files => 'Also delete the downloaded files';

  @override
  String get delete_confirm => 'Delete';

  @override
  String get delete_cancel => 'Cancel';

  @override
  String selection_count(int count) {
    return '$count selected';
  }

  @override
  String get banner_reconnecting_title =>
      'Connection to the download service lost';

  @override
  String get banner_reconnecting_message => 'Trying to reconnect…';

  @override
  String get banner_daemon_restarting_title =>
      'The download service stopped unexpectedly';

  @override
  String get banner_daemon_restarting_message =>
      'It is restarting; your downloads continue from where they were.';

  @override
  String get banner_daemon_failed_title =>
      'The download service keeps stopping';

  @override
  String banner_daemon_failed_message(String reason) {
    return '$reason';
  }

  @override
  String get banner_daemon_restart => 'Restart service';

  @override
  String get banner_dismiss => 'Dismiss';
}
