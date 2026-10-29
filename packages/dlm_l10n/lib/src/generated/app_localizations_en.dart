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
}
