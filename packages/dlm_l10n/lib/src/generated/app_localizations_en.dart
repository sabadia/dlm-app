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
  String get app_name => 'DLM';

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
  String get menu_file => 'File';

  @override
  String get menu_go => 'Go';

  @override
  String get menu_window => 'Window';

  @override
  String get menu_help => 'Help';

  @override
  String get menu_about => 'About DLM';

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
  String get setup_system_title => 'On this computer';

  @override
  String get setup_system_desc =>
      'Optional. All of this can be changed later in Preferences and under Access.';

  @override
  String get setup_login => 'Start when I log in';

  @override
  String get setup_login_desc =>
      'Keeps downloads going without opening the app by hand.';

  @override
  String get setup_ext => 'Browser extension';

  @override
  String get setup_ext_desc => 'Send downloads from your browser to this app.';

  @override
  String setup_ext_connected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Set up for $count browsers',
      one: 'Set up for 1 browser',
    );
    return '$_temp0';
  }

  @override
  String get setup_ext_none => 'Not set up';

  @override
  String get setup_ext_unknown => 'Not available';

  @override
  String get setup_ext_open => 'Set up…';

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
  String get view_sort => 'Sort by';

  @override
  String get view_sort_default => 'Default order';

  @override
  String get view_sort_added => 'Date added';

  @override
  String get view_sort_name => 'Name';

  @override
  String get view_sort_size => 'Size';

  @override
  String get view_sort_completed => 'Date completed';

  @override
  String get view_sort_asc => 'Ascending';

  @override
  String get view_sort_desc => 'Descending';

  @override
  String get view_group => 'Group by';

  @override
  String get view_group_none => 'No grouping';

  @override
  String get view_group_status => 'Status';

  @override
  String get view_group_queue => 'Queue';

  @override
  String get view_group_engine => 'Engine';

  @override
  String group_header(String name, int count) {
    return '$name ($count)';
  }

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
  String get col_category => 'Category';

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
  String get add_torrent_unreadable => 'That torrent file could not be read.';

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
  String get tr_format_json => 'DLM JSON';

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
  String get pref_accent_indigo => 'DLM indigo';

  @override
  String get pref_accent_custom => 'Custom colour';

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
  String get tray_tooltip => 'DLM';

  @override
  String get tray_show => 'Show DLM';

  @override
  String get tray_pause_all => 'Pause all';

  @override
  String get tray_resume_all => 'Resume all';

  @override
  String get tray_add => 'Add downloads…';

  @override
  String get tray_quit => 'Quit DLM';

  @override
  String get notif_completed => 'Download finished';

  @override
  String get notif_failed => 'Download failed';

  @override
  String get notif_expired => 'Link expired';

  @override
  String get notif_open => 'Open';

  @override
  String get notif_folder => 'Show in folder';

  @override
  String get notif_retry => 'Retry';

  @override
  String get notif_queue => 'Queue finished';

  @override
  String get setup_no_tray =>
      'This system has no menu-bar icon, so closing the window quits the app.';

  @override
  String get pref_notifications => 'Notifications';

  @override
  String get pref_tray => 'Show an icon in the menu bar or notification area';

  @override
  String get pref_tray_desc =>
      'Closing the window then keeps the app running; quit from the icon\'s menu. Without an icon, closing the window quits.';

  @override
  String get pref_notify => 'Tell me when a download finishes or fails';

  @override
  String get pref_notify_desc =>
      'A system notification with buttons to open the file or retry.';

  @override
  String get drop_nothing =>
      'Nothing to add: drop .torrent files or text files with links.';

  @override
  String get clip_offer_title => 'A link is on the clipboard';

  @override
  String get clip_offer_add => 'Add';

  @override
  String get clip_offer_dismiss => 'Not now';

  @override
  String get pref_units => 'Sizes';

  @override
  String get pref_units_iec => 'Kibibytes (KiB)';

  @override
  String get pref_units_si => 'Kilobytes (kB)';

  @override
  String get pref_language => 'Language';

  @override
  String get pref_language_system => 'System';

  @override
  String get pref_clipboard => 'Watch the clipboard for links';

  @override
  String get pref_clipboard_desc =>
      'When the window is in front, offer to add an http, ftp, magnet or ed2k link that was copied. Off until you turn it on. The clipboard is not written to the log.';

  @override
  String get pref_shortcuts => 'Shortcuts';

  @override
  String get pref_global => 'Global shortcuts';

  @override
  String get pref_global_desc =>
      'Work while another program has the focus. Off until you set a chord; a chord needs Ctrl, Alt, Shift or the system key.';

  @override
  String get pref_global_unsupported =>
      'Not available here: a Wayland session does not let apps claim keys for the whole desktop.';

  @override
  String get cmd_global_toggle => 'Show or hide DLM';

  @override
  String get cmd_global_clipboard => 'Add the link on the clipboard';

  @override
  String get pref_shortcuts_clear => 'Clear';

  @override
  String get pref_shortcuts_none => 'Not set';

  @override
  String get pref_shortcuts_change => 'Change';

  @override
  String get pref_shortcuts_press => 'Press the new shortcut';

  @override
  String get pref_shortcuts_reset => 'Reset shortcuts';

  @override
  String get ab_updates => 'Updates';

  @override
  String get ab_channel => 'Channel';

  @override
  String get ab_channel_stable => 'Stable';

  @override
  String get ab_channel_beta => 'Beta';

  @override
  String get ab_check => 'Check for updates';

  @override
  String get ab_checking => 'Checking…';

  @override
  String get ab_up_to_date => 'This is the newest version on this channel.';

  @override
  String ab_available(String version) {
    return '$version is available';
  }

  @override
  String get ab_open_release => 'Open the release';

  @override
  String get ab_check_failed => 'The update check did not succeed.';

  @override
  String pref_shortcuts_conflict(String command) {
    return 'Already used by $command';
  }

  @override
  String get pref_startup => 'Startup';

  @override
  String get pref_login => 'Start when I log in';

  @override
  String get pref_login_desc =>
      'Opens the app in the background when you sign in to this computer.';

  @override
  String get pref_start_hidden => 'Start hidden';

  @override
  String get pref_start_hidden_desc =>
      'When started at login, keep the window closed; open it from the tray icon.';

  @override
  String get pref_daemon_service => 'Keep downloading without the app';

  @override
  String get pref_daemon_service_desc =>
      'Starts the download service at login on its own, so queues and schedules run while the app is closed.';

  @override
  String get nav_manage_about => 'About';

  @override
  String get ab_title => 'DLM';

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
      'DLM is built from open-source packages. Their licences are listed here.';

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

  @override
  String get nav_tools => 'Tools';

  @override
  String get hub_button => 'Tools, manage and settings';

  @override
  String get hub_close => 'Close';

  @override
  String add_category(String name, String dir) {
    return 'Will be sorted into $name: $dir';
  }

  @override
  String add_login_stored(String host) {
    return 'A login is stored for $host';
  }

  @override
  String get add_login_add => 'Add a login';

  @override
  String add_cookies_stored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cookies are stored for this site',
      one: '1 cookie is stored for this site',
    );
    return '$_temp0';
  }

  @override
  String get add_cookies_none => 'No cookies are stored for this site';

  @override
  String add_login_none(String host) {
    return 'No login is stored for $host';
  }

  @override
  String get insp_tab_events => 'Events';

  @override
  String get ev_created => 'Added to the list';

  @override
  String ev_status(String from, String to) {
    return '$from → $to';
  }

  @override
  String ev_refresh(String strategy, String outcome) {
    return 'Link renewal with $strategy: $outcome';
  }

  @override
  String get ev_current_error => 'Failed';

  @override
  String get ev_none =>
      'Nothing has happened to this download since the app connected.';

  @override
  String get ev_note =>
      'This is what the app has seen since it connected; the daemon does not keep a longer history.';
}

/// The translations for English (`en_XA`).
class AppLocalizationsEnXa extends AppLocalizationsEn {
  AppLocalizationsEnXa() : super('en_XA');

  @override
  String get problem_task_not_found =>
      '[Thàt dôwñlôàd dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_queue_not_found =>
      '[Thàt qûéûé dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_category_not_found =>
      '[Thàt çàtégôrý dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_webhook_not_found =>
      '[Thàt wébhôôk dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_credential_not_found =>
      '[Thàt lôgîñ dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_plugin_not_found =>
      '[Thàt plûgîñ dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_cookie_not_found =>
      '[Thàt çôôkîé dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~]';

  @override
  String get problem_engine_not_found =>
      '[Thàt dôwñlôàd éñgîñé dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~~~~]';

  @override
  String get problem_browser_profile_not_found =>
      '[Thàt brôwšér prôfîlé dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~~~~]';

  @override
  String get problem_browser_result_not_found =>
      '[Thàt pàgé réšûlt dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~~]';

  @override
  String get problem_browser_candidate_not_found =>
      '[Thàt dôwñlôàd çàñdîdàté dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~~~~]';

  @override
  String get problem_refresh_attempt_not_found =>
      '[Thàt lîñk réfréšh dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~~~]';

  @override
  String get problem_resolve_result_not_found =>
      '[Thàt lîñk çhéçk dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~~~~]';

  @override
  String get problem_queue_name_taken =>
      '[Â qûéûé wîth thàt ñàmé àlréàdý éxîštš.~~~~~~~~~~~~]';

  @override
  String get problem_category_name_taken =>
      '[Â çàtégôrý wîth thàt ñàmé àlréàdý éxîštš.~~~~~~~~~~~~~]';

  @override
  String get problem_queue_not_empty =>
      '[Thé qûéûé štîll hàš dôwñlôàdš. Môvé ôr délété thém fîršt.~~~~~~~~~~~~~~~~~~]';

  @override
  String problem_task_duplicate(String status) {
    return '[Thîš fîlé îš àlréàdý îñ ýôûr dôwñlôàdš ($status).~~~~~~~~~~~~~~~]';
  }

  @override
  String get problem_task_file_exists =>
      '[Â fîlé wîth thàt ñàmé àlréàdý éxîštš îñ thé tàrgét fôldér.~~~~~~~~~~~~~~~~~~]';

  @override
  String problem_task_invalid_state(String operation, String status) {
    return '[Thîš dôwñlôàd çàññôt bé $operation whîlé ît îš $status.~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get problem_task_invalid_transition =>
      '[Thîš dôwñlôàd çàññôt çhàñgé tô thàt štàté rîght ñôw.~~~~~~~~~~~~~~~~]';

  @override
  String get problem_task_locked =>
      '[Thîš dôwñlôàd îš bûšý. Trý àgàîñ îñ à môméñt.~~~~~~~~~~~~~~]';

  @override
  String get problem_task_state_changed =>
      '[Thîš dôwñlôàd çhàñgéd whîlé ýôû wéré wôrkîñg ôñ ît. Çhéçk îtš štàté àñd trý àgàîñ.~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_browser_running =>
      '[Thé brôwšér îš îñ ûšé. Çlôšé îtš pàgéš fîršt.~~~~~~~~~~~~~~]';

  @override
  String get problem_category_bad_dir =>
      '[Thàt fôldér îš ñôt àllôwéd fôr à çàtégôrý.~~~~~~~~~~~~~]';

  @override
  String get problem_settings_invalid =>
      '[Šômé šéttîñgš àré ñôt vàlîd. Çhéçk thé hîghlîghtéd fîéldš.~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_validation_failed =>
      '[Šômé vàlûéš àré ñôt vàlîd. Çhéçk thé hîghlîghtéd fîéldš.~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_invalid_argument =>
      '[Thôšé vàlûéš àré ñôt vàlîd.~~~~~~~~~]';

  @override
  String get problem_settings_changed =>
      '[Thé šéttîñgš wéré çhàñgéd šôméwhéré élšé. Thé làtéšt šéttîñgš hàvé bééñ lôàdéd; révîéw ýôûr çhàñgé àñd àpplý ît àgàîñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_browser_unavailable =>
      '[Ñô brôwšér îš àvàîlàblé. Îñštàll Çhrômé, Çhrômîûm, Édgé ôr Bràvé, ôr àllôw dôwñlôàdîñg ôñé îñ thé šéttîñgš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String problem_origin_failed(String code) {
    return '[Thé šérvér ôf thé fîlé dîd ñôt àñšwér prôpérlý ($code).~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get problem_request_cancelled =>
      '[Thé réqûéšt wàš çàñçélléd.~~~~~~~~]';

  @override
  String get problem_service_unavailable =>
      '[Thé dôwñlôàd šérvîçé îš ñôt réàdý ýét. Trý àgàîñ îñ à môméñt.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_bad_request =>
      '[Thé réqûéšt wàš ñôt ûñdérštôôd.~~~~~~~~~~]';

  @override
  String get problem_unauthorized =>
      '[Thé àççéšš tôkéñ wàš réjéçtéd. Çhéçk thé tôkéñ ôf thîš çôññéçtîôñ.~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_forbidden => '[Ýôû àré ñôt àllôwéd tô dô thàt.~~~~~~~~~~]';

  @override
  String get problem_not_found => '[Thàt dôéš ñôt éxîšt (àñý môré).~~~~~~~~~~]';

  @override
  String get problem_conflict =>
      '[Thàt çôñflîçtš wîth thé çûrréñt štàté. Réfréšh àñd trý àgàîñ.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_precondition_failed =>
      '[Thàt wàš çhàñgéd šôméwhéré élšé. Réfréšh àñd trý àgàîñ.~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_too_many_requests =>
      '[Tôô màñý réqûéštš. Wàît à môméñt.~~~~~~~~~~]';

  @override
  String get problem_server_error =>
      '[Thé dôwñlôàd šérvîçé hàd àñ îñtérñàl prôblém.~~~~~~~~~~~~~~]';

  @override
  String get problem_connection_lost =>
      '[Thé dôwñlôàd šérvîçé çàññôt bé réàçhéd.~~~~~~~~~~~~]';

  @override
  String get problem_connection_timeout =>
      '[Thé dôwñlôàd šérvîçé dîd ñôt àñšwér îñ tîmé.~~~~~~~~~~~~~~]';

  @override
  String get problem_connection_certificate =>
      '[Thé çértîfîçàté ôf thé dôwñlôàd šérvîçé çhàñgéd ôr îš ñôt trûštéd. Dô ñôt çôñtîñûé ûñléšš ýôû éxpéçt thîš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get problem_unknown => '[Šôméthîñg wéñt wrôñg.~~~~~~~]';

  @override
  String get relativeJustNow => '[jûšt ñôw~~~]';

  @override
  String relativeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mîñûtéš àgô',
      one: '1 mîñûté àgô',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String relativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hôûrš àgô',
      one: '1 hôûr àgô',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get relativeYesterday => '[ýéštérdàý~~~]';

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dàýš àgô',
      one: '1 dàý àgô',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get app_name => '[DLM~]';

  @override
  String get nav_label => '[Ñàvîgàtîôñ~~~]';

  @override
  String get nav_all => '[Âll Dôwñlôàdš~~~~]';

  @override
  String get nav_active => '[Âçtîvé~~]';

  @override
  String get nav_queued => '[Qûéûéd~~]';

  @override
  String get nav_paused => '[Pàûšéd~~]';

  @override
  String get nav_completed => '[Çômplétéd~~~]';

  @override
  String get nav_failed => '[Fàîléd~~]';

  @override
  String get nav_queues => '[Qûéûéš~~]';

  @override
  String get toolbar_search_placeholder => '[Šéàrçh dôwñlôàdš~~~~~]';

  @override
  String get toolbar_search_clear => '[Çléàr šéàrçh~~~~]';

  @override
  String get toolbar_inspector_show => '[Šhôw détàîlš~~~~]';

  @override
  String get toolbar_inspector_hide => '[Hîdé détàîlš~~~~]';

  @override
  String get toolbar_palette => '[Çômmàñdš~~~]';

  @override
  String get toolbar_label => '[Tôôlbàr~~~]';

  @override
  String get inspector_empty_title => '[Ñô dôwñlôàd šéléçtéd~~~~~~]';

  @override
  String get inspector_empty_message =>
      '[Šéléçt à dôwñlôàd tô šéé îtš détàîlš.~~~~~~~~~~~~]';

  @override
  String get inspector_resize => '[Réšîžé détàîlš~~~~~]';

  @override
  String get sidebar_resize => '[Réšîžé šîdébàr~~~~~]';

  @override
  String get palette_placeholder => '[Týpé à çômmàñd~~~~~]';

  @override
  String get palette_no_results => '[Ñô màtçhîñg çômmàñd~~~~~~]';

  @override
  String get palette_label => '[Çômmàñd pàlétté~~~~~]';

  @override
  String get menu_file => '[Fîlé~~]';

  @override
  String get menu_go => '[Gô~]';

  @override
  String get menu_window => '[Wîñdôw~~]';

  @override
  String get menu_help => '[Hélp~~]';

  @override
  String get menu_about => '[Âbôût DLM~~~]';

  @override
  String command_go_to(String destination) {
    return '[Gô tô $destination~~~~~~]';
  }

  @override
  String get command_toggle_inspector => '[Šhôw ôr hîdé détàîlš~~~~~~]';

  @override
  String get command_focus_search => '[Šéàrçh dôwñlôàdš~~~~~]';

  @override
  String get connection_connecting_title =>
      '[Çôññéçtîñg tô thé dôwñlôàd šérvîçé~~~~~~~~~~~]';

  @override
  String connection_connecting_message(String name) {
    return '[Štàrtîñg $name…~~~~~]';
  }

  @override
  String get connection_failed_title =>
      '[Çàññôt réàçh thé dôwñlôàd šérvîçé~~~~~~~~~~]';

  @override
  String connection_failed_message(String name) {
    return '[Thé àpp çôûld ñôt çôññéçt tô $name.~~~~~~~~~~~]';
  }

  @override
  String get connection_retry => '[Trý àgàîñ~~~]';

  @override
  String get connection_token_rejected_title =>
      '[Thé àççéšš tôkéñ wàš réfûšéd~~~~~~~~~]';

  @override
  String connection_token_rejected_message(String name) {
    return '[$name dîd ñôt àççépt thé šàvéd tôkéñ.~~~~~~~~~~~~]';
  }

  @override
  String get connection_incompatible_title =>
      '[Thîš véršîôñ ôf thé àpp çàññôt tàlk tô thàt šérvîçé~~~~~~~~~~~~~~~~]';

  @override
  String get connection_incompatible_message =>
      '[Ûpdàté thé àpp ôr thé šérvîçé šô théîr véršîôñš màtçh.~~~~~~~~~~~~~~~~~]';

  @override
  String get connection_trust_title => '[Trûšt thîš šérvér?~~~~~~]';

  @override
  String connection_trust_message(String name) {
    return '[$name préšéñtéd à çértîfîçàté thé àpp hàš ñôt šééñ béfôré. Çhéçk thàt thé fîñgérprîñt bélôw màtçhéš thé ôñé ôñ thé šérvér.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get connection_trust_accept => '[Trûšt àñd çôññéçt~~~~~~]';

  @override
  String get connection_trust_reject => '[Çàñçél~~]';

  @override
  String get status_connected => '[Çôññéçtéd~~~]';

  @override
  String get connection_trust_subject => '[Šûbjéçt~~~]';

  @override
  String get connection_trust_issuer => '[Îššûér~~]';

  @override
  String get connection_trust_expires => '[Vàlîd ûñtîl~~~~]';

  @override
  String get connection_trust_fingerprint => '[Fîñgérprîñt~~~~]';

  @override
  String get connection_certificate_changed =>
      '[Thé šérvér\'š çértîfîçàté îš dîfféréñt frôm thé ôñé ýôû trûštéd. Dô ñôt çôñtîñûé ûñléšš ýôû kñôw ît wàš réplàçéd.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String connection_reason(String reason) {
    return '[Réàšôñ: $reason~~~~~]';
  }

  @override
  String get col_name => '[Ñàmé~~]';

  @override
  String get col_status => '[Štàtûš~~]';

  @override
  String get col_progress => '[Prôgréšš~~~]';

  @override
  String get col_size => '[Šîžé~~]';

  @override
  String get col_speed => '[Špééd~~]';

  @override
  String get col_eta => '[Tîmé léft~~~]';

  @override
  String get col_queue => '[Qûéûé~~]';

  @override
  String get col_added => '[Âddéd~~]';

  @override
  String get task_status_queued => '[Qûéûéd~~]';

  @override
  String get task_status_running => '[Dôwñlôàdîñg~~~~]';

  @override
  String get task_status_paused => '[Pàûšéd~~]';

  @override
  String get task_status_awaiting_link => '[Wàîtîñg fôr à lîñk~~~~~~]';

  @override
  String get task_status_refreshing => '[Réfréšhîñg lîñk~~~~~]';

  @override
  String get task_status_postprocessing => '[Fîñîšhîñg~~~]';

  @override
  String get task_status_completed => '[Çômplétéd~~~]';

  @override
  String get task_status_error => '[Fàîléd~~]';

  @override
  String get task_status_unknown => '[Ûñkñôwñ~~~]';

  @override
  String get task_unnamed => '[Ûññàméd dôwñlôàd~~~~~]';

  @override
  String task_eta(String time) {
    return '[$time léft~~~~]';
  }

  @override
  String task_row_label(String name, String status) {
    return '[$name, $status~~~~~]';
  }

  @override
  String get table_downloads_label => '[Dôwñlôàdš~~~]';

  @override
  String get table_sorted_ascending => '[šôrtéd àšçéñdîñg~~~~~]';

  @override
  String get table_sorted_descending => '[šôrtéd déšçéñdîñg~~~~~~]';

  @override
  String table_resize_column(String column) {
    return '[Réšîžé $column~~~~~]';
  }

  @override
  String get table_loading_row => '[Lôàdîñg~~~]';

  @override
  String get list_loading => '[Lôàdîñg dôwñlôàdš~~~~~~]';

  @override
  String get list_empty_title => '[Ñô dôwñlôàdš héré~~~~~~]';

  @override
  String get list_empty_message =>
      '[Dôwñlôàdš ýôû àdd wîll àppéàr îñ thîš lîšt.~~~~~~~~~~~~~]';

  @override
  String get list_empty_search_title =>
      '[Ñôthîñg màtçhéš ýôûr šéàrçh~~~~~~~~~]';

  @override
  String get list_empty_search_message =>
      '[Trý dîfféréñt wôrdš ôr çléàr thé šéàrçh.~~~~~~~~~~~~]';

  @override
  String get list_error_title => '[Çôûld ñôt lôàd thé dôwñlôàdš~~~~~~~~~]';

  @override
  String get list_retry => '[Trý àgàîñ~~~]';

  @override
  String get action_pause => '[Pàûšé~~]';

  @override
  String get action_resume => '[Réšûmé~~]';

  @override
  String get action_restart => '[Dôwñlôàd àgàîñ~~~~~]';

  @override
  String get action_delete => '[Délété…~~~]';

  @override
  String get action_copy_link => '[Çôpý lîñk~~~]';

  @override
  String get action_undo => '[Ûñdô~~]';

  @override
  String get action_dismiss => '[Dîšmîšš~~~]';

  @override
  String toast_paused(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pàûšéd $count dôwñlôàdš',
      one: 'Pàûšéd 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String toast_resumed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Réšûméd $count dôwñlôàdš',
      one: 'Réšûméd 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String toast_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Délétéd $count dôwñlôàdš',
      one: 'Délétéd 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get toast_restarted => '[Dôwñlôàd réštàrtéd~~~~~~]';

  @override
  String get toast_link_copied => '[Lîñk çôpîéd~~~~]';

  @override
  String toast_some_failed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš çôûld ñôt bé çhàñgéd',
      one: '1 dôwñlôàd çôûld ñôt bé çhàñgéd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get toast_failure_unknown => '[Šôméthîñg wéñt wrôñg.~~~~~~~]';

  @override
  String delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Délété $count dôwñlôàdš?',
      one: 'Délété thîš dôwñlôàd?',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get delete_message =>
      '[Théý àré rémôvéd frôm thé lîšt. Théîr fîléš štàý ôñ dîšk ûñléšš ýôû çhôôšé ôthérwîšé.~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get delete_files => '[Âlšô délété thé dôwñlôàdéd fîléš~~~~~~~~~~]';

  @override
  String get delete_confirm => '[Délété~~]';

  @override
  String get delete_cancel => '[Çàñçél~~]';

  @override
  String selection_count(int count) {
    return '[$count šéléçtéd~~~~~]';
  }

  @override
  String get banner_reconnecting_title =>
      '[Çôññéçtîôñ tô thé dôwñlôàd šérvîçé lôšt~~~~~~~~~~~~]';

  @override
  String get banner_reconnecting_message => '[Trýîñg tô réçôññéçt…~~~~~~]';

  @override
  String get banner_daemon_restarting_title =>
      '[Thé dôwñlôàd šérvîçé štôppéd ûñéxpéçtédlý~~~~~~~~~~~~~]';

  @override
  String get banner_daemon_restarting_message =>
      '[Ît îš réštàrtîñg; ýôûr dôwñlôàdš çôñtîñûé frôm whéré théý wéré.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get banner_daemon_failed_title =>
      '[Thé dôwñlôàd šérvîçé kéépš štôppîñg~~~~~~~~~~~]';

  @override
  String banner_daemon_failed_message(String reason) {
    return '[$reason~~~]';
  }

  @override
  String get banner_daemon_restart => '[Réštàrt šérvîçé~~~~~]';

  @override
  String get banner_dismiss => '[Dîšmîšš~~~]';

  @override
  String get queue_new => '[Ñéw qûéûé~~~]';

  @override
  String get queue_new_title => '[Ñéw qûéûé~~~]';

  @override
  String get queue_name_label => '[Ñàmé~~]';

  @override
  String get queue_name_placeholder => '[Fôr éxàmplé Ñîght dôwñlôàdš~~~~~~~~~]';

  @override
  String get queue_name_taken =>
      '[Â qûéûé wîth thàt ñàmé àlréàdý éxîštš.~~~~~~~~~~~~]';

  @override
  String get queue_create => '[Çréàté~~]';

  @override
  String get queue_rename => '[Réñàmé…~~~]';

  @override
  String get queue_rename_title => '[Réñàmé qûéûé~~~~]';

  @override
  String get queue_save => '[Šàvé~~]';

  @override
  String get queue_delete => '[Délété qûéûé…~~~~]';

  @override
  String queue_delete_title(String name) {
    return '[Délété “$name”?~~~~~]';
  }

  @override
  String get queue_delete_message =>
      '[Îtš dôwñlôàdš môvé tô thé défàûlt qûéûé. Ñôthîñg îš rémôvéd frôm dîšk.~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get queue_delete_confirm => '[Délété qûéûé~~~~]';

  @override
  String get queue_move_up => '[Môvé ûp~~~]';

  @override
  String get queue_move_down => '[Môvé dôwñ~~~]';

  @override
  String get queue_start => '[Štàrt qûéûé~~~~]';

  @override
  String get queue_stop => '[Štôp qûéûé~~~]';

  @override
  String get queue_settings => '[Qûéûé šéttîñgš…~~~~~]';

  @override
  String get queue_menu => '[Qûéûé àçtîôñš~~~~]';

  @override
  String get queue_state_running => '[Rûññîñg~~~]';

  @override
  String get queue_state_stopped => '[Štôppéd~~~]';

  @override
  String get queue_default => '[Défàûlt~~~]';

  @override
  String toast_queue_created(String name) {
    return '[Çréàtéd “$name”~~~~~]';
  }

  @override
  String toast_queue_renamed(String name) {
    return '[Réñàméd tô “$name”~~~~~~]';
  }

  @override
  String toast_queue_deleted(String name) {
    return '[Délétéd “$name”~~~~~]';
  }

  @override
  String toast_queue_started(String name) {
    return '[“$name” štàrtéd~~~~~]';
  }

  @override
  String toast_queue_stopped(String name) {
    return '[“$name” štôppéd~~~~~]';
  }

  @override
  String toast_queue_saved(String name) {
    return '[Šàvéd thé šéttîñgš ôf “$name”~~~~~~~~~]';
  }

  @override
  String qs_title(String name) {
    return '[Šéttîñgš ôf “$name”~~~~~~]';
  }

  @override
  String get qs_intro =>
      '[Âñýthîñg léft émptý fôllôwš thé glôbàl šéttîñgš.~~~~~~~~~~~~~~~]';

  @override
  String get qs_group_speed => '[Špééd~~]';

  @override
  String get qs_speed_limit => '[Špééd lîmît~~~~]';

  @override
  String get qs_speed_limit_desc =>
      '[Pér šéçôñd, fôr thé whôlé qûéûé. Émptý méàñš ñô lîmît ôf îtš ôwñ.~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get qs_speed_placeholder => '[Fôr éxàmplé 2 MB~~~~~]';

  @override
  String get qs_invalid_size => '[Éñtér à šîžé lîké 500K ôr 2 MB.~~~~~~~~~~]';

  @override
  String get qs_group_schedule => '[Šçhédûlé~~~]';

  @override
  String get qs_schedule_on => '[Rûñ ôñlý àt çhôšéñ tîméš~~~~~~~~]';

  @override
  String get qs_schedule_desc =>
      '[Ôûtšîdé théšé hôûrš thé qûéûé wàîtš; dôwñlôàdš réšûmé whéñ thé ñéxt wîñdôw ôpéñš.~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get qs_schedule_grid =>
      '[Wééklý šçhédûlé, ôñé çéll pér hôûr~~~~~~~~~~~]';

  @override
  String get qs_group_profiles => '[Špééd prôfîléš~~~~~]';

  @override
  String get qs_profiles_desc =>
      '[Â prôfîlé lîmîtš thé špééd whîlé îtš hôûrš àré àçtîvé.~~~~~~~~~~~~~~~~~]';

  @override
  String qs_profile_title(int index) {
    return '[Prôfîlé $index~~~~~]';
  }

  @override
  String get qs_profile_add => '[Âdd à prôfîlé~~~~]';

  @override
  String get qs_profile_remove => '[Rémôvé~~]';

  @override
  String get qs_profile_limit => '[Lîmît whîlé àçtîvé~~~~~~]';

  @override
  String get qs_profile_unlimited =>
      '[Émptý méàñš ûñlîmîtéd whîlé àçtîvé.~~~~~~~~~~~]';

  @override
  String get qs_group_quota => '[Qûôtà~~]';

  @override
  String get qs_quota_on => '[Lîmît thé àmôûñt dôwñlôàdéd~~~~~~~~~]';

  @override
  String get qs_quota_desc =>
      '[Whéñ thé qûôtà îš ûšéd ûp thé qûéûé wàîtš fôr thé pérîôd tô rôll ôvér.~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get qs_quota_bytes => '[Âmôûñt~~]';

  @override
  String get qs_quota_period => '[Pér pérîôd~~~]';

  @override
  String get qs_quota_period_placeholder => '[Fôr éxàmplé 1 d~~~~~]';

  @override
  String get qs_invalid_duration =>
      '[Éñtér à tîmé lîké 1h, 1d ôr 90m (àt léàšt à mîñûté).~~~~~~~~~~~~~~~~]';

  @override
  String get qs_group_after => '[Whéñ thé qûéûé fîñîšhéš~~~~~~~]';

  @override
  String get qs_after => '[Théñ~~]';

  @override
  String get qs_after_none => '[Dô ñôthîñg~~~]';

  @override
  String get qs_after_stop => '[Štôp thé qûéûé~~~~~]';

  @override
  String get qs_after_sleep => '[Pût thé çômpûtér tô šléép~~~~~~~~]';

  @override
  String get qs_after_shutdown => '[Šhût thé çômpûtér dôwñ~~~~~~~]';

  @override
  String get qs_after_command => '[Rûñ à prôgràm~~~~]';

  @override
  String get qs_after_delay => '[Wàît fîršt~~~]';

  @override
  String get qs_after_delay_desc =>
      '[Â gràçé pérîôd îñ whîçh ýôû çàñ çàñçél. Émptý méàñš 1 mîñûté.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get qs_after_command_path => '[Prôgràm (fûll pàth)~~~~~~]';

  @override
  String get qs_after_command_args => '[Ârgûméñtš, ôñé pér lîñé~~~~~~~]';

  @override
  String get qs_after_command_warning =>
      '[Thîš prôgràm rûñš wîth ýôûr pérmîššîôñš whéñévér thé qûéûé fîñîšhéš. Ôñlý ûšé ôñé ýôû trûšt.~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get qs_invalid_path =>
      '[Éñtér thé fûll pàth ôf thé prôgràm.~~~~~~~~~~~]';

  @override
  String get qs_cancel => '[Çàñçél~~]';

  @override
  String queue_countdown_title(String name) {
    return '[“$name” hàš fîñîšhéd~~~~~~~]';
  }

  @override
  String queue_countdown_message(String action, String time) {
    return '[$action îñ $time.~~~~~~]';
  }

  @override
  String get queue_countdown_cancel => '[Çàñçél àñd štôp thé qûéûé~~~~~~~~]';

  @override
  String queue_action_cancelled(String name) {
    return '[Thé àçtîôñ àftér “$name” wàš çàñçélléd.~~~~~~~~~~~~]';
  }

  @override
  String get qs_schedule_custom =>
      '[Théšé hôûrš îñçlûdé mîñûtéš, whîçh thé wééklý grîd çàññôt šhôw. Théý àré képt àš théý àré ûñtîl ýôû réplàçé thém.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get qs_schedule_use_grid => '[Ûšé thé hôûrlý grîd~~~~~~]';

  @override
  String get queue_missing_title =>
      '[Thîš qûéûé dôéš ñôt éxîšt àñý môré~~~~~~~~~~~]';

  @override
  String get queue_missing_message =>
      '[Ît wàš délétéd, pérhàpš frôm àñôthér wîñdôw. Pîçk àñôthér ôñé îñ thé šîdébàr.~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get setup_title => '[Wélçômé~~~]';

  @override
  String get setup_intro =>
      '[Â qûîçk lôôk àt whéré ýôûr dôwñlôàdš gô àñd whàt thé dôwñlôàd šérvîçé fôûñd ôñ thîš çômpûtér. Ýôû çàñ çômé bàçk tô thîš frôm thé çômmàñd pàlétté.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get setup_folder_title => '[Dôwñlôàd fôldér~~~~~]';

  @override
  String get setup_folder_desc =>
      '[Ñéw dôwñlôàdš àré šàvéd héré ûñléšš à çàtégôrý ôr qûéûé šàýš ôthérwîšé.~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get setup_folder_choose => '[Çhôôšé…~~~]';

  @override
  String get setup_folder_dialog => '[Çhôôšé thé dôwñlôàd fôldér~~~~~~~~]';

  @override
  String get setup_folder_unset => '[Ñôt çhôšéñ ýét~~~~~]';

  @override
  String setup_folder_saved(String path) {
    return '[Dôwñlôàdš wîll bé šàvéd îñ $path~~~~~~~~~~]';
  }

  @override
  String get setup_tools_title => '[Hélpér prôgràmš~~~~~]';

  @override
  String get setup_tools_desc =>
      '[Théšé àré ûšéd fôr šômé dôwñlôàdš. Â mîššîñg ôñé îš ôñlý à prôblém whéñ à dôwñlôàd ñéédš ît.~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get setup_tools_recheck => '[Çhéçk àgàîñ~~~~]';

  @override
  String get setup_tools_loading => '[Lôôkîñg fôr hélpér prôgràmš…~~~~~~~~~]';

  @override
  String get setup_tool_ffmpeg => '[ffmpég~~]';

  @override
  String get setup_tool_ffmpeg_desc =>
      '[Jôîñš vîdéô àñd àûdîô àñd çôñvértš médîà.~~~~~~~~~~~~~]';

  @override
  String get setup_tool_ytdlp => '[ýt-dlp~~]';

  @override
  String get setup_tool_ytdlp_desc => '[Dôwñlôàdš frôm vîdéô šîtéš.~~~~~~~~~]';

  @override
  String get setup_tool_browser => '[Brôwšér~~~]';

  @override
  String get setup_tool_browser_desc =>
      '[Ôpéñš pàgéš thàt ôñlý wôrk îñ à réàl brôwšér.~~~~~~~~~~~~~~]';

  @override
  String setup_tool_found(String version) {
    return '[Fôûñd · $version~~~~~~]';
  }

  @override
  String get setup_tool_found_noversion => '[Fôûñd~~]';

  @override
  String get setup_tool_missing => '[Ñôt fôûñd~~~]';

  @override
  String get setup_tool_missing_auto =>
      '[Ñôt fôûñd · îñštàlléd àûtômàtîçàllý whéñ ñéédéd~~~~~~~~~~~~~~~]';

  @override
  String setup_tool_error(String error) {
    return '[Prôblém: $error~~~~~]';
  }

  @override
  String get setup_done => '[Dôñé~~]';

  @override
  String get setup_system_title => '[Ôñ thîš çômpûtér~~~~~]';

  @override
  String get setup_system_desc =>
      '[Ôptîôñàl. Âll ôf thîš çàñ bé çhàñgéd làtér îñ Préféréñçéš àñd ûñdér Âççéšš.~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get setup_login => '[Štàrt whéñ Î lôg îñ~~~~~~]';

  @override
  String get setup_login_desc =>
      '[Kéépš dôwñlôàdš gôîñg wîthôût ôpéñîñg thé àpp bý hàñd.~~~~~~~~~~~~~~~~~]';

  @override
  String get setup_ext => '[Brôwšér éxtéñšîôñ~~~~~~]';

  @override
  String get setup_ext_desc =>
      '[Šéñd dôwñlôàdš frôm ýôûr brôwšér tô thîš àpp.~~~~~~~~~~~~~~]';

  @override
  String setup_ext_connected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Šét ûp fôr $count brôwšérš',
      one: 'Šét ûp fôr 1 brôwšér',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get setup_ext_none => '[Ñôt šét ûp~~~]';

  @override
  String get setup_ext_unknown => '[Ñôt àvàîlàblé~~~~]';

  @override
  String get setup_ext_open => '[Šét ûp…~~~]';

  @override
  String get cmd_setup => '[Šétûp àñd héàlth çhéçk…~~~~~~~]';

  @override
  String get insp_label => '[Dôwñlôàd détàîlš~~~~~]';

  @override
  String get insp_tab_overview => '[Ôvérvîéw~~~]';

  @override
  String get insp_tab_files => '[Fîléš~~]';

  @override
  String get insp_tab_speed => '[Špééd~~]';

  @override
  String get insp_tab_source => '[Lîñk~~]';

  @override
  String insp_multi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš šéléçtéd',
      one: '1 dôwñlôàd šéléçtéd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get insp_multi_hint =>
      '[Šéléçt à šîñglé dôwñlôàd tô šéé îtš détàîlš.~~~~~~~~~~~~~~]';

  @override
  String get insp_gone => '[Thîš dôwñlôàd ñô lôñgér éxîštš.~~~~~~~~~~]';

  @override
  String get ov_group_progress => '[Prôgréšš~~~]';

  @override
  String get ov_group_where => '[Whéré ît gôéš~~~~]';

  @override
  String get ov_group_times => '[Tîméš~~]';

  @override
  String get ov_status => '[Štàtûš~~]';

  @override
  String get ov_progress => '[Dôñé~~]';

  @override
  String get ov_size => '[Šîžé~~]';

  @override
  String get ov_size_unknown => '[Ñôt kñôwñ ýét~~~~]';

  @override
  String get ov_downloaded => '[Dôwñlôàdéd~~~]';

  @override
  String get ov_speed => '[Špééd~~]';

  @override
  String get ov_time_left => '[Tîmé léft~~~]';

  @override
  String get ov_connections => '[Çôññéçtîôñš~~~~]';

  @override
  String get ov_queue => '[Qûéûé~~]';

  @override
  String get ov_engine => '[Éñgîñé~~]';

  @override
  String get ov_folder => '[Fôldér~~]';

  @override
  String get ov_priority => '[Prîôrîtý~~~]';

  @override
  String get ov_labels => '[Làbélš~~]';

  @override
  String get ov_added => '[Âddéd~~]';

  @override
  String get ov_started => '[Štàrtéd~~~]';

  @override
  String get ov_completed => '[Fîñîšhéd~~~]';

  @override
  String get ov_none => '[—~]';

  @override
  String get ov_priority_low => '[Lôw~]';

  @override
  String get ov_priority_normal => '[Ñôrmàl~~]';

  @override
  String get ov_priority_high => '[Hîgh~~]';

  @override
  String get ov_error_title => '[Ît štôppéd wîth àñ érrôr~~~~~~~~]';

  @override
  String ov_error_detail(String message, String code) {
    return '[$message ($code)~~~~~~]';
  }

  @override
  String ov_error_when(String when) {
    return '[$when~~]';
  }

  @override
  String get ov_error_retryable => '[Trýîñg àgàîñ màý wôrk.~~~~~~~]';

  @override
  String get ov_error_final =>
      '[Trýîñg àgàîñ wîll ñôt hélp ûñtîl šôméthîñg çhàñgéš.~~~~~~~~~~~~~~~~]';

  @override
  String get files_tree_label => '[Fîléš ôf thîš dôwñlôàd~~~~~~~]';

  @override
  String get files_single => '[Thîš dôwñlôàd îš à šîñglé fîlé.~~~~~~~~~~]';

  @override
  String files_count(int selected, int total) {
    return '[$selected ôf $total fîléš šéléçtéd~~~~~~~~~~~]';
  }

  @override
  String get files_none_selected =>
      '[Ñô fîléš àré šéléçtéd fôr dôwñlôàd.~~~~~~~~~~~]';

  @override
  String get speed_title => '[Dôwñlôàd špééd~~~~~]';

  @override
  String speed_summary(String current, String peak, int seconds) {
    return '[Ñôw $current, hîghéšt $peak ôvér thé làšt $seconds šéçôñdš.~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get speed_waiting =>
      '[Thé gràph fîllš îñ whîlé thé dôwñlôàd rûñš.~~~~~~~~~~~~~]';

  @override
  String get speed_series => '[Špééd~~]';

  @override
  String get src_group_link => '[Lîñk~~]';

  @override
  String get src_group_history => '[Lîñk réñéwàlš~~~~]';

  @override
  String get src_current => '[Çûrréñt lîñk~~~~]';

  @override
  String get src_original => '[Fîršt lîñk~~~]';

  @override
  String get src_page => '[Pàgé~~]';

  @override
  String get src_referrer => '[Référrér~~~]';

  @override
  String get src_mirrors => '[Mîrrôrš~~~]';

  @override
  String get src_copy => '[Çôpý~~]';

  @override
  String get src_refresh => '[Réñéw lîñk ñôw~~~~~]';

  @override
  String get src_await => '[Wàît fôr à ñéw lîñk~~~~~~]';

  @override
  String get src_edit => '[Réplàçé lîñk…~~~~]';

  @override
  String get src_edit_title => '[Réplàçé thé lîñk~~~~~]';

  @override
  String get src_edit_label => '[Ñéw lîñk~~~]';

  @override
  String get src_edit_hint =>
      '[Thé dàémôñ çhéçkš ît àgàîñšt thé fîlé. Îf ît îš ñôt thé šàmé fîlé, thé dôwñlôàd štàrtš àgàîñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get src_edit_needs_pause =>
      '[Pàûšé thé dôwñlôàd fîršt tô réplàçé îtš lîñk.~~~~~~~~~~~~~~]';

  @override
  String get src_edit_save => '[Réplàçé~~~]';

  @override
  String get src_history_empty =>
      '[Thé lîñk hàš ñôt ñéédéd réñéwîñg.~~~~~~~~~~]';

  @override
  String src_attempt(String strategy, String outcome) {
    return '[$strategy · $outcome~~~~~~~]';
  }

  @override
  String src_attempt_cause(String cause) {
    return '[Çàûšé: $cause~~~~~]';
  }

  @override
  String get toast_link_refreshing => '[Âškîñg fôr à ñéw lîñk~~~~~~~]';

  @override
  String get toast_link_waiting => '[Wàîtîñg fôr à ñéw lîñk~~~~~~~]';

  @override
  String get toast_link_replaced => '[Lîñk réplàçéd~~~~]';

  @override
  String get files_skipped => '[ñôt dôwñlôàdéd~~~~~]';

  @override
  String get insp_tab_segments => '[Šégméñtš~~~]';

  @override
  String get insp_tab_torrent => '[Tôrréñt~~~]';

  @override
  String get seg_none =>
      '[Thîš dôwñlôàd îš ñôt šplît îñtô šégméñtš.~~~~~~~~~~~~~]';

  @override
  String seg_summary(int count, int percent) {
    return '[$count šégméñtš, $percent% dôñé.~~~~~~~~~~~]';
  }

  @override
  String get seg_label => '[Màp ôf thé šégméñtš ôf thé dôwñlôàd~~~~~~~~~~~]';

  @override
  String get seg_done => '[dôwñlôàdéd~~~]';

  @override
  String get seg_todo => '[štîll tô dô~~~~]';

  @override
  String get torrent_none =>
      '[Théré îš ñô šwàrm tô šhôw ýét: thé tôrréñt hàš ñôt štàrtéd.~~~~~~~~~~~~~~~~~~]';

  @override
  String get torrent_state => '[Štàté~~]';

  @override
  String get torrent_hash => '[Îñfô hàšh~~~]';

  @override
  String get torrent_private => '[Prîvàté tôrréñt~~~~~]';

  @override
  String get torrent_yes => '[ýéš~]';

  @override
  String get torrent_no => '[ñô~]';

  @override
  String get torrent_peers => '[Péérš~~]';

  @override
  String torrent_peers_value(int connected, int known, int seeders) {
    return '[$connected çôññéçtéd, $known kñôwñ, $seeders šéédérš~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get torrent_shared => '[Šhàréd~~]';

  @override
  String torrent_shared_value(String uploaded, String ratio) {
    return '[$uploaded ûplôàdéd, ràtîô $ratio~~~~~~~~~~~]';
  }

  @override
  String get torrent_seeding_time => '[Šéédîñg fôr~~~~]';

  @override
  String get torrent_trackers => '[Tràçkérš~~~]';

  @override
  String get torrent_peer_list => '[Çôññéçtéd péérš~~~~~]';

  @override
  String torrent_peer_rate(String rate) {
    return '[$rate dôwñ~~~~]';
  }

  @override
  String get files_edit => '[Çhôôšé fîléš~~~~]';

  @override
  String get files_save => '[Šàvé šéléçtîôñ~~~~~]';

  @override
  String get files_cancel => '[Çàñçél~~]';

  @override
  String get files_locked =>
      '[Pàûšé thé dôwñlôàd tô çhàñgé whîçh fîléš àré dôwñlôàdéd.~~~~~~~~~~~~~~~~~]';

  @override
  String get files_select_all => '[Âll fîléš~~~]';

  @override
  String get files_pick_one => '[Šéléçt àt léàšt ôñé fîlé.~~~~~~~~]';

  @override
  String get toast_files_saved => '[Šéléçtîôñ šàvéd~~~~~]';

  @override
  String files_file_label(String name) {
    return '[Dôwñlôàd $name~~~~~]';
  }

  @override
  String get add_title => '[Âdd dôwñlôàdš~~~~]';

  @override
  String get add_button => '[Âdd~]';

  @override
  String get add_links => '[Lîñkš~~]';

  @override
  String get add_links_placeholder =>
      '[Ôñé lîñk pér lîñé: wéb àddréššéš, màgñét lîñkš, ôr à pàttérñ lîké http://hôšt/îmg[1-20].jpg~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get add_looking => '[Lôôkîñg àt thé lîñk…~~~~~~]';

  @override
  String add_files(int count) {
    return '[$count fîléš~~~~]';
  }

  @override
  String add_many(int count) {
    return '[$count dôwñlôàdš~~~~~~]';
  }

  @override
  String get add_more => '[àñd môré…~~~]';

  @override
  String add_duplicate(String name) {
    return '[Âlréàdý îñ thé lîšt: $name~~~~~~~~~]';
  }

  @override
  String get add_anyway => '[Âdd ît àñýwàý~~~~]';

  @override
  String get add_queue => '[Qûéûé~~]';

  @override
  String get add_folder => '[Fôldér~~]';

  @override
  String get add_folder_default => '[Thé défàûlt dôwñlôàd fôldér~~~~~~~~~]';

  @override
  String get add_name => '[Ñàmé~~]';

  @override
  String get add_name_placeholder => '[Tàkéñ frôm thé lîñk~~~~~~]';

  @override
  String get add_paused => '[Âdd wîthôût štàrtîñg~~~~~~]';

  @override
  String add_done_one(String name) {
    return '[Âddéd $name~~~~]';
  }

  @override
  String add_done_many(int count) {
    return '[Âddéd $count dôwñlôàdš~~~~~~~]';
  }

  @override
  String get cmd_add => '[Âdd dôwñlôàdš…~~~~~]';

  @override
  String get toolbar_add => '[Âdd dôwñlôàdš~~~~]';

  @override
  String get view_menu => '[Vîéw~~]';

  @override
  String get view_engine => '[Éñgîñé~~]';

  @override
  String get view_all_engines => '[Âll éñgîñéš~~~~]';

  @override
  String get view_sort => '[Šôrt bý~~~]';

  @override
  String get view_sort_default => '[Défàûlt ôrdér~~~~]';

  @override
  String get view_sort_added => '[Dàté àddéd~~~]';

  @override
  String get view_sort_name => '[Ñàmé~~]';

  @override
  String get view_sort_size => '[Šîžé~~]';

  @override
  String get view_sort_completed => '[Dàté çômplétéd~~~~~]';

  @override
  String get view_sort_asc => '[Âšçéñdîñg~~~]';

  @override
  String get view_sort_desc => '[Déšçéñdîñg~~~]';

  @override
  String get view_group => '[Grôûp bý~~~]';

  @override
  String get view_group_none => '[Ñô grôûpîñg~~~~]';

  @override
  String get view_group_status => '[Štàtûš~~]';

  @override
  String get view_group_queue => '[Qûéûé~~]';

  @override
  String get view_group_engine => '[Éñgîñé~~]';

  @override
  String group_header(String name, int count) {
    return '[$name ($count)~~~~~]';
  }

  @override
  String get view_saved => '[Šàvéd vîéwš~~~~]';

  @override
  String get view_save => '[Šàvé çûrréñt vîéw…~~~~~~]';

  @override
  String get view_save_title => '[Šàvé thîš vîéw~~~~~]';

  @override
  String view_delete(String name) {
    return '[Délété vîéw $name~~~~~~]';
  }

  @override
  String get col_engine => '[Éñgîñé~~]';

  @override
  String get col_category => '[Çàtégôrý~~~]';

  @override
  String list_total(int count) {
    return '[$count dôwñlôàdš~~~~~~]';
  }

  @override
  String get action_refresh_link => '[Gét à ñéw lîñk~~~~~]';

  @override
  String get action_move_to => '[Môvé tô qûéûé~~~~]';

  @override
  String get action_priority => '[Prîôrîtý~~~]';

  @override
  String get priority_high => '[Hîgh~~]';

  @override
  String get priority_normal => '[Ñôrmàl~~]';

  @override
  String get priority_low => '[Lôw~]';

  @override
  String toast_moved(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Môvéd $count dôwñlôàdš tô $queue',
      one: 'Môvéd 1 dôwñlôàd tô $queue',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String toast_prioritised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prîôrîtý çhàñgéd fôr $count dôwñlôàdš',
      one: 'Prîôrîtý çhàñgéd fôr 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String toast_restarted_many(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Réštàrtîñg $count dôwñlôàdš',
      one: 'Réštàrtîñg 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String toast_refreshing_many(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Âškîñg fôr ñéw lîñkš fôr $count dôwñlôàdš',
      one: 'Âškîñg fôr à ñéw lîñk fôr 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get status_label => '[Štàtûš bàr~~~]';

  @override
  String get status_reconnecting => '[Réçôññéçtîñg…~~~~]';

  @override
  String status_speed(String down, String up) {
    return '[↓ $down  ↑ $up~~~~~]';
  }

  @override
  String status_counts(int active, int queued) {
    return '[$active àçtîvé, $queued wàîtîñg~~~~~~~~~~]';
  }

  @override
  String status_quota(String used, String total) {
    return '[$used ôf $total~~~~~~]';
  }

  @override
  String get status_quota_label => '[Qûôtà ûšéd~~~]';

  @override
  String get status_turbo => '[Tûrbô~~]';

  @override
  String get status_turbo_on => '[Tûrbô ôñ~~~]';

  @override
  String get status_pause_all => '[Pàûšé àll~~~]';

  @override
  String get status_resume_all => '[Réšûmé àll~~~]';

  @override
  String get add_import => '[Împôrt lîšt…~~~~]';

  @override
  String add_import_title(String name) {
    return '[Împôrt $name~~~~]';
  }

  @override
  String add_import_go(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Âdd $count dôwñlôàdš',
      one: 'Âdd 1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get add_results_title => '[Whàt hàppéñéd~~~~]';

  @override
  String add_results_summary(int ok, int failed) {
    return '[$ok àddéd, $failed ñôt àddéd.~~~~~~~~~~]';
  }

  @override
  String get add_result_ok => '[Âddéd~~]';

  @override
  String get add_result_failed => '[Ñôt àddéd~~~]';

  @override
  String get add_result_duplicate => '[Âlréàdý îñ thé lîšt~~~~~~]';

  @override
  String get add_close => '[Çlôšé~~]';

  @override
  String get add_folder_browse => '[Brôwšé fôldérš~~~~~]';

  @override
  String get folder_browser_title => '[Çhôôšé à fôldér~~~~~]';

  @override
  String get folder_browser_roots => '[Plàçéš ýôû çàñ çhôôšé frôm~~~~~~~~]';

  @override
  String get folder_browser_empty => '[Ñô fôldérš héré.~~~~~]';

  @override
  String get folder_browser_choose => '[Çhôôšé thîš fôldér~~~~~~]';

  @override
  String get folder_browser_error =>
      '[Thé fôldérš çôûld ñôt bé lîštéd.~~~~~~~~~~]';

  @override
  String get add_advanced => '[Môré ôptîôñš~~~~]';

  @override
  String get add_mode => '[Tréàt thé lîñk àš~~~~~~]';

  @override
  String get add_mode_auto => '[Lét thé àpp déçîdé~~~~~~]';

  @override
  String get add_mode_direct => '[Â fîlé~~]';

  @override
  String get add_mode_ytdlp => '[Â vîdéô ôr àûdîô pàgé (ýt-dlp)~~~~~~~~~]';

  @override
  String get add_mode_browser => '[Â pàgé thàt ñéédš à brôwšér~~~~~~~~~]';

  @override
  String get add_referrer => '[Référrér~~~]';

  @override
  String get add_headers => '[Héàdérš~~~]';

  @override
  String get add_headers_hint => '[Ôñé pér lîñé, lîké Ñàmé: vàlûé~~~~~~~~~]';

  @override
  String get add_headers_invalid =>
      '[Évérý lîñé ñéédš à ñàmé, à çôlôñ àñd à vàlûé.~~~~~~~~~~~~~~]';

  @override
  String get add_mirrors => '[Mîrrôrš~~~]';

  @override
  String get add_mirrors_hint =>
      '[Ôthér plàçéš wîth thé šàmé fîlé, ôñé lîñk pér lîñé~~~~~~~~~~~~~~~]';

  @override
  String get add_checksum => '[Çhéçkšûm~~~]';

  @override
  String get add_checksum_algorithm => '[Çhéçkšûm àlgôrîthm~~~~~~]';

  @override
  String get add_checksum_placeholder => '[Éxpéçtéd vàlûé îñ héx~~~~~~~]';

  @override
  String get add_checksum_invalid =>
      '[Ñôt à vàlîd vàlûé fôr thîš àlgôrîthm.~~~~~~~~~~~~]';

  @override
  String get add_torrent => '[Tôrréñt fîlé…~~~~]';

  @override
  String get add_torrent_too_big =>
      '[Thàt tôrréñt fîlé îš tôô làrgé (16 MîB àt môšt).~~~~~~~~~~~~~~~]';

  @override
  String get add_torrent_unreadable =>
      '[Thàt tôrréñt fîlé çôûld ñôt bé réàd.~~~~~~~~~~~]';

  @override
  String add_torrent_remove(String name) {
    return '[Rémôvé $name~~~~]';
  }

  @override
  String get nav_categories => '[Çàtégôrîéš~~~]';

  @override
  String drag_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš',
      one: '1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get view_density => '[Rôw héîght~~~]';

  @override
  String get view_density_comfortable => '[Çômfôrtàblé~~~~]';

  @override
  String get view_density_compact => '[Çômpàçt~~~]';

  @override
  String get view_columns => '[Çôlûmñš~~~]';

  @override
  String get display_menu => '[Dîšplàý~~~]';

  @override
  String get settings_search => '[Šéàrçh šéttîñgš~~~~~]';

  @override
  String get settings_save => '[Šàvé~~]';

  @override
  String get settings_revert => '[Révért~~]';

  @override
  String get settings_saved => '[Šéttîñgš šàvéd~~~~~]';

  @override
  String get settings_unsaved => '[Ûñšàvéd çhàñgéš~~~~~]';

  @override
  String get settings_no_match => '[Ñô šéttîñg màtçhéš ýôûr šéàrçh.~~~~~~~~~~]';

  @override
  String get settings_changed_elsewhere =>
      '[Thé šéttîñgš wéré çhàñgéd šôméwhéré élšé. Théîr véršîôñ îš šhôwñ ñôw; màké ýôûr çhàñgéš àgàîñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get settings_level_default => '[Défàûlt~~~]';

  @override
  String get settings_level_global => '[Glôbàl~~]';

  @override
  String get settings_level_queue => '[Qûéûé~~]';

  @override
  String get settings_level_task => '[Thîš dôwñlôàd~~~~]';

  @override
  String get settings_restart => '[Ñéédš réštàrt~~~~]';

  @override
  String get settings_unset => '[Ñôt šét~~~]';

  @override
  String settings_reset(String name) {
    return '[Réšét $name tô thé îñhérîtéd vàlûé~~~~~~~~~~~]';
  }

  @override
  String get settings_invalid_size =>
      '[Ñôt à šîžé, šûçh àš 10 MB ôr 512 K.~~~~~~~~~~~]';

  @override
  String get settings_invalid_number =>
      '[Ñôt à ñûmbér îñ thé àllôwéd ràñgé.~~~~~~~~~~~]';

  @override
  String get settings_invalid_duration =>
      '[Ûšé à dûràtîôñ lîké 30š, 5m ôr 1h30m.~~~~~~~~~~~~]';

  @override
  String get settings_leave_title => '[Léàvé wîthôût šàvîñg?~~~~~~~]';

  @override
  String get settings_leave_message =>
      '[Ýôû çhàñgéd šéttîñgš thàt àré ñôt šàvéd ýét.~~~~~~~~~~~~~~]';

  @override
  String get settings_leave_confirm => '[Léàvé~~]';

  @override
  String get settings_leave_stay => '[Kéép édîtîñg~~~~]';

  @override
  String get nav_settings => '[Šéttîñgš~~~]';

  @override
  String get insp_tab_settings => '[Šéttîñgš~~~]';

  @override
  String get se_name => '[Ñàmé~~]';

  @override
  String get se_value => '[Vàlûé~~]';

  @override
  String get se_remove => '[Rémôvé~~]';

  @override
  String get se_add => '[Âdd~]';

  @override
  String get se_add_rule => '[Âdd à rûlé~~~]';

  @override
  String get se_proxy_mode => '[Prôxý~~]';

  @override
  String get se_proxy_none => '[Ñô prôxý~~~]';

  @override
  String get se_proxy_system => '[Thé šýštém\'š prôxý~~~~~~]';

  @override
  String get se_proxy_custom => '[Â prôxý Î çhôôšé~~~~~]';

  @override
  String get se_proxy_url => '[Prôxý àddréšš~~~~]';

  @override
  String get se_rule_hosts => '[Hôštš~~]';

  @override
  String get se_rule_hosts_hint => '[éxàmplé.çôm, *.çdñ.ñét~~~~~~~]';

  @override
  String get se_lines => '[Ôñé éñtrý pér lîñé~~~~~~]';

  @override
  String get se_move_up => '[Môvé ûp~~~]';

  @override
  String get se_move_down => '[Môvé dôwñ~~~]';

  @override
  String get se_pa_add => '[Âdd àñ àçtîôñ~~~~]';

  @override
  String get se_pa_extract => '[Ûñpàçk àrçhîvéš~~~~~]';

  @override
  String get se_pa_add_torrent => '[Âdd à dôwñlôàdéd .tôrréñt fîlé~~~~~~~~~]';

  @override
  String get se_pa_command => '[Rûñ à prôgràm~~~~]';

  @override
  String get se_pa_av_scan => '[Šçàñ fôr vîrûšéš~~~~~]';

  @override
  String get se_pa_dir => '[Fôldér~~]';

  @override
  String get se_pa_dir_hint => '[Ñéxt tô thé fîlé~~~~~]';

  @override
  String get se_pa_delete => '[Délété thé fîlé àftérwàrdš~~~~~~~~]';

  @override
  String get se_pa_password => '[Pàššwôrd~~~]';

  @override
  String get se_pa_cmd => '[Prôgràm~~~]';

  @override
  String get se_pa_cmd_hint => '[Fûll pàth, é.g. /ûšr/bîñ/çlàmšçàñ~~~~~~~~~~]';

  @override
  String get se_pa_args => '[Ârgûméñtš~~~]';

  @override
  String se_pa_args_hint(String token) {
    return '[Ôñé pér lîñé; $token îš thé fîlé~~~~~~~~~~]';
  }

  @override
  String get se_pa_timeout => '[Tîmé lîmît~~~]';

  @override
  String get se_pa_infected_exit => '[Îñféçtéd éxît çôdé~~~~~~]';

  @override
  String get se_pa_on_infected => '[Whéñ îñféçtéd~~~~]';

  @override
  String get se_pa_infected_delete => '[Délété thé fîlé~~~~~]';

  @override
  String get se_pa_infected_keep => '[Kéép thé fîlé~~~~]';

  @override
  String get se_pa_command_warning =>
      '[Thîš rûñš à prôgràm ôñ évérý fîñîšhéd dôwñlôàd. Ôñlý ûšé à prôgràm ýôû trûšt.~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get se_pa_av_warning =>
      '[Âñ îñféçtéd fîlé fàîlš thé dôwñlôàd àñd, ûñléšš ýôû kéép ît, îš délétéd. Ôñlý ûšé à šçàññér ýôû trûšt.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get se_quota_bytes => '[Âmôûñt~~]';

  @override
  String get se_quota_per => '[pér~]';

  @override
  String get se_quota_period => '[Pérîôd~~]';

  @override
  String get nav_manage => '[Màñàgé~~]';

  @override
  String get nav_manage_categories => '[Çàtégôrîéš~~~]';

  @override
  String get cat_intro =>
      '[Â çàtégôrý šôrtš à fîñîšhéd dôwñlôàd îñtô à fôldér bý îtš fîlé éxtéñšîôñ ôr çôñtéñt týpé. Thé fîršt çàtégôrý thàt màtçhéš wîñš, šô thé ôrdér màttérš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get cat_add => '[Âdd à çàtégôrý~~~~~]';

  @override
  String get cat_add_title => '[Âdd à çàtégôrý~~~~~]';

  @override
  String get cat_edit_title => '[Édît thé çàtégôrý~~~~~~]';

  @override
  String get cat_saved => '[Çàtégôrý šàvéd~~~~~]';

  @override
  String get cat_empty_title => '[Ñô çàtégôrîéš ýét~~~~~~]';

  @override
  String get cat_empty_message =>
      '[Âdd ôñé tô hàvé fîñîšhéd dôwñlôàdš šôrtéd îñtô fôldérš.~~~~~~~~~~~~~~~~~]';

  @override
  String get cat_name => '[Ñàmé~~]';

  @override
  String get cat_folder => '[Fôldér~~]';

  @override
  String get cat_folder_desc =>
      '[Whéré fîléš ôf thîš çàtégôrý àré pût.~~~~~~~~~~~~]';

  @override
  String get cat_extensions => '[Éxtéñšîôñš~~~]';

  @override
  String get cat_extensions_desc =>
      '[Šépàràtéd bý çômmàš ôr špàçéš, lîké mkv, mp4.~~~~~~~~~~~~~~]';

  @override
  String get cat_extensions_invalid =>
      '[Éxtéñšîôñš àré léttérš àñd dîgîtš ôñlý.~~~~~~~~~~~~]';

  @override
  String get cat_mime => '[Çôñtéñt týpéš~~~~]';

  @override
  String get cat_mime_desc =>
      '[Ôñé pér lîñé, lîké vîdéô/* ôr àpplîçàtîôñ/pdf.~~~~~~~~~~~~~~]';

  @override
  String get cat_mime_invalid =>
      '[Ûšé thé fôrm týpé/šûbtýpé, ôr týpé/*.~~~~~~~~~~~~]';

  @override
  String cat_drag(String name) {
    return '[Dràg $name tô çhàñgé îtš ôrdér~~~~~~~~~~]';
  }

  @override
  String cat_move_up(String name) {
    return '[Môvé $name ûp~~~~~]';
  }

  @override
  String cat_move_down(String name) {
    return '[Môvé $name dôwñ~~~~~]';
  }

  @override
  String cat_edit(String name) {
    return '[Édît $name~~~~]';
  }

  @override
  String cat_delete(String name) {
    return '[Délété $name~~~~]';
  }

  @override
  String cat_delete_title(String name) {
    return '[Délété thé çàtégôrý $name?~~~~~~~~~]';
  }

  @override
  String get cat_delete_message =>
      '[Fîléš àlréàdý šôrtéd bý ît štàý whéré théý àré.~~~~~~~~~~~~~~~]';

  @override
  String get cat_delete_confirm => '[Délété çàtégôrý~~~~~]';

  @override
  String get cat_test_title => '[Trý à fîlé~~~]';

  @override
  String get cat_test_name => '[Fîlé ñàmé~~~]';

  @override
  String get cat_test_mime => '[Çôñtéñt týpé~~~~]';

  @override
  String get cat_test_none =>
      '[Ñô çàtégôrý màtçhéš: thé fîlé štàýš îñ thé ñôrmàl dôwñlôàd fôldér.~~~~~~~~~~~~~~~~~~~~]';

  @override
  String cat_test_found(String name, String dir) {
    return '[Gôéš tô $name: $dir~~~~~~~]';
  }

  @override
  String get cat_test_error => '[Thé dàémôñ çôûld ñôt bé àškéd.~~~~~~~~~]';

  @override
  String get nav_manage_logins => '[Lôgîñš~~]';

  @override
  String get nav_manage_cookies => '[Çôôkîéš~~~]';

  @override
  String get field_show => '[Šhôw~~]';

  @override
  String get field_hide => '[Hîdé~~]';

  @override
  String get login_intro =>
      '[Lôgîñš àré šéñt tô šîtéš thàt àšk fôr à ûšér ñàmé àñd pàššwôrd. Thé pàššwôrd štàýš îñ thé dôwñlôàd šérvîçé: ît îš ñévér šhôwñ héré àgàîñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get login_add => '[Âdd à lôgîñ~~~~]';

  @override
  String get login_add_title => '[Âdd à lôgîñ~~~~]';

  @override
  String get login_edit_title => '[Édît thé lôgîñ~~~~~]';

  @override
  String get login_saved => '[Lôgîñ šàvéd~~~~]';

  @override
  String get login_empty_title => '[Ñô lôgîñš ýét~~~~]';

  @override
  String get login_empty_message =>
      '[Âdd ôñé fôr à šîté thàt ñéédš à ûšér ñàmé àñd pàššwôrd.~~~~~~~~~~~~~~~~~]';

  @override
  String get login_host => '[Šîté~~]';

  @override
  String get login_host_desc =>
      '[Â hôšt ñàmé lîké éxàmplé.çôm, ôr *.éxàmplé.çôm fôr àll îtš šûbdômàîñš.~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get login_user => '[Ûšér ñàmé~~~]';

  @override
  String get login_password => '[Pàššwôrd~~~]';

  @override
  String get login_password_keep =>
      '[Léàvé émptý tô kéép thé štôréd pàššwôrd.~~~~~~~~~~~~]';

  @override
  String get login_scheme => '[Méthôd~~]';

  @override
  String get login_scheme_auto => '[Lét thé šîté déçîdé~~~~~~]';

  @override
  String get login_scheme_basic => '[Bàšîç~~]';

  @override
  String get login_scheme_digest => '[Dîgéšt~~]';

  @override
  String login_updated(String date) {
    return '[çhàñgéd $date~~~~~]';
  }

  @override
  String login_edit(String host) {
    return '[Édît thé lôgîñ fôr $host~~~~~~~~]';
  }

  @override
  String login_delete(String host) {
    return '[Délété thé lôgîñ fôr $host~~~~~~~~~]';
  }

  @override
  String login_delete_title(String host) {
    return '[Délété thé lôgîñ fôr $host?~~~~~~~~~]';
  }

  @override
  String get login_delete_message =>
      '[Dôwñlôàdš frôm thàt šîté wîll ñô lôñgér šîgñ îñ.~~~~~~~~~~~~~~~]';

  @override
  String get login_delete_confirm => '[Délété lôgîñ~~~~]';

  @override
  String get ck_intro =>
      '[Çôôkîéš kéép ýôû šîgñéd îñ tô šîtéš. Théîr vàlûéš štàý îñ thé dôwñlôàd šérvîçé; àñ éxpôrt îš thé ôñlý wàý tô šéé thém.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ck_import => '[Împôrt çôôkîéš…~~~~~]';

  @override
  String get ck_export => '[Éxpôrt àll…~~~~]';

  @override
  String get ck_empty_title => '[Ñô çôôkîéš štôréd~~~~~~]';

  @override
  String get ck_empty_message =>
      '[Împôrt à çôôkîéš fîlé, ôr lét thé brôwšér éxtéñšîôñ šéñd thém.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ck_tree_label => '[Çôôkîéš bý dômàîñ~~~~~~]';

  @override
  String ck_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çôôkîéš',
      one: '1 çôôkîé',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~]';
  }

  @override
  String get ck_secure => '[Šéçûré~~]';

  @override
  String get ck_http_only => '[HTTP ôñlý~~~]';

  @override
  String get ck_session => '[Šéššîôñ~~~]';

  @override
  String ck_export_domain(String domain) {
    return '[Éxpôrt thé çôôkîéš ôf $domain~~~~~~~~~]';
  }

  @override
  String ck_delete_domain(String domain) {
    return '[Délété thé çôôkîéš ôf $domain~~~~~~~~~]';
  }

  @override
  String ck_delete_cookie(String name) {
    return '[Délété thé çôôkîé $name~~~~~~~~]';
  }

  @override
  String ck_delete_domain_title(String domain) {
    return '[Délété thé çôôkîéš ôf $domain?~~~~~~~~~~]';
  }

  @override
  String ck_delete_domain_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çôôkîéš wîll bé délétéd.',
      one: '1 çôôkîé wîll bé délétéd.',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get ck_delete_confirm => '[Délété çôôkîéš~~~~~]';

  @override
  String ck_import_title(String name) {
    return '[Împôrt $name~~~~]';
  }

  @override
  String ck_import_summary(int imported, int skipped) {
    return '[$imported împôrtéd, $skipped škîppéd.~~~~~~~~~~~~]';
  }

  @override
  String get ck_export_title => '[Éxpôrt çôôkîéš~~~~~]';

  @override
  String get ck_export_all => '[Âll štôréd çôôkîéš.~~~~~~]';

  @override
  String ck_export_one(String domain) {
    return '[Thé çôôkîéš ôf $domain.~~~~~~~~]';
  }

  @override
  String get ck_format => '[Fîlé týpé~~~]';

  @override
  String get ck_format_netscape => '[Ñétšçàpé çôôkîéš.txt~~~~~~]';

  @override
  String get ck_format_json => '[JŠÔÑ~~]';

  @override
  String get ck_export_warning =>
      '[Thé éxpôrt çôñtàîñš thé çôôkîé vàlûéš. Âñýôñé whô hàš thém çàñ šîgñ îñ àš ýôû. Révéàl thém ôñlý whéré ýôû çàñ kéép thém šàfé.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ck_reveal => '[Révéàl thé çôôkîéš~~~~~~]';

  @override
  String ck_export_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çôôkîéš',
      one: '1 çôôkîé',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~]';
  }

  @override
  String get ck_export_text => '[Thé éxpôrtéd çôôkîéš~~~~~~]';

  @override
  String get ck_copy => '[Çôpý~~]';

  @override
  String get ck_copied => '[Çôpîéd~~]';

  @override
  String get ck_save => '[Šàvé tô à fîlé…~~~~~]';

  @override
  String get ck_saved => '[Fîlé šàvéd~~~]';

  @override
  String get nav_manage_webhooks => '[Wébhôôkš~~~]';

  @override
  String get wh_intro =>
      '[Â wébhôôk îš àñ àddréšš thàt îš šéñt thé dàémôñ\'š évéñtš àš théý hàppéñ, fôr éxàmplé whéñ à dôwñlôàd fîñîšhéš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get wh_add => '[Âdd à wébhôôk~~~~]';

  @override
  String get wh_add_title => '[Âdd à wébhôôk~~~~]';

  @override
  String get wh_edit_title => '[Édît thé wébhôôk~~~~~]';

  @override
  String get wh_saved => '[Wébhôôk šàvéd~~~~]';

  @override
  String get wh_empty_title => '[Ñô wébhôôkš ýét~~~~~]';

  @override
  String get wh_empty_message =>
      '[Âdd ôñé tô hàvé évéñtš šéñt tô àñôthér prôgràm.~~~~~~~~~~~~~~~]';

  @override
  String get wh_url => '[Âddréšš~~~]';

  @override
  String get wh_url_invalid =>
      '[Ûšé àñ àddréšš thàt štàrtš wîth http:// ôr httpš://.~~~~~~~~~~~~~~~~]';

  @override
  String get wh_secret => '[Šéçrét~~]';

  @override
  String get wh_secret_desc =>
      '[Délîvérîéš àré šîgñéd wîth ît, šô thé réçéîvér çàñ çhéçk whéré théý çàmé frôm. Ôptîôñàl.~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get wh_secret_keep =>
      '[Léàvé émptý tô kéép thé štôréd šéçrét.~~~~~~~~~~~~]';

  @override
  String get wh_secret_remove => '[Rémôvé thé šéçrét~~~~~~]';

  @override
  String get wh_enabled_label => '[Šéñd délîvérîéš~~~~~]';

  @override
  String wh_enabled(String url) {
    return '[Šéñd délîvérîéš tô $url~~~~~~~~]';
  }

  @override
  String get wh_events => '[Évéñtš~~]';

  @override
  String get wh_events_desc =>
      '[Léàvé àll ûñtîçkéd tô réçéîvé évérý évéñt.~~~~~~~~~~~~~]';

  @override
  String get wh_all_events => '[Âll évéñtš~~~]';

  @override
  String wh_events_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count évéñtš',
      one: '1 évéñt',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~]';
  }

  @override
  String get wh_signed => '[Šîgñéd~~]';

  @override
  String get wh_test => '[Téšt~~]';

  @override
  String wh_test_ok(String url) {
    return '[$url àççéptéd thé téšt évéñt.~~~~~~~~~]';
  }

  @override
  String wh_test_failed(String url) {
    return '[$url dîd ñôt àççépt thé téšt évéñt.~~~~~~~~~~~]';
  }

  @override
  String get wh_log => '[Délîvérîéš~~~]';

  @override
  String wh_log_title(String url) {
    return '[Délîvérîéš tô $url~~~~~~]';
  }

  @override
  String get wh_log_desc =>
      '[Thé làšt àttémptš šîñçé thé dàémôñ štàrtéd, ñéwéšt fîršt.~~~~~~~~~~~~~~~~~~]';

  @override
  String get wh_log_empty => '[Ñôthîñg wàš šéñt ýét.~~~~~~~]';

  @override
  String get wh_log_error => '[Thé délîvérîéš çôûld ñôt bé réàd.~~~~~~~~~~]';

  @override
  String get wh_log_refresh => '[Réfréšh~~~]';

  @override
  String get wh_log_no_answer => '[ñô àñšwér~~~]';

  @override
  String wh_log_status(int status) {
    return '[HTTP $status~~~~]';
  }

  @override
  String wh_log_attempt(int n) {
    return '[àttémpt $n~~~~]';
  }

  @override
  String get wh_log_retry => '[wîll rétrý~~~]';

  @override
  String wh_edit(String url) {
    return '[Édît $url~~~]';
  }

  @override
  String wh_delete(String url) {
    return '[Délété $url~~~~]';
  }

  @override
  String wh_delete_title(String url) {
    return '[Délété thé wébhôôk $url?~~~~~~~~]';
  }

  @override
  String get wh_delete_message =>
      '[Évéñtš wîll ñô lôñgér bé šéñt théré.~~~~~~~~~~~]';

  @override
  String get wh_delete_confirm => '[Délété wébhôôk~~~~~]';

  @override
  String get nav_manage_plugins => '[Plûgîñš~~~]';

  @override
  String get log_level => '[Lévél~~]';

  @override
  String get log_level_all => '[Âll lévélš~~~]';

  @override
  String get log_level_info => '[Îñfô àñd àbôvé~~~~~]';

  @override
  String get log_level_warn => '[Wàrñîñgš àñd érrôrš~~~~~~]';

  @override
  String get log_level_error => '[Érrôrš ôñlý~~~~]';

  @override
  String get log_search => '[Šéàrçh thé lôg~~~~~]';

  @override
  String get log_refresh => '[Réfréšh~~~]';

  @override
  String get log_empty => '[Ñô lôg réçôrdš.~~~~~]';

  @override
  String get log_error => '[Thé lôg çôûld ñôt bé réàd.~~~~~~~~]';

  @override
  String get pl_intro =>
      '[Plûgîñš àré JàvàŠçrîpt éxtéñšîôñš thàt réšôlvé lîñkš, réñéw éxpîréd ôñéš àñd réàçt tô dôwñlôàdš štàrtîñg, fàîlîñg àñd fîñîšhîñg. Théý rûñ îñšîdé thé dàémôñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pl_install => '[Îñštàll à plûgîñ~~~~~]';

  @override
  String get pl_install_title => '[Îñštàll à plûgîñ~~~~~]';

  @override
  String get pl_install_message =>
      '[Thé plûgîñ îš îñštàlléd šwîtçhéd ôff. Ýôû révîéw whàt ît màý dô béfôré ît rûñš.~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pl_install_go => '[Îñštàll~~~]';

  @override
  String get pl_source => '[Whéré frôm~~~]';

  @override
  String get pl_source_desc =>
      '[Â fôldér ôñ thé çômpûtér thé dàémôñ rûñš ôñ, ôr à gît àddréšš.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pl_ref => '[Véršîôñ~~~]';

  @override
  String get pl_ref_desc =>
      '[Â bràñçh, tàg ôr çômmît, fôr à gît àddréšš. Ôptîôñàl.~~~~~~~~~~~~~~~~]';

  @override
  String get pl_replace => '[Réplàçé à plûgîñ ôf thé šàmé ñàmé~~~~~~~~~~]';

  @override
  String get pl_empty_title => '[Ñô plûgîñš îñštàlléd~~~~~~]';

  @override
  String get pl_empty_message =>
      '[Îñštàll ôñé frôm à fôldér ôr à gît àddréšš.~~~~~~~~~~~~~]';

  @override
  String pl_enabled(String name) {
    return '[Rûñ $name~~~]';
  }

  @override
  String get pl_permissions => '[Pérmîššîôñš~~~~]';

  @override
  String get pl_logs => '[Lôg~]';

  @override
  String pl_remove(String name) {
    return '[Rémôvé $name~~~~]';
  }

  @override
  String pl_remove_title(String name) {
    return '[Rémôvé $name?~~~~~]';
  }

  @override
  String get pl_remove_message =>
      '[Thé plûgîñ, îtš fîléš àñd thé dàtà ît štôréd àré délétéd.~~~~~~~~~~~~~~~~~~]';

  @override
  String get pl_remove_confirm => '[Rémôvé plûgîñ~~~~]';

  @override
  String pl_logs_title(String name) {
    return '[Lôg ôf $name~~~~]';
  }

  @override
  String pl_review_title(String name) {
    return '[Whàt $name màý dô~~~~~~]';
  }

  @override
  String get pl_review_fresh =>
      '[Thé plûgîñ îš îñštàlléd bût ñôt rûññîñg.~~~~~~~~~~~~]';

  @override
  String pl_review_source(String source, String version) {
    return '[Frôm $source, véršîôñ $version.~~~~~~~~~~]';
  }

  @override
  String get pl_hooks => '[Ît réàçtš tô~~~~]';

  @override
  String get pl_hooks_none => '[Ñô évéñtš.~~~]';

  @override
  String get pl_hosts => '[Ît màý çôñtàçt~~~~~]';

  @override
  String get pl_hosts_none => '[Ñô ôthér çômpûtérš.~~~~~~]';

  @override
  String get pl_trust_warning =>
      '[Â plûgîñ rûñš îñšîdé thé dàémôñ àñd çàñ çôñtàçt thé hôštš lîštéd. Ôñlý šwîtçh ôñ plûgîñš ýôû trûšt.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pl_keep_off => '[Kéép ît ôff~~~~]';

  @override
  String get pl_enable => '[Šwîtçh ît ôñ~~~~]';

  @override
  String get nav_manage_browser => '[Brôwšér tôôl~~~~]';

  @override
  String get br_intro =>
      '[Šômé pàgéš ôñlý šhôw théîr dôwñlôàdš îñ à réàl brôwšér. Ôpéñ ôñé héré àñd thé dàémôñ\'š héàdléšš brôwšér lîštš whàt thé pàgé léàdš tô: fîléš, vîdéô àñd àûdîô štréàmš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get br_open_title => '[Ôpéñ à pàgé~~~~]';

  @override
  String get br_url => '[Pàgé àddréšš~~~~]';

  @override
  String get br_url_invalid =>
      '[Ûšé àñ àddréšš thàt štàrtš wîth http:// ôr httpš://.~~~~~~~~~~~~~~~~]';

  @override
  String get br_open => '[Ôpéñ~~]';

  @override
  String get br_opening => '[Ôpéñîñg…~~~]';

  @override
  String get br_error => '[Thé pàgé çôûld ñôt bé ôpéñéd.~~~~~~~~~]';

  @override
  String br_result_info(String url, String group) {
    return '[Ôpéñéd $url îñ thé grôûp $group.~~~~~~~~~~~]';
  }

  @override
  String get br_none => '[Thé pàgé léd tô ñô dôwñlôàdš.~~~~~~~~~]';

  @override
  String get br_download => '[Dôwñlôàd~~~]';

  @override
  String br_added(String name) {
    return '[Âddéd $name~~~~]';
  }

  @override
  String get br_profiles_title => '[Brôwšér prôfîléš~~~~~]';

  @override
  String get br_profiles_desc =>
      '[Éàçh šîté grôûp hàš îtš ôwñ prôfîlé, whîçh kéépš thé lôgîñš ôf thé pàgéš ôpéñéd théré.~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get br_profiles_none => '[Ñô prôfîléš ýét.~~~~~]';

  @override
  String get br_profiles_error =>
      '[Thé prôfîléš çôûld ñôt bé lîštéd.~~~~~~~~~~]';

  @override
  String br_profile_delete(String group) {
    return '[Délété thé prôfîlé $group~~~~~~~~]';
  }

  @override
  String br_profile_delete_title(String group) {
    return '[Délété thé prôfîlé ôf $group?~~~~~~~~~]';
  }

  @override
  String get br_profile_delete_message =>
      '[Îtš çôôkîéš àñd štôréd dàtà àré rémôvéd. Ît çàññôt bé délétéd whîlé îtš brôwšér rûñš.~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get br_profile_delete_confirm => '[Délété prôfîlé~~~~~]';

  @override
  String get br_state_title => '[Thé héàdléšš brôwšér~~~~~~]';

  @override
  String get br_state_in_use => '[Îñ ûšé~~]';

  @override
  String get br_state_unused => '[Ñôt ûšéd ýét~~~~]';

  @override
  String get br_state_running => '[Rûññîñg~~~]';

  @override
  String get br_state_none => '[Ñôñé~~]';

  @override
  String get br_state_max => '[Ât môšt àt ôñçé~~~~~]';

  @override
  String get br_tools_title => '[Prôgràmš~~~]';

  @override
  String get nav_manage_transfer => '[Împôrt àñd éxpôrt~~~~~~]';

  @override
  String get tr_intro =>
      '[Âdd màñý dôwñlôàdš frôm à lîšt, ôr wrîté ýôûr dôwñlôàdš ôût àš à lîšt. Ñôthîñg îš àddéd ûñtîl ýôû hàvé šééñ whàt wôûld hàppéñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get tr_import_title => '[Împôrt à lîšt~~~~]';

  @override
  String get tr_list => '[Thé lîšt~~~]';

  @override
  String get tr_list_desc => '[Pàšté ît héré, ôr çhôôšé à fîlé.~~~~~~~~~~]';

  @override
  String get tr_choose => '[Çhôôšé à fîlé…~~~~~]';

  @override
  String get tr_format => '[Kîñd ôf lîšt~~~~]';

  @override
  String get tr_format_urls => '[Ôñé lîñk pér lîñé~~~~~~]';

  @override
  String get tr_format_json => '[DLM JŠÔÑ~~~]';

  @override
  String get tr_format_aria2 => '[àrîà2 îñpût fîlé~~~~~]';

  @override
  String get tr_default_queue => '[Thé défàûlt qûéûé~~~~~~]';

  @override
  String get tr_duplicates => '[Âdd dûplîçàtéš tôô~~~~~~]';

  @override
  String get tr_duplicates_desc =>
      '[Ôthérwîšé lîñkš thàt àré àlréàdý îñ thé lîšt àré škîppéd.~~~~~~~~~~~~~~~~~~]';

  @override
  String get tr_preview => '[Prévîéw~~~]';

  @override
  String tr_preview_summary(int ok, int failed) {
    return '[Wôûld àdd $ok, wôûld ñôt àdd $failed.~~~~~~~~~~~~]';
  }

  @override
  String get tr_export_title => '[Éxpôrt dôwñlôàdš~~~~~]';

  @override
  String get tr_export_format => '[Fîlé kîñd tô éxpôrt~~~~~~]';

  @override
  String get tr_export_queue => '[Qûéûé~~]';

  @override
  String get tr_all_queues => '[Âll qûéûéš~~~]';

  @override
  String get tr_export_status => '[Whîçh dôwñlôàdš~~~~~]';

  @override
  String get tr_all_statuses => '[Âll ôf thém~~~~]';

  @override
  String get tr_export => '[Éxpôrt~~]';

  @override
  String tr_export_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš',
      one: '1 dôwñlôàd',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get tr_export_text => '[Thé éxpôrtéd lîšt~~~~~~]';

  @override
  String get nav_manage_statistics => '[Štàtîštîçš~~~]';

  @override
  String get st_error => '[Thé štàtîštîçš çôûld ñôt bé réàd.~~~~~~~~~~]';

  @override
  String get st_totals => '[Tôtàlš~~]';

  @override
  String get st_tasks => '[Dôwñlôàdš~~~]';

  @override
  String get st_downloaded => '[Dôwñlôàdéd îñ àll~~~~~~]';

  @override
  String get st_by_status => '[Bý štàté~~~]';

  @override
  String get st_by_engine => '[Bý éñgîñé~~~]';

  @override
  String st_completed_in(String period) {
    return '[Fîñîšhéd îñ thé làšt $period~~~~~~~~~]';
  }

  @override
  String get st_bucket => '[Bûçkét~~]';

  @override
  String get st_bucket_hour => '[Pér hôûr~~~]';

  @override
  String get st_bucket_day => '[Pér dàý~~~]';

  @override
  String get st_group => '[Šplît bý~~~]';

  @override
  String get st_group_none => '[Ñôthîñg~~~]';

  @override
  String get st_group_engine => '[Éñgîñé~~]';

  @override
  String get st_group_queue => '[Qûéûé~~]';

  @override
  String get st_timeline => '[Tràffîç~~~]';

  @override
  String st_timeline_summary(String down, String up) {
    return '[Dôwñlôàdéd $down, ûplôàdéd $up îñ thîš ràñgé.~~~~~~~~~~~~~~~]';
  }

  @override
  String get st_timeline_empty => '[Ñô tràffîç îñ thîš ràñgé.~~~~~~~~]';

  @override
  String get st_all_traffic => '[Âll tràffîç~~~~]';

  @override
  String get st_history => '[Fîñîšhéd dôwñlôàdš~~~~~~]';

  @override
  String get st_history_search => '[Šéàrçh bý ñàmé ôr lîñk~~~~~~~]';

  @override
  String get st_history_empty => '[Ñô fîñîšhéd dôwñlôàdš.~~~~~~~]';

  @override
  String get st_history_more => '[Šhôw môré~~~]';

  @override
  String get st_cleanup_title => '[Çléàñ ûp~~~]';

  @override
  String get st_cleanup_desc =>
      '[Rémôvéš fîñîšhéd dôwñlôàdš frôm thé lîšt. Thé àûtômàtîç çléàñûp ôf thé rétéñtîôñ šéttîñg ñévér délétéš fîléš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get st_cleanup_days => '[Ôldér thàñ~~~]';

  @override
  String get st_days => '[dàýš~~]';

  @override
  String get st_cleanup_files => '[Âlšô délété thé fîléš~~~~~~~]';

  @override
  String get st_cleanup_files_desc =>
      '[Ôff kéépš thé fîléš ôñ dîšk àñd ôñlý rémôvéš thé lîšt éñtrîéš.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get st_cleanup_preview => '[Çhéçk whàt wôûld gô~~~~~~]';

  @override
  String st_cleanup_preview_result(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš',
      one: '1 dôwñlôàd',
    );
    return '[$_temp0 ($size) wôûld bé rémôvéd.~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get st_cleanup_go => '[Çléàñ ûp~~~]';

  @override
  String st_cleanup_confirm_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš',
      one: '1 dôwñlôàd',
    );
    return '[Rémôvé $_temp0?~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get st_cleanup_confirm_list =>
      '[Théý léàvé thé lîšt; thé fîléš štàý whéré théý àré.~~~~~~~~~~~~~~~~]';

  @override
  String get st_cleanup_confirm_files =>
      '[Théý léàvé thé lîšt àñd théîr fîléš àré délétéd frôm thé dîšk. Thîš çàññôt bé ûñdôñé.~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String st_cleanup_done(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dôwñlôàdš',
      one: '1 dôwñlôàd',
    );
    return '[Rémôvéd $_temp0~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String st_cleanup_done_failed(int deleted, int failed) {
    return '[Rémôvéd $deleted; $failed çôûld ñôt bé rémôvéd~~~~~~~~~~~~~~~]';
  }

  @override
  String get nav_manage_daemon => '[Dàémôñ~~]';

  @override
  String get dm_intro =>
      '[Hôw thé dôwñlôàd šérvîçé îtšélf štàrtš: whéré ît lîštéñš, îtš éñgîñéš àñd prôgràmš, îtš lôggîñg. Môšt çhàñgéš tàké éfféçt àftér à réštàrt.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String dm_file(String file) {
    return '[Réàd frôm $file~~~~~]';
  }

  @override
  String dm_file_error(String error) {
    return '[Thé çôñfîgûràtîôñ fîlé hàš à prôblém: $error~~~~~~~~~~~~~~]';
  }

  @override
  String get dm_pending_title => '[Â réštàrt îš ñéédéd~~~~~~]';

  @override
  String get dm_pending_message =>
      '[Šômé šàvéd çhàñgéš àré wàîtîñg fôr thé dàémôñ tô réštàrt.~~~~~~~~~~~~~~~~~~]';

  @override
  String get dm_restart_now => '[Réštàrt ñôw~~~~]';

  @override
  String dm_pending_value(String value) {
    return '[àftér thé réštàrt: $value~~~~~~~~]';
  }

  @override
  String get dm_read_only => '[šét bý à flàg ôr thé éñvîrôñméñt~~~~~~~~~~]';

  @override
  String get dm_saved => '[Çôñfîgûràtîôñ šàvéd~~~~~~]';

  @override
  String get dm_needs_restart =>
      '[Théšé çhàñgéš tàké éfféçt àftér à réštàrt.~~~~~~~~~~~~~]';

  @override
  String get dm_restart_title => '[Réštàrt thé dàémôñ?~~~~~~]';

  @override
  String get dm_restart_message =>
      '[Dôwñlôàdš thàt àré rûññîñg àré réqûéûéd àñd štàrt àgàîñ àftérwàrdš.~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get dm_restart_confirm => '[Réštàrt~~~]';

  @override
  String get dm_restarting => '[Thé dàémôñ îš réštàrtîñg~~~~~~~~]';

  @override
  String get dm_log_title => '[Lôg~]';

  @override
  String get nav_manage_access => '[Âççéšš~~]';

  @override
  String get ac_identity => '[Thîš àpp~~~]';

  @override
  String get ac_signed_in => '[Šîgñéd îñ àš~~~~]';

  @override
  String ac_who(String name, String scope, String kind) {
    return '[$name ($scope, $kind)~~~~~~~~]';
  }

  @override
  String get ac_scope_admin => '[çàñ çhàñgé évérýthîñg~~~~~~~]';

  @override
  String get ac_scope_read => '[réàd ôñlý~~~]';

  @override
  String get ac_primary => '[thé màîñ tôkéñ~~~~~]';

  @override
  String get ac_named => '[à ñàméd tôkéñ~~~~]';

  @override
  String get ac_rotate => '[Réplàçé thé màîñ tôkéñ~~~~~~~]';

  @override
  String get ac_rotate_desc =>
      '[Màkéš à ñéw màîñ tôkéñ àñd štôpš thé ôld ôñé wôrkîñg àt ôñçé.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_rotate_title => '[Réplàçé thé màîñ tôkéñ?~~~~~~~]';

  @override
  String get ac_rotate_message =>
      '[Évérý çlîéñt thàt ûšéš thé ôld tôkéñ, šûçh àš à brôwšér éxtéñšîôñ ôr à šçrîpt, štôpš wôrkîñg ûñtîl ît îš gîvéñ thé ñéw ôñé. Thîš àpp îš šîgñéd îñ àgàîñ àûtômàtîçàllý.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_rotate_confirm => '[Réplàçé ît~~~]';

  @override
  String get ac_rotated_title => '[Thé ñéw màîñ tôkéñ~~~~~~]';

  @override
  String get ac_tokens => '[Ñàméd tôkéñš~~~~]';

  @override
  String get ac_tokens_desc =>
      '[Gîvé à dàšhbôàrd, à šçrîpt ôr àñôthér dévîçé à tôkéñ ôf îtš ôwñ, àñd révôké ît whéñ ît îš ñô lôñgér ñéédéd.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_tokens_none => '[Ñô ñàméd tôkéñš.~~~~~]';

  @override
  String get ac_tokens_error => '[Thé tôkéñš çôûld ñôt bé lîštéd.~~~~~~~~~~]';

  @override
  String get ac_add => '[Âdd à tôkéñ~~~~]';

  @override
  String get ac_add_title => '[Âdd à tôkéñ~~~~]';

  @override
  String get ac_name => '[Ñàmé~~]';

  @override
  String get ac_name_hint => '[dàšhbôàrd~~~]';

  @override
  String get ac_scope => '[Çàñ~]';

  @override
  String get ac_scope_desc =>
      '[Â réàd-ôñlý tôkéñ çàñ lôôk àt évérýthîñg éxçépt çôôkîéš, àñd çhàñgé ñôthîñg.~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_create => '[Çréàté~~]';

  @override
  String ac_created_title(String name) {
    return '[Thé tôkéñ $name~~~~~]';
  }

  @override
  String ac_created(String date) {
    return '[çréàtéd $date~~~~~]';
  }

  @override
  String get ac_never_used => '[ñévér ûšéd~~~]';

  @override
  String ac_last_used(String date) {
    return '[làšt ûšéd $date~~~~~]';
  }

  @override
  String ac_delete(String name) {
    return '[Révôké thé tôkéñ $name~~~~~~~]';
  }

  @override
  String ac_delete_title(String name) {
    return '[Révôké thé tôkéñ $name?~~~~~~~~]';
  }

  @override
  String get ac_delete_message => '[Whàtévér ûšéš ît štôpš wôrkîñg.~~~~~~~~~~]';

  @override
  String get ac_delete_confirm => '[Révôké tôkéñ~~~~]';

  @override
  String get ac_secret_once =>
      '[Thîš îš thé ôñlý tîmé thé tôkéñ îš šhôwñ. Çôpý ît ñôw àñd kéép ît šôméwhéré šàfé.~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_secret_done => '[Î hàvé çôpîéd ît~~~~~]';

  @override
  String get ac_secret_gone => '[Thé tôkéñ îš ñôt šhôwñ àgàîñ~~~~~~~~~]';

  @override
  String get ac_nh_title => '[Brôwšér éxtéñšîôñ~~~~~~]';

  @override
  String get ac_nh_desc =>
      '[Thé éxtéñšîôñ tàlkš tô thé dôwñlôàd šérvîçé thrôûgh à ñàtîvé hôšt thàt îš régîštéréd wîth éàçh brôwšér. Îñštàllîñg wôrkš ôñlý ôñ thé çômpûtér thé dàémôñ rûñš ôñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_nh_origins => '[Âllôwéd éxtéñšîôñš~~~~~~]';

  @override
  String get ac_nh_no_origins => '[Ñôñé ýét~~~]';

  @override
  String get ac_nh_error =>
      '[Thé éxtéñšîôñ hôšt çàññôt bé màñàgéd frôm héré.~~~~~~~~~~~~~~~]';

  @override
  String get ac_nh_ids => '[Éxtéñšîôñ ÎDš~~~~]';

  @override
  String get ac_nh_ids_desc =>
      '[Šépàràtéd bý çômmàš ôr špàçéš. Ñéédéd tô îñštàll.~~~~~~~~~~~~~~~]';

  @override
  String get ac_nh_install => '[Îñštàll fôr àll brôwšérš~~~~~~~~]';

  @override
  String get ac_nh_remove => '[Rémôvé~~]';

  @override
  String ac_nh_done(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dôñé fôr $count brôwšérš',
      one: 'Dôñé fôr 1 brôwšér',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get ac_mcp_title => '[Âššîštàñtš (MÇP)~~~~~]';

  @override
  String get ac_mcp_desc =>
      '[Âñ ÂÎ àššîštàñt thàt špéàkš thé Môdél Çôñtéxt Prôtôçôl çàñ àdd àñd màñàgé dôwñlôàdš. Ît šîgñš îñ wîth à tôkéñ.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ac_mcp_url => '[Âddréšš~~~]';

  @override
  String get ac_mcp_claude => '[Çlàûdé Çôdé~~~~]';

  @override
  String get ac_mcp_json => '[Šéttîñgš fîlé (JŠÔÑ)~~~~~~]';

  @override
  String get ac_mcp_token_note =>
      '[Réplàçé <tôkéñ> wîth à tôkéñ frôm thîš pàgé. Â réàd-ôñlý tôkéñ létš àñ àššîštàñt lôôk bût ñôt çhàñgé àñýthîñg.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get nav_manage_preferences => '[Préféréñçéš~~~~]';

  @override
  String get pref_intro =>
      '[Hôw thé àpp lôôkš àñd àškš. Çhàñgéš àpplý àt ôñçé.~~~~~~~~~~~~~~~]';

  @override
  String get pref_appearance => '[Âppéàràñçé~~~]';

  @override
  String get pref_theme => '[Thémé~~]';

  @override
  String get pref_theme_system => '[Šýštém~~]';

  @override
  String get pref_theme_light => '[Lîght~~]';

  @override
  String get pref_theme_dark => '[Dàrk~~]';

  @override
  String get pref_accent => '[Âççéñt çôlôûr~~~~]';

  @override
  String get pref_accent_default => '[Thé šýštém\'š~~~~]';

  @override
  String get pref_accent_indigo => '[DLM îñdîgô~~~]';

  @override
  String get pref_accent_custom => '[Çûštôm çôlôûr~~~~]';

  @override
  String get pref_accent_blue => '[Blûé~~]';

  @override
  String get pref_accent_green => '[Grééñ~~]';

  @override
  String get pref_accent_orange => '[Ôràñgé~~]';

  @override
  String get pref_accent_red => '[Réd~]';

  @override
  String get pref_accent_purple => '[Pûrplé~~]';

  @override
  String get pref_accent_pink => '[Pîñk~~]';

  @override
  String get pref_skin => '[Lôôk àñd féél~~~~]';

  @override
  String get pref_skin_desc =>
      '[Thé àpp fôllôwš ýôûr šýštém; çhôôšé àñôthér tô šéé thé àpp dréššéd àš ôñ thàt šýštém.~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_skin_auto => '[Màtçh thîš šýštém~~~~~~]';

  @override
  String get pref_skin_macos => '[màçÔŠ~~]';

  @override
  String get pref_skin_fluent => '[Wîñdôwš (Flûéñt)~~~~~]';

  @override
  String get pref_skin_adwaita => '[GÑÔMÉ (Âdwàîtà)~~~~~]';

  @override
  String get pref_skin_breeze => '[KDÉ (Brééžé)~~~~]';

  @override
  String get pref_density => '[Rôw héîght~~~]';

  @override
  String get pref_confirmations => '[Âškîñg fîršt~~~~]';

  @override
  String get pref_confirm_delete => '[Âšk béfôré délétîñg dôwñlôàdš~~~~~~~~~]';

  @override
  String get pref_confirm_delete_desc =>
      '[Ôff délétéš àt ôñçé, kéépîñg thé fîléš ôñ dîšk.~~~~~~~~~~~~~~~]';

  @override
  String get tray_tooltip => '[DLM~]';

  @override
  String get tray_show => '[Šhôw DLM~~~]';

  @override
  String get tray_pause_all => '[Pàûšé àll~~~]';

  @override
  String get tray_resume_all => '[Réšûmé àll~~~]';

  @override
  String get tray_add => '[Âdd dôwñlôàdš…~~~~~]';

  @override
  String get tray_quit => '[Qûît DLM~~~]';

  @override
  String get notif_completed => '[Dôwñlôàd fîñîšhéd~~~~~~]';

  @override
  String get notif_failed => '[Dôwñlôàd fàîléd~~~~~]';

  @override
  String get notif_expired => '[Lîñk éxpîréd~~~~]';

  @override
  String get notif_open => '[Ôpéñ~~]';

  @override
  String get notif_folder => '[Šhôw îñ fôldér~~~~~]';

  @override
  String get notif_retry => '[Rétrý~~]';

  @override
  String get notif_queue => '[Qûéûé fîñîšhéd~~~~~]';

  @override
  String get setup_no_tray =>
      '[Thîš šýštém hàš ñô méñû-bàr îçôñ, šô çlôšîñg thé wîñdôw qûîtš thé àpp.~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_notifications => '[Ñôtîfîçàtîôñš~~~~]';

  @override
  String get pref_tray =>
      '[Šhôw àñ îçôñ îñ thé méñû bàr ôr ñôtîfîçàtîôñ àréà~~~~~~~~~~~~~~~]';

  @override
  String get pref_tray_desc =>
      '[Çlôšîñg thé wîñdôw théñ kéépš thé àpp rûññîñg; qûît frôm thé îçôñ\'š méñû. Wîthôût àñ îçôñ, çlôšîñg thé wîñdôw qûîtš.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_notify =>
      '[Téll mé whéñ à dôwñlôàd fîñîšhéš ôr fàîlš~~~~~~~~~~~~~]';

  @override
  String get pref_notify_desc =>
      '[Â šýštém ñôtîfîçàtîôñ wîth bûttôñš tô ôpéñ thé fîlé ôr rétrý.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get drop_nothing =>
      '[Ñôthîñg tô àdd: drôp .tôrréñt fîléš ôr téxt fîléš wîth lîñkš.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get clip_offer_title => '[Â lîñk îš ôñ thé çlîpbôàrd~~~~~~~~]';

  @override
  String get clip_offer_add => '[Âdd~]';

  @override
  String get clip_offer_dismiss => '[Ñôt ñôw~~~]';

  @override
  String get pref_units => '[Šîžéš~~]';

  @override
  String get pref_units_iec => '[Kîbîbýtéš (KîB)~~~~~]';

  @override
  String get pref_units_si => '[Kîlôbýtéš (kB)~~~~~]';

  @override
  String get pref_language => '[Làñgûàgé~~~]';

  @override
  String get pref_language_system => '[Šýštém~~]';

  @override
  String get pref_clipboard => '[Wàtçh thé çlîpbôàrd fôr lîñkš~~~~~~~~~]';

  @override
  String get pref_clipboard_desc =>
      '[Whéñ thé wîñdôw îš îñ frôñt, ôffér tô àdd àñ http, ftp, màgñét ôr éd2k lîñk thàt wàš çôpîéd. Ôff ûñtîl ýôû tûrñ ît ôñ. Thé çlîpbôàrd îš ñôt wrîttéñ tô thé lôg.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_shortcuts => '[Šhôrtçûtš~~~]';

  @override
  String get pref_global => '[Glôbàl šhôrtçûtš~~~~~]';

  @override
  String get pref_global_desc =>
      '[Wôrk whîlé àñôthér prôgràm hàš thé fôçûš. Ôff ûñtîl ýôû šét à çhôrd; à çhôrd ñéédš Çtrl, Âlt, Šhîft ôr thé šýštém kéý.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_global_unsupported =>
      '[Ñôt àvàîlàblé héré: à Wàýlàñd šéššîôñ dôéš ñôt lét àppš çlàîm kéýš fôr thé whôlé déšktôp.~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get cmd_global_toggle => '[Šhôw ôr hîdé DLM~~~~~]';

  @override
  String get cmd_global_clipboard => '[Âdd thé lîñk ôñ thé çlîpbôàrd~~~~~~~~~]';

  @override
  String get pref_shortcuts_clear => '[Çléàr~~]';

  @override
  String get pref_shortcuts_none => '[Ñôt šét~~~]';

  @override
  String get pref_shortcuts_change => '[Çhàñgé~~]';

  @override
  String get pref_shortcuts_press => '[Préšš thé ñéw šhôrtçût~~~~~~~]';

  @override
  String get pref_shortcuts_reset => '[Réšét šhôrtçûtš~~~~~]';

  @override
  String get ab_updates => '[Ûpdàtéš~~~]';

  @override
  String get ab_channel => '[Çhàññél~~~]';

  @override
  String get ab_channel_stable => '[Štàblé~~]';

  @override
  String get ab_channel_beta => '[Bétà~~]';

  @override
  String get ab_check => '[Çhéçk fôr ûpdàtéš~~~~~~]';

  @override
  String get ab_checking => '[Çhéçkîñg…~~~]';

  @override
  String get ab_up_to_date =>
      '[Thîš îš thé ñéwéšt véršîôñ ôñ thîš çhàññél.~~~~~~~~~~~~~]';

  @override
  String ab_available(String version) {
    return '[$version îš àvàîlàblé~~~~~~~]';
  }

  @override
  String get ab_open_release => '[Ôpéñ thé réléàšé~~~~~]';

  @override
  String get ab_check_failed => '[Thé ûpdàté çhéçk dîd ñôt šûççééd.~~~~~~~~~~]';

  @override
  String pref_shortcuts_conflict(String command) {
    return '[Âlréàdý ûšéd bý $command~~~~~~~~]';
  }

  @override
  String get pref_startup => '[Štàrtûp~~~]';

  @override
  String get pref_login => '[Štàrt whéñ Î lôg îñ~~~~~~]';

  @override
  String get pref_login_desc =>
      '[Ôpéñš thé àpp îñ thé bàçkgrôûñd whéñ ýôû šîgñ îñ tô thîš çômpûtér.~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_start_hidden => '[Štàrt hîddéñ~~~~]';

  @override
  String get pref_start_hidden_desc =>
      '[Whéñ štàrtéd àt lôgîñ, kéép thé wîñdôw çlôšéd; ôpéñ ît frôm thé tràý îçôñ.~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get pref_daemon_service =>
      '[Kéép dôwñlôàdîñg wîthôût thé àpp~~~~~~~~~~]';

  @override
  String get pref_daemon_service_desc =>
      '[Štàrtš thé dôwñlôàd šérvîçé àt lôgîñ ôñ îtš ôwñ, šô qûéûéš àñd šçhédûléš rûñ whîlé thé àpp îš çlôšéd.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get nav_manage_about => '[Âbôût~~]';

  @override
  String get ab_title => '[DLM~]';

  @override
  String get ab_blurb =>
      '[Â dôwñlôàd màñàgér fôr fîléš, tôrréñtš àñd štréàmš, màdé ôf thîš àpp àñd à dôwñlôàd šérvîçé thàt dôéš thé wôrk.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ab_app => '[Thîš àpp~~~]';

  @override
  String get ab_daemon => '[Thé dôwñlôàd šérvîçé~~~~~~]';

  @override
  String get ab_version => '[Véršîôñ~~~]';

  @override
  String get ab_api => '[Tàlkš ÂPÎ révîšîôñ~~~~~~]';

  @override
  String ab_api_value(int current, int oldest) {
    return '[révîšîôñ $current, wôrkš wîth $oldest àñd ñéwér~~~~~~~~~~~~~~~]';
  }

  @override
  String get ab_system => '[Šýštém~~]';

  @override
  String get ab_address => '[Lîštéñš ôñ~~~]';

  @override
  String get ab_compat => '[Tôgéthér~~~]';

  @override
  String get ab_compat_ok => '[Théý wôrk tôgéthér.~~~~~~]';

  @override
  String get ab_compat_app_old =>
      '[Thé šérvîçé ñéédš à ñéwér véršîôñ ôf thîš àpp.~~~~~~~~~~~~~~]';

  @override
  String get ab_compat_daemon_old =>
      '[Thé šérvîçé îš ôldér thàñ thîš àpp šûppôrtš.~~~~~~~~~~~~~~]';

  @override
  String get ab_compat_unknown => '[Ñôt çôññéçtéd.~~~~~]';

  @override
  String get ab_support => '[Šûppôrt~~~]';

  @override
  String get ab_diagnostics => '[Dîàgñôštîçš~~~~]';

  @override
  String get ab_diagnostics_copy => '[Çôpý dîàgñôštîçš~~~~~]';

  @override
  String get ab_diagnostics_desc =>
      '[Pûtš véršîôñš, thé çôññéçtîôñš (wîthôût tôkéñš) àñd thé réçéñt lôg ôñ thé çlîpbôàrd, wîth šéçrétš rémôvéd, fôr ýôû tô pàšté îñtô à bûg répôrt.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ab_diagnostics_copied => '[Dîàgñôštîçš çôpîéd~~~~~~]';

  @override
  String get ab_licences => '[Ôpéñ-šôûrçé lîçéñçéš~~~~~~]';

  @override
  String get ab_licences_list => '[Pàçkàgéš~~~]';

  @override
  String get ab_licences_show => '[Šhôw thé lîçéñçéš~~~~~~]';

  @override
  String get ab_licences_desc =>
      '[DLM îš bûîlt frôm ôpéñ-šôûrçé pàçkàgéš. Théîr lîçéñçéš àré lîštéd héré.~~~~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ab_licences_none =>
      '[Ñô lîçéñçéš àré régîštéréd îñ thîš bûîld.~~~~~~~~~~~~~]';

  @override
  String ab_licences_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lîçéñçé téxtš',
      one: '1 lîçéñçé téxt',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get nav_tools => '[Tôôlš~~]';

  @override
  String get hub_button => '[Tôôlš, màñàgé àñd šéttîñgš~~~~~~~~]';

  @override
  String get hub_close => '[Çlôšé~~]';

  @override
  String add_category(String name, String dir) {
    return '[Wîll bé šôrtéd îñtô $name: $dir~~~~~~~~~~]';
  }

  @override
  String add_login_stored(String host) {
    return '[Â lôgîñ îš štôréd fôr $host~~~~~~~~~]';
  }

  @override
  String get add_login_add => '[Âdd à lôgîñ~~~~]';

  @override
  String add_cookies_stored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çôôkîéš àré štôréd fôr thîš šîté',
      one: '1 çôôkîé îš štôréd fôr thîš šîté',
    );
    return '[$_temp0~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
  }

  @override
  String get add_cookies_none =>
      '[Ñô çôôkîéš àré štôréd fôr thîš šîté~~~~~~~~~~~]';

  @override
  String add_login_none(String host) {
    return '[Ñô lôgîñ îš štôréd fôr $host~~~~~~~~~]';
  }

  @override
  String get insp_tab_events => '[Évéñtš~~]';

  @override
  String get ev_created => '[Âddéd tô thé lîšt~~~~~~]';

  @override
  String ev_status(String from, String to) {
    return '[$from → $to~~~~]';
  }

  @override
  String ev_refresh(String strategy, String outcome) {
    return '[Lîñk réñéwàl wîth $strategy: $outcome~~~~~~~~~~~~]';
  }

  @override
  String get ev_current_error => '[Fàîléd~~]';

  @override
  String get ev_none =>
      '[Ñôthîñg hàš hàppéñéd tô thîš dôwñlôàd šîñçé thé àpp çôññéçtéd.~~~~~~~~~~~~~~~~~~~]';

  @override
  String get ev_note =>
      '[Thîš îš whàt thé àpp hàš šééñ šîñçé ît çôññéçtéd; thé dàémôñ dôéš ñôt kéép à lôñgér hîštôrý.~~~~~~~~~~~~~~~~~~~~~~~~~~~~]';
}
