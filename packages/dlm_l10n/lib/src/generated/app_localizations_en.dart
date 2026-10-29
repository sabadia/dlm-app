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

  @override
  String get queue_new => 'New queue';

  @override
  String get queue_new_title => 'New queue';

  @override
  String get queue_name_label => 'Name';

  @override
  String get queue_name_placeholder => 'For example Night downloads';

  @override
  String get queue_name_taken => 'A queue with that name already exists.';

  @override
  String get queue_create => 'Create';

  @override
  String get queue_rename => 'Rename…';

  @override
  String get queue_rename_title => 'Rename queue';

  @override
  String get queue_save => 'Save';

  @override
  String get queue_delete => 'Delete queue…';

  @override
  String queue_delete_title(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get queue_delete_message =>
      'Its downloads move to the default queue. Nothing is removed from disk.';

  @override
  String get queue_delete_confirm => 'Delete queue';

  @override
  String get queue_move_up => 'Move up';

  @override
  String get queue_move_down => 'Move down';

  @override
  String get queue_start => 'Start queue';

  @override
  String get queue_stop => 'Stop queue';

  @override
  String get queue_settings => 'Queue settings…';

  @override
  String get queue_menu => 'Queue actions';

  @override
  String get queue_state_running => 'Running';

  @override
  String get queue_state_stopped => 'Stopped';

  @override
  String get queue_default => 'Default';

  @override
  String toast_queue_created(String name) {
    return 'Created “$name”';
  }

  @override
  String toast_queue_renamed(String name) {
    return 'Renamed to “$name”';
  }

  @override
  String toast_queue_deleted(String name) {
    return 'Deleted “$name”';
  }

  @override
  String toast_queue_started(String name) {
    return '“$name” started';
  }

  @override
  String toast_queue_stopped(String name) {
    return '“$name” stopped';
  }

  @override
  String toast_queue_saved(String name) {
    return 'Saved the settings of “$name”';
  }

  @override
  String qs_title(String name) {
    return 'Settings of “$name”';
  }

  @override
  String get qs_intro => 'Anything left empty follows the global settings.';

  @override
  String get qs_group_speed => 'Speed';

  @override
  String get qs_speed_limit => 'Speed limit';

  @override
  String get qs_speed_limit_desc =>
      'Per second, for the whole queue. Empty means no limit of its own.';

  @override
  String get qs_speed_placeholder => 'For example 2 MB';

  @override
  String get qs_invalid_size => 'Enter a size like 500K or 2 MB.';

  @override
  String get qs_group_schedule => 'Schedule';

  @override
  String get qs_schedule_on => 'Run only at chosen times';

  @override
  String get qs_schedule_desc =>
      'Outside these hours the queue waits; downloads resume when the next window opens.';

  @override
  String get qs_schedule_grid => 'Weekly schedule, one cell per hour';

  @override
  String get qs_group_profiles => 'Speed profiles';

  @override
  String get qs_profiles_desc =>
      'A profile limits the speed while its hours are active.';

  @override
  String qs_profile_title(int index) {
    return 'Profile $index';
  }

  @override
  String get qs_profile_add => 'Add a profile';

  @override
  String get qs_profile_remove => 'Remove';

  @override
  String get qs_profile_limit => 'Limit while active';

  @override
  String get qs_profile_unlimited => 'Empty means unlimited while active.';

  @override
  String get qs_group_quota => 'Quota';

  @override
  String get qs_quota_on => 'Limit the amount downloaded';

  @override
  String get qs_quota_desc =>
      'When the quota is used up the queue waits for the period to roll over.';

  @override
  String get qs_quota_bytes => 'Amount';

  @override
  String get qs_quota_period => 'Per period';

  @override
  String get qs_quota_period_placeholder => 'For example 1 d';

  @override
  String get qs_invalid_duration =>
      'Enter a time like 1h, 1d or 90m (at least a minute).';

  @override
  String get qs_group_after => 'When the queue finishes';

  @override
  String get qs_after => 'Then';

  @override
  String get qs_after_none => 'Do nothing';

  @override
  String get qs_after_stop => 'Stop the queue';

  @override
  String get qs_after_sleep => 'Put the computer to sleep';

  @override
  String get qs_after_shutdown => 'Shut the computer down';

  @override
  String get qs_after_command => 'Run a program';

  @override
  String get qs_after_delay => 'Wait first';

  @override
  String get qs_after_delay_desc =>
      'A grace period in which you can cancel. Empty means 1 minute.';

  @override
  String get qs_after_command_path => 'Program (full path)';

  @override
  String get qs_after_command_args => 'Arguments, one per line';

  @override
  String get qs_after_command_warning =>
      'This program runs with your permissions whenever the queue finishes. Only use one you trust.';

  @override
  String get qs_invalid_path => 'Enter the full path of the program.';

  @override
  String get qs_cancel => 'Cancel';

  @override
  String queue_countdown_title(String name) {
    return '“$name” has finished';
  }

  @override
  String queue_countdown_message(String action, String time) {
    return '$action in $time.';
  }

  @override
  String get queue_countdown_cancel => 'Cancel and stop the queue';

  @override
  String queue_action_cancelled(String name) {
    return 'The action after “$name” was cancelled.';
  }

  @override
  String get qs_schedule_custom =>
      'These hours include minutes, which the weekly grid cannot show. They are kept as they are until you replace them.';

  @override
  String get qs_schedule_use_grid => 'Use the hourly grid';

  @override
  String get queue_missing_title => 'This queue does not exist any more';

  @override
  String get queue_missing_message =>
      'It was deleted, perhaps from another window. Pick another one in the sidebar.';

  @override
  String get setup_title => 'Welcome';

  @override
  String get setup_intro =>
      'A quick look at where your downloads go and what the download service found on this computer. You can come back to this from the command palette.';

  @override
  String get setup_folder_title => 'Download folder';

  @override
  String get setup_folder_desc =>
      'New downloads are saved here unless a category or queue says otherwise.';

  @override
  String get setup_folder_choose => 'Choose…';

  @override
  String get setup_folder_dialog => 'Choose the download folder';

  @override
  String get setup_folder_unset => 'Not chosen yet';

  @override
  String setup_folder_saved(String path) {
    return 'Downloads will be saved in $path';
  }

  @override
  String get setup_tools_title => 'Helper programs';

  @override
  String get setup_tools_desc =>
      'These are used for some downloads. A missing one is only a problem when a download needs it.';

  @override
  String get setup_tools_recheck => 'Check again';

  @override
  String get setup_tools_loading => 'Looking for helper programs…';

  @override
  String get setup_tool_ffmpeg => 'ffmpeg';

  @override
  String get setup_tool_ffmpeg_desc =>
      'Joins video and audio and converts media.';

  @override
  String get setup_tool_ytdlp => 'yt-dlp';

  @override
  String get setup_tool_ytdlp_desc => 'Downloads from video sites.';

  @override
  String get setup_tool_browser => 'Browser';

  @override
  String get setup_tool_browser_desc =>
      'Opens pages that only work in a real browser.';

  @override
  String setup_tool_found(String version) {
    return 'Found · $version';
  }

  @override
  String get setup_tool_found_noversion => 'Found';

  @override
  String get setup_tool_missing => 'Not found';

  @override
  String get setup_tool_missing_auto =>
      'Not found · installed automatically when needed';

  @override
  String setup_tool_error(String error) {
    return 'Problem: $error';
  }

  @override
  String get setup_done => 'Done';

  @override
  String get cmd_setup => 'Setup and health check…';

  @override
  String get insp_label => 'Download details';

  @override
  String get insp_tab_overview => 'Overview';

  @override
  String get insp_tab_files => 'Files';

  @override
  String get insp_tab_speed => 'Speed';

  @override
  String get insp_tab_source => 'Link';

  @override
  String insp_multi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads selected',
      one: '1 download selected',
    );
    return '$_temp0';
  }

  @override
  String get insp_multi_hint => 'Select a single download to see its details.';

  @override
  String get insp_gone => 'This download no longer exists.';

  @override
  String get ov_group_progress => 'Progress';

  @override
  String get ov_group_where => 'Where it goes';

  @override
  String get ov_group_times => 'Times';

  @override
  String get ov_status => 'Status';

  @override
  String get ov_progress => 'Done';

  @override
  String get ov_size => 'Size';

  @override
  String get ov_size_unknown => 'Not known yet';

  @override
  String get ov_downloaded => 'Downloaded';

  @override
  String get ov_speed => 'Speed';

  @override
  String get ov_time_left => 'Time left';

  @override
  String get ov_connections => 'Connections';

  @override
  String get ov_queue => 'Queue';

  @override
  String get ov_engine => 'Engine';

  @override
  String get ov_folder => 'Folder';

  @override
  String get ov_priority => 'Priority';

  @override
  String get ov_labels => 'Labels';

  @override
  String get ov_added => 'Added';

  @override
  String get ov_started => 'Started';

  @override
  String get ov_completed => 'Finished';

  @override
  String get ov_none => '—';

  @override
  String get ov_priority_low => 'Low';

  @override
  String get ov_priority_normal => 'Normal';

  @override
  String get ov_priority_high => 'High';

  @override
  String get ov_error_title => 'It stopped with an error';

  @override
  String ov_error_detail(String message, String code) {
    return '$message ($code)';
  }

  @override
  String ov_error_when(String when) {
    return '$when';
  }

  @override
  String get ov_error_retryable => 'Trying again may work.';

  @override
  String get ov_error_final =>
      'Trying again will not help until something changes.';

  @override
  String get files_tree_label => 'Files of this download';

  @override
  String get files_single => 'This download is a single file.';

  @override
  String files_count(int selected, int total) {
    return '$selected of $total files selected';
  }

  @override
  String get files_none_selected => 'No files are selected for download.';

  @override
  String get speed_title => 'Download speed';

  @override
  String speed_summary(String current, String peak, int seconds) {
    return 'Now $current, highest $peak over the last $seconds seconds.';
  }

  @override
  String get speed_waiting => 'The graph fills in while the download runs.';

  @override
  String get speed_series => 'Speed';

  @override
  String get src_group_link => 'Link';

  @override
  String get src_group_history => 'Link renewals';

  @override
  String get src_current => 'Current link';

  @override
  String get src_original => 'First link';

  @override
  String get src_page => 'Page';

  @override
  String get src_referrer => 'Referrer';

  @override
  String get src_mirrors => 'Mirrors';

  @override
  String get src_copy => 'Copy';

  @override
  String get src_refresh => 'Renew link now';

  @override
  String get src_await => 'Wait for a new link';

  @override
  String get src_edit => 'Replace link…';

  @override
  String get src_edit_title => 'Replace the link';

  @override
  String get src_edit_label => 'New link';

  @override
  String get src_edit_hint =>
      'The daemon checks it against the file. If it is not the same file, the download starts again.';

  @override
  String get src_edit_needs_pause =>
      'Pause the download first to replace its link.';

  @override
  String get src_edit_save => 'Replace';

  @override
  String get src_history_empty => 'The link has not needed renewing.';

  @override
  String src_attempt(String strategy, String outcome) {
    return '$strategy · $outcome';
  }

  @override
  String src_attempt_cause(String cause) {
    return 'Cause: $cause';
  }

  @override
  String get toast_link_refreshing => 'Asking for a new link';

  @override
  String get toast_link_waiting => 'Waiting for a new link';

  @override
  String get toast_link_replaced => 'Link replaced';

  @override
  String get files_skipped => 'not downloaded';

  @override
  String get insp_tab_segments => 'Segments';

  @override
  String get insp_tab_torrent => 'Torrent';

  @override
  String get seg_none => 'This download is not split into segments.';

  @override
  String seg_summary(int count, int percent) {
    return '$count segments, $percent% done.';
  }

  @override
  String get seg_label => 'Map of the segments of the download';

  @override
  String get seg_done => 'downloaded';

  @override
  String get seg_todo => 'still to do';

  @override
  String get torrent_none =>
      'There is no swarm to show yet: the torrent has not started.';

  @override
  String get torrent_state => 'State';

  @override
  String get torrent_hash => 'Info hash';

  @override
  String get torrent_private => 'Private torrent';

  @override
  String get torrent_yes => 'yes';

  @override
  String get torrent_no => 'no';

  @override
  String get torrent_peers => 'Peers';

  @override
  String torrent_peers_value(int connected, int known, int seeders) {
    return '$connected connected, $known known, $seeders seeders';
  }

  @override
  String get torrent_shared => 'Shared';

  @override
  String torrent_shared_value(String uploaded, String ratio) {
    return '$uploaded uploaded, ratio $ratio';
  }

  @override
  String get torrent_seeding_time => 'Seeding for';

  @override
  String get torrent_trackers => 'Trackers';

  @override
  String get torrent_peer_list => 'Connected peers';

  @override
  String torrent_peer_rate(String rate) {
    return '$rate down';
  }

  @override
  String get files_edit => 'Choose files';

  @override
  String get files_save => 'Save selection';

  @override
  String get files_cancel => 'Cancel';

  @override
  String get files_locked =>
      'Pause the download to change which files are downloaded.';

  @override
  String get files_select_all => 'All files';

  @override
  String get files_pick_one => 'Select at least one file.';

  @override
  String get toast_files_saved => 'Selection saved';

  @override
  String files_file_label(String name) {
    return 'Download $name';
  }

  @override
  String get add_title => 'Add downloads';

  @override
  String get add_button => 'Add';

  @override
  String get add_links => 'Links';

  @override
  String get add_links_placeholder =>
      'One link per line: web addresses, magnet links, or a pattern like http://host/img[1-20].jpg';

  @override
  String get add_looking => 'Looking at the link…';

  @override
  String add_files(int count) {
    return '$count files';
  }

  @override
  String add_many(int count) {
    return '$count downloads';
  }

  @override
  String get add_more => 'and more…';

  @override
  String add_duplicate(String name) {
    return 'Already in the list: $name';
  }

  @override
  String get add_anyway => 'Add it anyway';

  @override
  String get add_queue => 'Queue';

  @override
  String get add_folder => 'Folder';

  @override
  String get add_folder_default => 'The default download folder';

  @override
  String get add_name => 'Name';

  @override
  String get add_name_placeholder => 'Taken from the link';

  @override
  String get add_paused => 'Add without starting';

  @override
  String add_done_one(String name) {
    return 'Added $name';
  }

  @override
  String add_done_many(int count) {
    return 'Added $count downloads';
  }

  @override
  String get cmd_add => 'Add downloads…';

  @override
  String get toolbar_add => 'Add downloads';

  @override
  String get view_menu => 'View';

  @override
  String get view_engine => 'Engine';

  @override
  String get view_all_engines => 'All engines';

  @override
  String get view_saved => 'Saved views';

  @override
  String get view_save => 'Save current view…';

  @override
  String get view_save_title => 'Save this view';

  @override
  String view_delete(String name) {
    return 'Delete view $name';
  }

  @override
  String get col_engine => 'Engine';

  @override
  String list_total(int count) {
    return '$count downloads';
  }

  @override
  String get action_refresh_link => 'Get a new link';

  @override
  String get action_move_to => 'Move to queue';

  @override
  String get action_priority => 'Priority';

  @override
  String get priority_high => 'High';

  @override
  String get priority_normal => 'Normal';

  @override
  String get priority_low => 'Low';

  @override
  String toast_moved(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count downloads to $queue',
      one: 'Moved 1 download to $queue',
    );
    return '$_temp0';
  }

  @override
  String toast_prioritised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Priority changed for $count downloads',
      one: 'Priority changed for 1 download',
    );
    return '$_temp0';
  }

  @override
  String toast_restarted_many(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restarting $count downloads',
      one: 'Restarting 1 download',
    );
    return '$_temp0';
  }

  @override
  String toast_refreshing_many(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Asking for new links for $count downloads',
      one: 'Asking for a new link for 1 download',
    );
    return '$_temp0';
  }

  @override
  String get status_label => 'Status bar';

  @override
  String get status_reconnecting => 'Reconnecting…';

  @override
  String status_speed(String down, String up) {
    return '↓ $down  ↑ $up';
  }

  @override
  String status_counts(int active, int queued) {
    return '$active active, $queued waiting';
  }

  @override
  String status_quota(String used, String total) {
    return '$used of $total';
  }

  @override
  String get status_quota_label => 'Quota used';

  @override
  String get status_turbo => 'Turbo';

  @override
  String get status_turbo_on => 'Turbo on';

  @override
  String get status_pause_all => 'Pause all';

  @override
  String get status_resume_all => 'Resume all';

  @override
  String get add_import => 'Import list…';

  @override
  String add_import_title(String name) {
    return 'Import $name';
  }

  @override
  String add_import_go(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count downloads',
      one: 'Add 1 download',
    );
    return '$_temp0';
  }

  @override
  String get add_results_title => 'What happened';

  @override
  String add_results_summary(int ok, int failed) {
    return '$ok added, $failed not added.';
  }

  @override
  String get add_result_ok => 'Added';

  @override
  String get add_result_failed => 'Not added';

  @override
  String get add_result_duplicate => 'Already in the list';

  @override
  String get add_close => 'Close';

  @override
  String get add_folder_browse => 'Browse folders';

  @override
  String get folder_browser_title => 'Choose a folder';

  @override
  String get folder_browser_roots => 'Places you can choose from';

  @override
  String get folder_browser_empty => 'No folders here.';

  @override
  String get folder_browser_choose => 'Choose this folder';

  @override
  String get folder_browser_error => 'The folders could not be listed.';

  @override
  String get add_advanced => 'More options';

  @override
  String get add_mode => 'Treat the link as';

  @override
  String get add_mode_auto => 'Let the app decide';

  @override
  String get add_mode_direct => 'A file';

  @override
  String get add_mode_ytdlp => 'A video or audio page (yt-dlp)';

  @override
  String get add_mode_browser => 'A page that needs a browser';

  @override
  String get add_referrer => 'Referrer';

  @override
  String get add_headers => 'Headers';

  @override
  String get add_headers_hint => 'One per line, like Name: value';

  @override
  String get add_headers_invalid =>
      'Every line needs a name, a colon and a value.';

  @override
  String get add_mirrors => 'Mirrors';

  @override
  String get add_mirrors_hint =>
      'Other places with the same file, one link per line';

  @override
  String get add_checksum => 'Checksum';

  @override
  String get add_checksum_algorithm => 'Checksum algorithm';

  @override
  String get add_checksum_placeholder => 'Expected value in hex';

  @override
  String get add_checksum_invalid => 'Not a valid value for this algorithm.';

  @override
  String get add_torrent => 'Torrent file…';

  @override
  String get add_torrent_too_big =>
      'That torrent file is too large (16 MiB at most).';

  @override
  String add_torrent_remove(String name) {
    return 'Remove $name';
  }

  @override
  String get nav_categories => 'Categories';

  @override
  String drag_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads',
      one: '1 download',
    );
    return '$_temp0';
  }

  @override
  String get view_density => 'Row height';

  @override
  String get view_density_comfortable => 'Comfortable';

  @override
  String get view_density_compact => 'Compact';

  @override
  String get view_columns => 'Columns';

  @override
  String get display_menu => 'Display';

  @override
  String get settings_search => 'Search settings';

  @override
  String get settings_save => 'Save';

  @override
  String get settings_revert => 'Revert';

  @override
  String get settings_saved => 'Settings saved';

  @override
  String get settings_unsaved => 'Unsaved changes';

  @override
  String get settings_no_match => 'No setting matches your search.';

  @override
  String get settings_changed_elsewhere =>
      'The settings were changed somewhere else. Their version is shown now; make your changes again.';

  @override
  String get settings_level_default => 'Default';

  @override
  String get settings_level_global => 'Global';

  @override
  String get settings_level_queue => 'Queue';

  @override
  String get settings_level_task => 'This download';

  @override
  String get settings_restart => 'Needs restart';

  @override
  String get settings_unset => 'Not set';

  @override
  String settings_reset(String name) {
    return 'Reset $name to the inherited value';
  }

  @override
  String get settings_invalid_size => 'Not a size, such as 10 MB or 512 K.';

  @override
  String get settings_invalid_number => 'Not a number in the allowed range.';

  @override
  String get settings_invalid_duration =>
      'Use a duration like 30s, 5m or 1h30m.';

  @override
  String get settings_leave_title => 'Leave without saving?';

  @override
  String get settings_leave_message =>
      'You changed settings that are not saved yet.';

  @override
  String get settings_leave_confirm => 'Leave';

  @override
  String get settings_leave_stay => 'Keep editing';

  @override
  String get nav_settings => 'Settings';

  @override
  String get insp_tab_settings => 'Settings';

  @override
  String get se_name => 'Name';

  @override
  String get se_value => 'Value';

  @override
  String get se_remove => 'Remove';

  @override
  String get se_add => 'Add';

  @override
  String get se_add_rule => 'Add a rule';

  @override
  String get se_proxy_mode => 'Proxy';

  @override
  String get se_proxy_none => 'No proxy';

  @override
  String get se_proxy_system => 'The system\'s proxy';

  @override
  String get se_proxy_custom => 'A proxy I choose';

  @override
  String get se_proxy_url => 'Proxy address';

  @override
  String get se_rule_hosts => 'Hosts';

  @override
  String get se_rule_hosts_hint => 'example.com, *.cdn.net';

  @override
  String get se_lines => 'One entry per line';

  @override
  String get se_move_up => 'Move up';

  @override
  String get se_move_down => 'Move down';

  @override
  String get se_pa_add => 'Add an action';

  @override
  String get se_pa_extract => 'Unpack archives';

  @override
  String get se_pa_add_torrent => 'Add a downloaded .torrent file';

  @override
  String get se_pa_command => 'Run a program';

  @override
  String get se_pa_av_scan => 'Scan for viruses';

  @override
  String get se_pa_dir => 'Folder';

  @override
  String get se_pa_dir_hint => 'Next to the file';

  @override
  String get se_pa_delete => 'Delete the file afterwards';

  @override
  String get se_pa_password => 'Password';

  @override
  String get se_pa_cmd => 'Program';

  @override
  String get se_pa_cmd_hint => 'Full path, e.g. /usr/bin/clamscan';

  @override
  String get se_pa_args => 'Arguments';

  @override
  String se_pa_args_hint(String token) {
    return 'One per line; $token is the file';
  }

  @override
  String get se_pa_timeout => 'Time limit';

  @override
  String get se_pa_infected_exit => 'Infected exit code';

  @override
  String get se_pa_on_infected => 'When infected';

  @override
  String get se_pa_infected_delete => 'Delete the file';

  @override
  String get se_pa_infected_keep => 'Keep the file';

  @override
  String get se_pa_command_warning =>
      'This runs a program on every finished download. Only use a program you trust.';

  @override
  String get se_pa_av_warning =>
      'An infected file fails the download and, unless you keep it, is deleted. Only use a scanner you trust.';

  @override
  String get se_quota_bytes => 'Amount';

  @override
  String get se_quota_per => 'per';

  @override
  String get se_quota_period => 'Period';

  @override
  String get nav_manage => 'Manage';

  @override
  String get nav_manage_categories => 'Categories';

  @override
  String get cat_intro =>
      'A category sorts a finished download into a folder by its file extension or content type. The first category that matches wins, so the order matters.';

  @override
  String get cat_add => 'Add a category';

  @override
  String get cat_add_title => 'Add a category';

  @override
  String get cat_edit_title => 'Edit the category';

  @override
  String get cat_saved => 'Category saved';

  @override
  String get cat_empty_title => 'No categories yet';

  @override
  String get cat_empty_message =>
      'Add one to have finished downloads sorted into folders.';

  @override
  String get cat_name => 'Name';

  @override
  String get cat_folder => 'Folder';

  @override
  String get cat_folder_desc => 'Where files of this category are put.';

  @override
  String get cat_extensions => 'Extensions';

  @override
  String get cat_extensions_desc =>
      'Separated by commas or spaces, like mkv, mp4.';

  @override
  String get cat_extensions_invalid =>
      'Extensions are letters and digits only.';

  @override
  String get cat_mime => 'Content types';

  @override
  String get cat_mime_desc => 'One per line, like video/* or application/pdf.';

  @override
  String get cat_mime_invalid => 'Use the form type/subtype, or type/*.';

  @override
  String cat_drag(String name) {
    return 'Drag $name to change its order';
  }

  @override
  String cat_move_up(String name) {
    return 'Move $name up';
  }

  @override
  String cat_move_down(String name) {
    return 'Move $name down';
  }

  @override
  String cat_edit(String name) {
    return 'Edit $name';
  }

  @override
  String cat_delete(String name) {
    return 'Delete $name';
  }

  @override
  String cat_delete_title(String name) {
    return 'Delete the category $name?';
  }

  @override
  String get cat_delete_message =>
      'Files already sorted by it stay where they are.';

  @override
  String get cat_delete_confirm => 'Delete category';

  @override
  String get cat_test_title => 'Try a file';

  @override
  String get cat_test_name => 'File name';

  @override
  String get cat_test_mime => 'Content type';

  @override
  String get cat_test_none =>
      'No category matches: the file stays in the normal download folder.';

  @override
  String cat_test_found(String name, String dir) {
    return 'Goes to $name: $dir';
  }

  @override
  String get cat_test_error => 'The daemon could not be asked.';

  @override
  String get nav_manage_logins => 'Logins';

  @override
  String get nav_manage_cookies => 'Cookies';

  @override
  String get field_show => 'Show';

  @override
  String get field_hide => 'Hide';

  @override
  String get login_intro =>
      'Logins are sent to sites that ask for a user name and password. The password stays in the download service: it is never shown here again.';

  @override
  String get login_add => 'Add a login';

  @override
  String get login_add_title => 'Add a login';

  @override
  String get login_edit_title => 'Edit the login';

  @override
  String get login_saved => 'Login saved';

  @override
  String get login_empty_title => 'No logins yet';

  @override
  String get login_empty_message =>
      'Add one for a site that needs a user name and password.';

  @override
  String get login_host => 'Site';

  @override
  String get login_host_desc =>
      'A host name like example.com, or *.example.com for all its subdomains.';

  @override
  String get login_user => 'User name';

  @override
  String get login_password => 'Password';

  @override
  String get login_password_keep => 'Leave empty to keep the stored password.';

  @override
  String get login_scheme => 'Method';

  @override
  String get login_scheme_auto => 'Let the site decide';

  @override
  String get login_scheme_basic => 'Basic';

  @override
  String get login_scheme_digest => 'Digest';

  @override
  String login_updated(String date) {
    return 'changed $date';
  }

  @override
  String login_edit(String host) {
    return 'Edit the login for $host';
  }

  @override
  String login_delete(String host) {
    return 'Delete the login for $host';
  }

  @override
  String login_delete_title(String host) {
    return 'Delete the login for $host?';
  }

  @override
  String get login_delete_message =>
      'Downloads from that site will no longer sign in.';

  @override
  String get login_delete_confirm => 'Delete login';

  @override
  String get ck_intro =>
      'Cookies keep you signed in to sites. Their values stay in the download service; an export is the only way to see them.';

  @override
  String get ck_import => 'Import cookies…';

  @override
  String get ck_export => 'Export all…';

  @override
  String get ck_empty_title => 'No cookies stored';

  @override
  String get ck_empty_message =>
      'Import a cookies file, or let the browser extension send them.';

  @override
  String get ck_tree_label => 'Cookies by domain';

  @override
  String ck_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cookies',
      one: '1 cookie',
    );
    return '$_temp0';
  }

  @override
  String get ck_secure => 'Secure';

  @override
  String get ck_http_only => 'HTTP only';

  @override
  String get ck_session => 'Session';

  @override
  String ck_export_domain(String domain) {
    return 'Export the cookies of $domain';
  }

  @override
  String ck_delete_domain(String domain) {
    return 'Delete the cookies of $domain';
  }

  @override
  String ck_delete_cookie(String name) {
    return 'Delete the cookie $name';
  }

  @override
  String ck_delete_domain_title(String domain) {
    return 'Delete the cookies of $domain?';
  }

  @override
  String ck_delete_domain_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cookies will be deleted.',
      one: '1 cookie will be deleted.',
    );
    return '$_temp0';
  }

  @override
  String get ck_delete_confirm => 'Delete cookies';

  @override
  String ck_import_title(String name) {
    return 'Import $name';
  }

  @override
  String ck_import_summary(int imported, int skipped) {
    return '$imported imported, $skipped skipped.';
  }

  @override
  String get ck_export_title => 'Export cookies';

  @override
  String get ck_export_all => 'All stored cookies.';

  @override
  String ck_export_one(String domain) {
    return 'The cookies of $domain.';
  }

  @override
  String get ck_format => 'File type';

  @override
  String get ck_format_netscape => 'Netscape cookies.txt';

  @override
  String get ck_format_json => 'JSON';

  @override
  String get ck_export_warning =>
      'The export contains the cookie values. Anyone who has them can sign in as you. Reveal them only where you can keep them safe.';

  @override
  String get ck_reveal => 'Reveal the cookies';

  @override
  String ck_export_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cookies',
      one: '1 cookie',
    );
    return '$_temp0';
  }

  @override
  String get ck_export_text => 'The exported cookies';

  @override
  String get ck_copy => 'Copy';

  @override
  String get ck_copied => 'Copied';

  @override
  String get ck_save => 'Save to a file…';

  @override
  String get ck_saved => 'File saved';

  @override
  String get nav_manage_webhooks => 'Webhooks';

  @override
  String get wh_intro =>
      'A webhook is an address that is sent the daemon\'s events as they happen, for example when a download finishes.';

  @override
  String get wh_add => 'Add a webhook';

  @override
  String get wh_add_title => 'Add a webhook';

  @override
  String get wh_edit_title => 'Edit the webhook';

  @override
  String get wh_saved => 'Webhook saved';

  @override
  String get wh_empty_title => 'No webhooks yet';

  @override
  String get wh_empty_message =>
      'Add one to have events sent to another program.';

  @override
  String get wh_url => 'Address';

  @override
  String get wh_url_invalid =>
      'Use an address that starts with http:// or https://.';

  @override
  String get wh_secret => 'Secret';

  @override
  String get wh_secret_desc =>
      'Deliveries are signed with it, so the receiver can check where they came from. Optional.';

  @override
  String get wh_secret_keep => 'Leave empty to keep the stored secret.';

  @override
  String get wh_secret_remove => 'Remove the secret';

  @override
  String get wh_enabled_label => 'Send deliveries';

  @override
  String wh_enabled(String url) {
    return 'Send deliveries to $url';
  }

  @override
  String get wh_events => 'Events';

  @override
  String get wh_events_desc => 'Leave all unticked to receive every event.';

  @override
  String get wh_all_events => 'All events';

  @override
  String wh_events_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get wh_signed => 'Signed';

  @override
  String get wh_test => 'Test';

  @override
  String wh_test_ok(String url) {
    return '$url accepted the test event.';
  }

  @override
  String wh_test_failed(String url) {
    return '$url did not accept the test event.';
  }

  @override
  String get wh_log => 'Deliveries';

  @override
  String wh_log_title(String url) {
    return 'Deliveries to $url';
  }

  @override
  String get wh_log_desc =>
      'The last attempts since the daemon started, newest first.';

  @override
  String get wh_log_empty => 'Nothing was sent yet.';

  @override
  String get wh_log_error => 'The deliveries could not be read.';

  @override
  String get wh_log_refresh => 'Refresh';

  @override
  String get wh_log_no_answer => 'no answer';

  @override
  String wh_log_status(int status) {
    return 'HTTP $status';
  }

  @override
  String wh_log_attempt(int n) {
    return 'attempt $n';
  }

  @override
  String get wh_log_retry => 'will retry';

  @override
  String wh_edit(String url) {
    return 'Edit $url';
  }

  @override
  String wh_delete(String url) {
    return 'Delete $url';
  }

  @override
  String wh_delete_title(String url) {
    return 'Delete the webhook $url?';
  }

  @override
  String get wh_delete_message => 'Events will no longer be sent there.';

  @override
  String get wh_delete_confirm => 'Delete webhook';

  @override
  String get nav_manage_plugins => 'Plugins';

  @override
  String get log_level => 'Level';

  @override
  String get log_level_all => 'All levels';

  @override
  String get log_level_info => 'Info and above';

  @override
  String get log_level_warn => 'Warnings and errors';

  @override
  String get log_level_error => 'Errors only';

  @override
  String get log_search => 'Search the log';

  @override
  String get log_refresh => 'Refresh';

  @override
  String get log_empty => 'No log records.';

  @override
  String get log_error => 'The log could not be read.';

  @override
  String get pl_intro =>
      'Plugins are JavaScript extensions that resolve links, renew expired ones and react to downloads starting, failing and finishing. They run inside the daemon.';

  @override
  String get pl_install => 'Install a plugin';

  @override
  String get pl_install_title => 'Install a plugin';

  @override
  String get pl_install_message =>
      'The plugin is installed switched off. You review what it may do before it runs.';

  @override
  String get pl_install_go => 'Install';

  @override
  String get pl_source => 'Where from';

  @override
  String get pl_source_desc =>
      'A folder on the computer the daemon runs on, or a git address.';

  @override
  String get pl_ref => 'Version';

  @override
  String get pl_ref_desc =>
      'A branch, tag or commit, for a git address. Optional.';

  @override
  String get pl_replace => 'Replace a plugin of the same name';

  @override
  String get pl_empty_title => 'No plugins installed';

  @override
  String get pl_empty_message => 'Install one from a folder or a git address.';

  @override
  String pl_enabled(String name) {
    return 'Run $name';
  }

  @override
  String get pl_permissions => 'Permissions';

  @override
  String get pl_logs => 'Log';

  @override
  String pl_remove(String name) {
    return 'Remove $name';
  }

  @override
  String pl_remove_title(String name) {
    return 'Remove $name?';
  }

  @override
  String get pl_remove_message =>
      'The plugin, its files and the data it stored are deleted.';

  @override
  String get pl_remove_confirm => 'Remove plugin';

  @override
  String pl_logs_title(String name) {
    return 'Log of $name';
  }

  @override
  String pl_review_title(String name) {
    return 'What $name may do';
  }

  @override
  String get pl_review_fresh => 'The plugin is installed but not running.';

  @override
  String pl_review_source(String source, String version) {
    return 'From $source, version $version.';
  }

  @override
  String get pl_hooks => 'It reacts to';

  @override
  String get pl_hooks_none => 'No events.';

  @override
  String get pl_hosts => 'It may contact';

  @override
  String get pl_hosts_none => 'No other computers.';

  @override
  String get pl_trust_warning =>
      'A plugin runs inside the daemon and can contact the hosts listed. Only switch on plugins you trust.';

  @override
  String get pl_keep_off => 'Keep it off';

  @override
  String get pl_enable => 'Switch it on';

  @override
  String get nav_manage_browser => 'Browser tool';

  @override
  String get br_intro =>
      'Some pages only show their downloads in a real browser. Open one here and the daemon\'s headless browser lists what the page leads to: files, video and audio streams.';

  @override
  String get br_open_title => 'Open a page';

  @override
  String get br_url => 'Page address';

  @override
  String get br_url_invalid =>
      'Use an address that starts with http:// or https://.';

  @override
  String get br_open => 'Open';

  @override
  String get br_opening => 'Opening…';

  @override
  String get br_error => 'The page could not be opened.';

  @override
  String br_result_info(String url, String group) {
    return 'Opened $url in the group $group.';
  }

  @override
  String get br_none => 'The page led to no downloads.';

  @override
  String get br_download => 'Download';

  @override
  String br_added(String name) {
    return 'Added $name';
  }

  @override
  String get br_profiles_title => 'Browser profiles';

  @override
  String get br_profiles_desc =>
      'Each site group has its own profile, which keeps the logins of the pages opened there.';

  @override
  String get br_profiles_none => 'No profiles yet.';

  @override
  String get br_profiles_error => 'The profiles could not be listed.';

  @override
  String br_profile_delete(String group) {
    return 'Delete the profile $group';
  }

  @override
  String br_profile_delete_title(String group) {
    return 'Delete the profile of $group?';
  }

  @override
  String get br_profile_delete_message =>
      'Its cookies and stored data are removed. It cannot be deleted while its browser runs.';

  @override
  String get br_profile_delete_confirm => 'Delete profile';

  @override
  String get br_state_title => 'The headless browser';

  @override
  String get br_state_in_use => 'In use';

  @override
  String get br_state_unused => 'Not used yet';

  @override
  String get br_state_running => 'Running';

  @override
  String get br_state_none => 'None';

  @override
  String get br_state_max => 'At most at once';

  @override
  String get br_tools_title => 'Programs';

  @override
  String get nav_manage_transfer => 'Import and export';

  @override
  String get tr_intro =>
      'Add many downloads from a list, or write your downloads out as a list. Nothing is added until you have seen what would happen.';

  @override
  String get tr_import_title => 'Import a list';

  @override
  String get tr_list => 'The list';

  @override
  String get tr_list_desc => 'Paste it here, or choose a file.';

  @override
  String get tr_choose => 'Choose a file…';

  @override
  String get tr_format => 'Kind of list';

  @override
  String get tr_format_urls => 'One link per line';

  @override
  String get tr_format_json => 'dlm JSON';

  @override
  String get tr_format_aria2 => 'aria2 input file';

  @override
  String get tr_default_queue => 'The default queue';

  @override
  String get tr_duplicates => 'Add duplicates too';

  @override
  String get tr_duplicates_desc =>
      'Otherwise links that are already in the list are skipped.';

  @override
  String get tr_preview => 'Preview';

  @override
  String tr_preview_summary(int ok, int failed) {
    return 'Would add $ok, would not add $failed.';
  }

  @override
  String get tr_export_title => 'Export downloads';

  @override
  String get tr_export_format => 'File kind to export';

  @override
  String get tr_export_queue => 'Queue';

  @override
  String get tr_all_queues => 'All queues';

  @override
  String get tr_export_status => 'Which downloads';

  @override
  String get tr_all_statuses => 'All of them';

  @override
  String get tr_export => 'Export';

  @override
  String tr_export_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads',
      one: '1 download',
    );
    return '$_temp0';
  }

  @override
  String get tr_export_text => 'The exported list';

  @override
  String get nav_manage_statistics => 'Statistics';

  @override
  String get st_error => 'The statistics could not be read.';

  @override
  String get st_totals => 'Totals';

  @override
  String get st_tasks => 'Downloads';

  @override
  String get st_downloaded => 'Downloaded in all';

  @override
  String get st_by_status => 'By state';

  @override
  String get st_by_engine => 'By engine';

  @override
  String st_completed_in(String period) {
    return 'Finished in the last $period';
  }

  @override
  String get st_bucket => 'Bucket';

  @override
  String get st_bucket_hour => 'Per hour';

  @override
  String get st_bucket_day => 'Per day';

  @override
  String get st_group => 'Split by';

  @override
  String get st_group_none => 'Nothing';

  @override
  String get st_group_engine => 'Engine';

  @override
  String get st_group_queue => 'Queue';

  @override
  String get st_timeline => 'Traffic';

  @override
  String st_timeline_summary(String down, String up) {
    return 'Downloaded $down, uploaded $up in this range.';
  }

  @override
  String get st_timeline_empty => 'No traffic in this range.';

  @override
  String get st_all_traffic => 'All traffic';

  @override
  String get st_history => 'Finished downloads';

  @override
  String get st_history_search => 'Search by name or link';

  @override
  String get st_history_empty => 'No finished downloads.';

  @override
  String get st_history_more => 'Show more';

  @override
  String get st_cleanup_title => 'Clean up';

  @override
  String get st_cleanup_desc =>
      'Removes finished downloads from the list. The automatic cleanup of the retention setting never deletes files.';

  @override
  String get st_cleanup_days => 'Older than';

  @override
  String get st_days => 'days';

  @override
  String get st_cleanup_files => 'Also delete the files';

  @override
  String get st_cleanup_files_desc =>
      'Off keeps the files on disk and only removes the list entries.';

  @override
  String get st_cleanup_preview => 'Check what would go';

  @override
  String st_cleanup_preview_result(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads',
      one: '1 download',
    );
    return '$_temp0 ($size) would be removed.';
  }

  @override
  String get st_cleanup_go => 'Clean up';

  @override
  String st_cleanup_confirm_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads',
      one: '1 download',
    );
    return 'Remove $_temp0?';
  }

  @override
  String get st_cleanup_confirm_list =>
      'They leave the list; the files stay where they are.';

  @override
  String get st_cleanup_confirm_files =>
      'They leave the list and their files are deleted from the disk. This cannot be undone.';

  @override
  String st_cleanup_done(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads',
      one: '1 download',
    );
    return 'Removed $_temp0';
  }

  @override
  String st_cleanup_done_failed(int deleted, int failed) {
    return 'Removed $deleted; $failed could not be removed';
  }

  @override
  String get nav_manage_daemon => 'Daemon';

  @override
  String get dm_intro =>
      'How the download service itself starts: where it listens, its engines and programs, its logging. Most changes take effect after a restart.';

  @override
  String dm_file(String file) {
    return 'Read from $file';
  }

  @override
  String dm_file_error(String error) {
    return 'The configuration file has a problem: $error';
  }

  @override
  String get dm_pending_title => 'A restart is needed';

  @override
  String get dm_pending_message =>
      'Some saved changes are waiting for the daemon to restart.';

  @override
  String get dm_restart_now => 'Restart now';

  @override
  String dm_pending_value(String value) {
    return 'after the restart: $value';
  }

  @override
  String get dm_read_only => 'set by a flag or the environment';

  @override
  String get dm_saved => 'Configuration saved';

  @override
  String get dm_needs_restart => 'These changes take effect after a restart.';

  @override
  String get dm_restart_title => 'Restart the daemon?';

  @override
  String get dm_restart_message =>
      'Downloads that are running are requeued and start again afterwards.';

  @override
  String get dm_restart_confirm => 'Restart';

  @override
  String get dm_restarting => 'The daemon is restarting';

  @override
  String get dm_log_title => 'Log';

  @override
  String get nav_manage_access => 'Access';

  @override
  String get ac_identity => 'This app';

  @override
  String get ac_signed_in => 'Signed in as';

  @override
  String ac_who(String name, String scope, String kind) {
    return '$name ($scope, $kind)';
  }

  @override
  String get ac_scope_admin => 'can change everything';

  @override
  String get ac_scope_read => 'read only';

  @override
  String get ac_primary => 'the main token';

  @override
  String get ac_named => 'a named token';

  @override
  String get ac_rotate => 'Replace the main token';

  @override
  String get ac_rotate_desc =>
      'Makes a new main token and stops the old one working at once.';

  @override
  String get ac_rotate_title => 'Replace the main token?';

  @override
  String get ac_rotate_message =>
      'Every client that uses the old token, such as a browser extension or a script, stops working until it is given the new one. This app is signed in again automatically.';

  @override
  String get ac_rotate_confirm => 'Replace it';

  @override
  String get ac_rotated_title => 'The new main token';

  @override
  String get ac_tokens => 'Named tokens';

  @override
  String get ac_tokens_desc =>
      'Give a dashboard, a script or another device a token of its own, and revoke it when it is no longer needed.';

  @override
  String get ac_tokens_none => 'No named tokens.';

  @override
  String get ac_tokens_error => 'The tokens could not be listed.';

  @override
  String get ac_add => 'Add a token';

  @override
  String get ac_add_title => 'Add a token';

  @override
  String get ac_name => 'Name';

  @override
  String get ac_name_hint => 'dashboard';

  @override
  String get ac_scope => 'Can';

  @override
  String get ac_scope_desc =>
      'A read-only token can look at everything except cookies, and change nothing.';

  @override
  String get ac_create => 'Create';

  @override
  String ac_created_title(String name) {
    return 'The token $name';
  }

  @override
  String ac_created(String date) {
    return 'created $date';
  }

  @override
  String get ac_never_used => 'never used';

  @override
  String ac_last_used(String date) {
    return 'last used $date';
  }

  @override
  String ac_delete(String name) {
    return 'Revoke the token $name';
  }

  @override
  String ac_delete_title(String name) {
    return 'Revoke the token $name?';
  }

  @override
  String get ac_delete_message => 'Whatever uses it stops working.';

  @override
  String get ac_delete_confirm => 'Revoke token';

  @override
  String get ac_secret_once =>
      'This is the only time the token is shown. Copy it now and keep it somewhere safe.';

  @override
  String get ac_secret_done => 'I have copied it';

  @override
  String get ac_secret_gone => 'The token is not shown again';

  @override
  String get ac_nh_title => 'Browser extension';

  @override
  String get ac_nh_desc =>
      'The extension talks to the download service through a native host that is registered with each browser. Installing works only on the computer the daemon runs on.';

  @override
  String get ac_nh_origins => 'Allowed extensions';

  @override
  String get ac_nh_no_origins => 'None yet';

  @override
  String get ac_nh_error => 'The extension host cannot be managed from here.';

  @override
  String get ac_nh_ids => 'Extension IDs';

  @override
  String get ac_nh_ids_desc =>
      'Separated by commas or spaces. Needed to install.';

  @override
  String get ac_nh_install => 'Install for all browsers';

  @override
  String get ac_nh_remove => 'Remove';

  @override
  String ac_nh_done(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Done for $count browsers',
      one: 'Done for 1 browser',
    );
    return '$_temp0';
  }

  @override
  String get ac_mcp_title => 'Assistants (MCP)';

  @override
  String get ac_mcp_desc =>
      'An AI assistant that speaks the Model Context Protocol can add and manage downloads. It signs in with a token.';

  @override
  String get ac_mcp_url => 'Address';

  @override
  String get ac_mcp_claude => 'Claude Code';

  @override
  String get ac_mcp_json => 'Settings file (JSON)';

  @override
  String get ac_mcp_token_note =>
      'Replace <token> with a token from this page. A read-only token lets an assistant look but not change anything.';

  @override
  String get nav_manage_preferences => 'Preferences';

  @override
  String get pref_intro => 'How the app looks and asks. Changes apply at once.';

  @override
  String get pref_appearance => 'Appearance';

  @override
  String get pref_theme => 'Theme';

  @override
  String get pref_theme_system => 'System';

  @override
  String get pref_theme_light => 'Light';

  @override
  String get pref_theme_dark => 'Dark';

  @override
  String get pref_accent => 'Accent colour';

  @override
  String get pref_accent_default => 'The system\'s';

  @override
  String get pref_accent_blue => 'Blue';

  @override
  String get pref_accent_green => 'Green';

  @override
  String get pref_accent_orange => 'Orange';

  @override
  String get pref_accent_red => 'Red';

  @override
  String get pref_accent_purple => 'Purple';

  @override
  String get pref_accent_pink => 'Pink';

  @override
  String get pref_skin => 'Look and feel';

  @override
  String get pref_skin_desc =>
      'The app follows your system; choose another to see the app dressed as on that system.';

  @override
  String get pref_skin_auto => 'Match this system';

  @override
  String get pref_skin_macos => 'macOS';

  @override
  String get pref_skin_fluent => 'Windows (Fluent)';

  @override
  String get pref_skin_adwaita => 'GNOME (Adwaita)';

  @override
  String get pref_skin_breeze => 'KDE (Breeze)';

  @override
  String get pref_density => 'Row height';

  @override
  String get pref_confirmations => 'Asking first';

  @override
  String get pref_confirm_delete => 'Ask before deleting downloads';

  @override
  String get pref_confirm_delete_desc =>
      'Off deletes at once, keeping the files on disk.';

  @override
  String get nav_manage_about => 'About';

  @override
  String get ab_title => 'dlm';

  @override
  String get ab_blurb =>
      'A download manager for files, torrents and streams, made of this app and a download service that does the work.';

  @override
  String get ab_app => 'This app';

  @override
  String get ab_daemon => 'The download service';

  @override
  String get ab_version => 'Version';

  @override
  String get ab_api => 'Talks API revision';

  @override
  String ab_api_value(int current, int oldest) {
    return 'revision $current, works with $oldest and newer';
  }

  @override
  String get ab_system => 'System';

  @override
  String get ab_address => 'Listens on';

  @override
  String get ab_compat => 'Together';

  @override
  String get ab_compat_ok => 'They work together.';

  @override
  String get ab_compat_app_old =>
      'The service needs a newer version of this app.';

  @override
  String get ab_compat_daemon_old =>
      'The service is older than this app supports.';

  @override
  String get ab_compat_unknown => 'Not connected.';

  @override
  String get ab_support => 'Support';

  @override
  String get ab_diagnostics => 'Diagnostics';

  @override
  String get ab_diagnostics_copy => 'Copy diagnostics';

  @override
  String get ab_diagnostics_desc =>
      'Puts versions, the connections (without tokens) and the recent log on the clipboard, with secrets removed, for you to paste into a bug report.';

  @override
  String get ab_diagnostics_copied => 'Diagnostics copied';

  @override
  String get ab_licences => 'Open-source licences';

  @override
  String get ab_licences_list => 'Packages';

  @override
  String get ab_licences_show => 'Show the licences';

  @override
  String get ab_licences_desc =>
      'dlm is built from open-source packages. Their licences are listed here.';

  @override
  String get ab_licences_none => 'No licences are registered in this build.';

  @override
  String ab_licences_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count licence texts',
      one: '1 licence text',
    );
    return '$_temp0';
  }
}
