import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @problem_task_not_found.
  ///
  /// In en, this message translates to:
  /// **'That download does not exist (any more).'**
  String get problem_task_not_found;

  /// No description provided for @problem_queue_not_found.
  ///
  /// In en, this message translates to:
  /// **'That queue does not exist (any more).'**
  String get problem_queue_not_found;

  /// No description provided for @problem_category_not_found.
  ///
  /// In en, this message translates to:
  /// **'That category does not exist (any more).'**
  String get problem_category_not_found;

  /// No description provided for @problem_webhook_not_found.
  ///
  /// In en, this message translates to:
  /// **'That webhook does not exist (any more).'**
  String get problem_webhook_not_found;

  /// No description provided for @problem_credential_not_found.
  ///
  /// In en, this message translates to:
  /// **'That login does not exist (any more).'**
  String get problem_credential_not_found;

  /// No description provided for @problem_plugin_not_found.
  ///
  /// In en, this message translates to:
  /// **'That plugin does not exist (any more).'**
  String get problem_plugin_not_found;

  /// No description provided for @problem_cookie_not_found.
  ///
  /// In en, this message translates to:
  /// **'That cookie does not exist (any more).'**
  String get problem_cookie_not_found;

  /// No description provided for @problem_engine_not_found.
  ///
  /// In en, this message translates to:
  /// **'That download engine does not exist (any more).'**
  String get problem_engine_not_found;

  /// No description provided for @problem_browser_profile_not_found.
  ///
  /// In en, this message translates to:
  /// **'That browser profile does not exist (any more).'**
  String get problem_browser_profile_not_found;

  /// No description provided for @problem_browser_result_not_found.
  ///
  /// In en, this message translates to:
  /// **'That page result does not exist (any more).'**
  String get problem_browser_result_not_found;

  /// No description provided for @problem_browser_candidate_not_found.
  ///
  /// In en, this message translates to:
  /// **'That download candidate does not exist (any more).'**
  String get problem_browser_candidate_not_found;

  /// No description provided for @problem_refresh_attempt_not_found.
  ///
  /// In en, this message translates to:
  /// **'That link refresh does not exist (any more).'**
  String get problem_refresh_attempt_not_found;

  /// No description provided for @problem_resolve_result_not_found.
  ///
  /// In en, this message translates to:
  /// **'That link check does not exist (any more).'**
  String get problem_resolve_result_not_found;

  /// No description provided for @problem_queue_name_taken.
  ///
  /// In en, this message translates to:
  /// **'A queue with that name already exists.'**
  String get problem_queue_name_taken;

  /// No description provided for @problem_category_name_taken.
  ///
  /// In en, this message translates to:
  /// **'A category with that name already exists.'**
  String get problem_category_name_taken;

  /// No description provided for @problem_queue_not_empty.
  ///
  /// In en, this message translates to:
  /// **'The queue still has downloads. Move or delete them first.'**
  String get problem_queue_not_empty;

  /// No description provided for @problem_task_duplicate.
  ///
  /// In en, this message translates to:
  /// **'This file is already in your downloads ({status}).'**
  String problem_task_duplicate(String status);

  /// No description provided for @problem_task_file_exists.
  ///
  /// In en, this message translates to:
  /// **'A file with that name already exists in the target folder.'**
  String get problem_task_file_exists;

  /// No description provided for @problem_task_invalid_state.
  ///
  /// In en, this message translates to:
  /// **'This download cannot be {operation} while it is {status}.'**
  String problem_task_invalid_state(String operation, String status);

  /// No description provided for @problem_task_invalid_transition.
  ///
  /// In en, this message translates to:
  /// **'This download cannot change to that state right now.'**
  String get problem_task_invalid_transition;

  /// No description provided for @problem_task_locked.
  ///
  /// In en, this message translates to:
  /// **'This download is busy. Try again in a moment.'**
  String get problem_task_locked;

  /// No description provided for @problem_task_state_changed.
  ///
  /// In en, this message translates to:
  /// **'This download changed while you were working on it. Check its state and try again.'**
  String get problem_task_state_changed;

  /// No description provided for @problem_browser_running.
  ///
  /// In en, this message translates to:
  /// **'The browser is in use. Close its pages first.'**
  String get problem_browser_running;

  /// No description provided for @problem_category_bad_dir.
  ///
  /// In en, this message translates to:
  /// **'That folder is not allowed for a category.'**
  String get problem_category_bad_dir;

  /// No description provided for @problem_settings_invalid.
  ///
  /// In en, this message translates to:
  /// **'Some settings are not valid. Check the highlighted fields.'**
  String get problem_settings_invalid;

  /// No description provided for @problem_validation_failed.
  ///
  /// In en, this message translates to:
  /// **'Some values are not valid. Check the highlighted fields.'**
  String get problem_validation_failed;

  /// No description provided for @problem_invalid_argument.
  ///
  /// In en, this message translates to:
  /// **'Those values are not valid.'**
  String get problem_invalid_argument;

  /// No description provided for @problem_settings_changed.
  ///
  /// In en, this message translates to:
  /// **'The settings were changed somewhere else. The latest settings have been loaded; review your change and apply it again.'**
  String get problem_settings_changed;

  /// No description provided for @problem_browser_unavailable.
  ///
  /// In en, this message translates to:
  /// **'No browser is available. Install Chrome, Chromium, Edge or Brave, or allow downloading one in the settings.'**
  String get problem_browser_unavailable;

  /// No description provided for @problem_origin_failed.
  ///
  /// In en, this message translates to:
  /// **'The server of the file did not answer properly ({code}).'**
  String problem_origin_failed(String code);

  /// No description provided for @problem_request_cancelled.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled.'**
  String get problem_request_cancelled;

  /// No description provided for @problem_service_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The download service is not ready yet. Try again in a moment.'**
  String get problem_service_unavailable;

  /// No description provided for @problem_bad_request.
  ///
  /// In en, this message translates to:
  /// **'The request was not understood.'**
  String get problem_bad_request;

  /// No description provided for @problem_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'The access token was rejected. Check the token of this connection.'**
  String get problem_unauthorized;

  /// No description provided for @problem_forbidden.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do that.'**
  String get problem_forbidden;

  /// No description provided for @problem_not_found.
  ///
  /// In en, this message translates to:
  /// **'That does not exist (any more).'**
  String get problem_not_found;

  /// No description provided for @problem_conflict.
  ///
  /// In en, this message translates to:
  /// **'That conflicts with the current state. Refresh and try again.'**
  String get problem_conflict;

  /// No description provided for @problem_precondition_failed.
  ///
  /// In en, this message translates to:
  /// **'That was changed somewhere else. Refresh and try again.'**
  String get problem_precondition_failed;

  /// No description provided for @problem_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment.'**
  String get problem_too_many_requests;

  /// No description provided for @problem_server_error.
  ///
  /// In en, this message translates to:
  /// **'The download service had an internal problem.'**
  String get problem_server_error;

  /// No description provided for @problem_connection_lost.
  ///
  /// In en, this message translates to:
  /// **'The download service cannot be reached.'**
  String get problem_connection_lost;

  /// No description provided for @problem_connection_timeout.
  ///
  /// In en, this message translates to:
  /// **'The download service did not answer in time.'**
  String get problem_connection_timeout;

  /// No description provided for @problem_connection_certificate.
  ///
  /// In en, this message translates to:
  /// **'The certificate of the download service changed or is not trusted. Do not continue unless you expect this.'**
  String get problem_connection_certificate;

  /// No description provided for @problem_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get problem_unknown;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String relativeMinutesAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String relativeDaysAgo(int count);

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'dlm'**
  String get app_name;

  /// No description provided for @nav_label.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get nav_label;

  /// No description provided for @nav_all.
  ///
  /// In en, this message translates to:
  /// **'All Downloads'**
  String get nav_all;

  /// No description provided for @nav_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get nav_active;

  /// No description provided for @nav_queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get nav_queued;

  /// No description provided for @nav_paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get nav_paused;

  /// No description provided for @nav_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get nav_completed;

  /// No description provided for @nav_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get nav_failed;

  /// No description provided for @nav_queues.
  ///
  /// In en, this message translates to:
  /// **'Queues'**
  String get nav_queues;

  /// No description provided for @toolbar_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search downloads'**
  String get toolbar_search_placeholder;

  /// No description provided for @toolbar_search_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get toolbar_search_clear;

  /// No description provided for @toolbar_inspector_show.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get toolbar_inspector_show;

  /// No description provided for @toolbar_inspector_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get toolbar_inspector_hide;

  /// No description provided for @toolbar_palette.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get toolbar_palette;

  /// No description provided for @toolbar_label.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get toolbar_label;

  /// No description provided for @inspector_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No download selected'**
  String get inspector_empty_title;

  /// No description provided for @inspector_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Select a download to see its details.'**
  String get inspector_empty_message;

  /// No description provided for @inspector_resize.
  ///
  /// In en, this message translates to:
  /// **'Resize details'**
  String get inspector_resize;

  /// No description provided for @sidebar_resize.
  ///
  /// In en, this message translates to:
  /// **'Resize sidebar'**
  String get sidebar_resize;

  /// No description provided for @palette_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Type a command'**
  String get palette_placeholder;

  /// No description provided for @palette_no_results.
  ///
  /// In en, this message translates to:
  /// **'No matching command'**
  String get palette_no_results;

  /// No description provided for @palette_label.
  ///
  /// In en, this message translates to:
  /// **'Command palette'**
  String get palette_label;

  /// No description provided for @command_go_to.
  ///
  /// In en, this message translates to:
  /// **'Go to {destination}'**
  String command_go_to(String destination);

  /// No description provided for @command_toggle_inspector.
  ///
  /// In en, this message translates to:
  /// **'Show or hide details'**
  String get command_toggle_inspector;

  /// No description provided for @command_focus_search.
  ///
  /// In en, this message translates to:
  /// **'Search downloads'**
  String get command_focus_search;

  /// No description provided for @connection_connecting_title.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the download service'**
  String get connection_connecting_title;

  /// No description provided for @connection_connecting_message.
  ///
  /// In en, this message translates to:
  /// **'Starting {name}…'**
  String connection_connecting_message(String name);

  /// No description provided for @connection_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the download service'**
  String get connection_failed_title;

  /// No description provided for @connection_failed_message.
  ///
  /// In en, this message translates to:
  /// **'The app could not connect to {name}.'**
  String connection_failed_message(String name);

  /// No description provided for @connection_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get connection_retry;

  /// No description provided for @connection_token_rejected_title.
  ///
  /// In en, this message translates to:
  /// **'The access token was refused'**
  String get connection_token_rejected_title;

  /// No description provided for @connection_token_rejected_message.
  ///
  /// In en, this message translates to:
  /// **'{name} did not accept the saved token.'**
  String connection_token_rejected_message(String name);

  /// No description provided for @connection_incompatible_title.
  ///
  /// In en, this message translates to:
  /// **'This version of the app cannot talk to that service'**
  String get connection_incompatible_title;

  /// No description provided for @connection_incompatible_message.
  ///
  /// In en, this message translates to:
  /// **'Update the app or the service so their versions match.'**
  String get connection_incompatible_message;

  /// No description provided for @connection_trust_title.
  ///
  /// In en, this message translates to:
  /// **'Trust this server?'**
  String get connection_trust_title;

  /// No description provided for @connection_trust_message.
  ///
  /// In en, this message translates to:
  /// **'{name} presented a certificate the app has not seen before. Check that the fingerprint below matches the one on the server.'**
  String connection_trust_message(String name);

  /// No description provided for @connection_trust_accept.
  ///
  /// In en, this message translates to:
  /// **'Trust and connect'**
  String get connection_trust_accept;

  /// No description provided for @connection_trust_reject.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get connection_trust_reject;

  /// No description provided for @status_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get status_connected;

  /// No description provided for @connection_trust_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get connection_trust_subject;

  /// No description provided for @connection_trust_issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get connection_trust_issuer;

  /// No description provided for @connection_trust_expires.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get connection_trust_expires;

  /// No description provided for @connection_trust_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get connection_trust_fingerprint;

  /// No description provided for @connection_certificate_changed.
  ///
  /// In en, this message translates to:
  /// **'The server\'s certificate is different from the one you trusted. Do not continue unless you know it was replaced.'**
  String get connection_certificate_changed;

  /// No description provided for @connection_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String connection_reason(String reason);

  /// No description provided for @col_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get col_name;

  /// No description provided for @col_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get col_status;

  /// No description provided for @col_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get col_progress;

  /// No description provided for @col_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get col_size;

  /// No description provided for @col_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get col_speed;

  /// No description provided for @col_eta.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get col_eta;

  /// No description provided for @col_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get col_queue;

  /// No description provided for @col_added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get col_added;

  /// No description provided for @task_status_queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get task_status_queued;

  /// No description provided for @task_status_running.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get task_status_running;

  /// No description provided for @task_status_paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get task_status_paused;

  /// No description provided for @task_status_awaiting_link.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a link'**
  String get task_status_awaiting_link;

  /// No description provided for @task_status_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing link'**
  String get task_status_refreshing;

  /// No description provided for @task_status_postprocessing.
  ///
  /// In en, this message translates to:
  /// **'Finishing'**
  String get task_status_postprocessing;

  /// No description provided for @task_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get task_status_completed;

  /// No description provided for @task_status_error.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get task_status_error;

  /// No description provided for @task_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get task_status_unknown;

  /// No description provided for @task_unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed download'**
  String get task_unnamed;

  /// No description provided for @task_eta.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String task_eta(String time);

  /// No description provided for @task_row_label.
  ///
  /// In en, this message translates to:
  /// **'{name}, {status}'**
  String task_row_label(String name, String status);

  /// No description provided for @table_downloads_label.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get table_downloads_label;

  /// No description provided for @table_sorted_ascending.
  ///
  /// In en, this message translates to:
  /// **'sorted ascending'**
  String get table_sorted_ascending;

  /// No description provided for @table_sorted_descending.
  ///
  /// In en, this message translates to:
  /// **'sorted descending'**
  String get table_sorted_descending;

  /// No description provided for @table_resize_column.
  ///
  /// In en, this message translates to:
  /// **'Resize {column}'**
  String table_resize_column(String column);

  /// No description provided for @table_loading_row.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get table_loading_row;

  /// No description provided for @list_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading downloads'**
  String get list_loading;

  /// No description provided for @list_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No downloads here'**
  String get list_empty_title;

  /// No description provided for @list_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Downloads you add will appear in this list.'**
  String get list_empty_message;

  /// No description provided for @list_empty_search_title.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search'**
  String get list_empty_search_title;

  /// No description provided for @list_empty_search_message.
  ///
  /// In en, this message translates to:
  /// **'Try different words or clear the search.'**
  String get list_empty_search_message;

  /// No description provided for @list_error_title.
  ///
  /// In en, this message translates to:
  /// **'Could not load the downloads'**
  String get list_error_title;

  /// No description provided for @list_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get list_retry;

  /// No description provided for @action_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get action_pause;

  /// No description provided for @action_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get action_resume;

  /// No description provided for @action_restart.
  ///
  /// In en, this message translates to:
  /// **'Download again'**
  String get action_restart;

  /// No description provided for @action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete…'**
  String get action_delete;

  /// No description provided for @action_copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get action_copy_link;

  /// No description provided for @action_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get action_undo;

  /// No description provided for @action_dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get action_dismiss;

  /// No description provided for @toast_paused.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Paused 1 download} other{Paused {count} downloads}}'**
  String toast_paused(int count);

  /// No description provided for @toast_resumed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Resumed 1 download} other{Resumed {count} downloads}}'**
  String toast_resumed(int count);

  /// No description provided for @toast_deleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 download} other{Deleted {count} downloads}}'**
  String toast_deleted(int count);

  /// No description provided for @toast_restarted.
  ///
  /// In en, this message translates to:
  /// **'Download restarted'**
  String get toast_restarted;

  /// No description provided for @toast_link_copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get toast_link_copied;

  /// No description provided for @toast_some_failed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 download could not be changed} other{{count} downloads could not be changed}}'**
  String toast_some_failed(int count);

  /// No description provided for @toast_failure_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get toast_failure_unknown;

  /// No description provided for @delete_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete this download?} other{Delete {count} downloads?}}'**
  String delete_title(int count);

  /// No description provided for @delete_message.
  ///
  /// In en, this message translates to:
  /// **'They are removed from the list. Their files stay on disk unless you choose otherwise.'**
  String get delete_message;

  /// No description provided for @delete_files.
  ///
  /// In en, this message translates to:
  /// **'Also delete the downloaded files'**
  String get delete_files;

  /// No description provided for @delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_confirm;

  /// No description provided for @delete_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get delete_cancel;

  /// No description provided for @selection_count.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selection_count(int count);

  /// No description provided for @banner_reconnecting_title.
  ///
  /// In en, this message translates to:
  /// **'Connection to the download service lost'**
  String get banner_reconnecting_title;

  /// No description provided for @banner_reconnecting_message.
  ///
  /// In en, this message translates to:
  /// **'Trying to reconnect…'**
  String get banner_reconnecting_message;

  /// No description provided for @banner_daemon_restarting_title.
  ///
  /// In en, this message translates to:
  /// **'The download service stopped unexpectedly'**
  String get banner_daemon_restarting_title;

  /// No description provided for @banner_daemon_restarting_message.
  ///
  /// In en, this message translates to:
  /// **'It is restarting; your downloads continue from where they were.'**
  String get banner_daemon_restarting_message;

  /// No description provided for @banner_daemon_failed_title.
  ///
  /// In en, this message translates to:
  /// **'The download service keeps stopping'**
  String get banner_daemon_failed_title;

  /// No description provided for @banner_daemon_failed_message.
  ///
  /// In en, this message translates to:
  /// **'{reason}'**
  String banner_daemon_failed_message(String reason);

  /// No description provided for @banner_daemon_restart.
  ///
  /// In en, this message translates to:
  /// **'Restart service'**
  String get banner_daemon_restart;

  /// No description provided for @banner_dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get banner_dismiss;

  /// No description provided for @queue_new.
  ///
  /// In en, this message translates to:
  /// **'New queue'**
  String get queue_new;

  /// No description provided for @queue_new_title.
  ///
  /// In en, this message translates to:
  /// **'New queue'**
  String get queue_new_title;

  /// No description provided for @queue_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get queue_name_label;

  /// No description provided for @queue_name_placeholder.
  ///
  /// In en, this message translates to:
  /// **'For example Night downloads'**
  String get queue_name_placeholder;

  /// No description provided for @queue_name_taken.
  ///
  /// In en, this message translates to:
  /// **'A queue with that name already exists.'**
  String get queue_name_taken;

  /// No description provided for @queue_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get queue_create;

  /// No description provided for @queue_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename…'**
  String get queue_rename;

  /// No description provided for @queue_rename_title.
  ///
  /// In en, this message translates to:
  /// **'Rename queue'**
  String get queue_rename_title;

  /// No description provided for @queue_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get queue_save;

  /// No description provided for @queue_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete queue…'**
  String get queue_delete;

  /// No description provided for @queue_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String queue_delete_title(String name);

  /// No description provided for @queue_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Its downloads move to the default queue. Nothing is removed from disk.'**
  String get queue_delete_message;

  /// No description provided for @queue_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete queue'**
  String get queue_delete_confirm;

  /// No description provided for @queue_move_up.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get queue_move_up;

  /// No description provided for @queue_move_down.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get queue_move_down;

  /// No description provided for @queue_start.
  ///
  /// In en, this message translates to:
  /// **'Start queue'**
  String get queue_start;

  /// No description provided for @queue_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop queue'**
  String get queue_stop;

  /// No description provided for @queue_settings.
  ///
  /// In en, this message translates to:
  /// **'Queue settings…'**
  String get queue_settings;

  /// No description provided for @queue_menu.
  ///
  /// In en, this message translates to:
  /// **'Queue actions'**
  String get queue_menu;

  /// No description provided for @queue_state_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get queue_state_running;

  /// No description provided for @queue_state_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get queue_state_stopped;

  /// No description provided for @queue_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get queue_default;

  /// No description provided for @toast_queue_created.
  ///
  /// In en, this message translates to:
  /// **'Created “{name}”'**
  String toast_queue_created(String name);

  /// No description provided for @toast_queue_renamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to “{name}”'**
  String toast_queue_renamed(String name);

  /// No description provided for @toast_queue_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted “{name}”'**
  String toast_queue_deleted(String name);

  /// No description provided for @toast_queue_started.
  ///
  /// In en, this message translates to:
  /// **'“{name}” started'**
  String toast_queue_started(String name);

  /// No description provided for @toast_queue_stopped.
  ///
  /// In en, this message translates to:
  /// **'“{name}” stopped'**
  String toast_queue_stopped(String name);

  /// No description provided for @toast_queue_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved the settings of “{name}”'**
  String toast_queue_saved(String name);

  /// No description provided for @qs_title.
  ///
  /// In en, this message translates to:
  /// **'Settings of “{name}”'**
  String qs_title(String name);

  /// No description provided for @qs_intro.
  ///
  /// In en, this message translates to:
  /// **'Anything left empty follows the global settings.'**
  String get qs_intro;

  /// No description provided for @qs_group_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get qs_group_speed;

  /// No description provided for @qs_speed_limit.
  ///
  /// In en, this message translates to:
  /// **'Speed limit'**
  String get qs_speed_limit;

  /// No description provided for @qs_speed_limit_desc.
  ///
  /// In en, this message translates to:
  /// **'Per second, for the whole queue. Empty means no limit of its own.'**
  String get qs_speed_limit_desc;

  /// No description provided for @qs_speed_placeholder.
  ///
  /// In en, this message translates to:
  /// **'For example 2 MB'**
  String get qs_speed_placeholder;

  /// No description provided for @qs_invalid_size.
  ///
  /// In en, this message translates to:
  /// **'Enter a size like 500K or 2 MB.'**
  String get qs_invalid_size;

  /// No description provided for @qs_group_schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get qs_group_schedule;

  /// No description provided for @qs_schedule_on.
  ///
  /// In en, this message translates to:
  /// **'Run only at chosen times'**
  String get qs_schedule_on;

  /// No description provided for @qs_schedule_desc.
  ///
  /// In en, this message translates to:
  /// **'Outside these hours the queue waits; downloads resume when the next window opens.'**
  String get qs_schedule_desc;

  /// No description provided for @qs_schedule_grid.
  ///
  /// In en, this message translates to:
  /// **'Weekly schedule, one cell per hour'**
  String get qs_schedule_grid;

  /// No description provided for @qs_group_profiles.
  ///
  /// In en, this message translates to:
  /// **'Speed profiles'**
  String get qs_group_profiles;

  /// No description provided for @qs_profiles_desc.
  ///
  /// In en, this message translates to:
  /// **'A profile limits the speed while its hours are active.'**
  String get qs_profiles_desc;

  /// No description provided for @qs_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile {index}'**
  String qs_profile_title(int index);

  /// No description provided for @qs_profile_add.
  ///
  /// In en, this message translates to:
  /// **'Add a profile'**
  String get qs_profile_add;

  /// No description provided for @qs_profile_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get qs_profile_remove;

  /// No description provided for @qs_profile_limit.
  ///
  /// In en, this message translates to:
  /// **'Limit while active'**
  String get qs_profile_limit;

  /// No description provided for @qs_profile_unlimited.
  ///
  /// In en, this message translates to:
  /// **'Empty means unlimited while active.'**
  String get qs_profile_unlimited;

  /// No description provided for @qs_group_quota.
  ///
  /// In en, this message translates to:
  /// **'Quota'**
  String get qs_group_quota;

  /// No description provided for @qs_quota_on.
  ///
  /// In en, this message translates to:
  /// **'Limit the amount downloaded'**
  String get qs_quota_on;

  /// No description provided for @qs_quota_desc.
  ///
  /// In en, this message translates to:
  /// **'When the quota is used up the queue waits for the period to roll over.'**
  String get qs_quota_desc;

  /// No description provided for @qs_quota_bytes.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get qs_quota_bytes;

  /// No description provided for @qs_quota_period.
  ///
  /// In en, this message translates to:
  /// **'Per period'**
  String get qs_quota_period;

  /// No description provided for @qs_quota_period_placeholder.
  ///
  /// In en, this message translates to:
  /// **'For example 1 d'**
  String get qs_quota_period_placeholder;

  /// No description provided for @qs_invalid_duration.
  ///
  /// In en, this message translates to:
  /// **'Enter a time like 1h, 1d or 90m (at least a minute).'**
  String get qs_invalid_duration;

  /// No description provided for @qs_group_after.
  ///
  /// In en, this message translates to:
  /// **'When the queue finishes'**
  String get qs_group_after;

  /// No description provided for @qs_after.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get qs_after;

  /// No description provided for @qs_after_none.
  ///
  /// In en, this message translates to:
  /// **'Do nothing'**
  String get qs_after_none;

  /// No description provided for @qs_after_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop the queue'**
  String get qs_after_stop;

  /// No description provided for @qs_after_sleep.
  ///
  /// In en, this message translates to:
  /// **'Put the computer to sleep'**
  String get qs_after_sleep;

  /// No description provided for @qs_after_shutdown.
  ///
  /// In en, this message translates to:
  /// **'Shut the computer down'**
  String get qs_after_shutdown;

  /// No description provided for @qs_after_command.
  ///
  /// In en, this message translates to:
  /// **'Run a program'**
  String get qs_after_command;

  /// No description provided for @qs_after_delay.
  ///
  /// In en, this message translates to:
  /// **'Wait first'**
  String get qs_after_delay;

  /// No description provided for @qs_after_delay_desc.
  ///
  /// In en, this message translates to:
  /// **'A grace period in which you can cancel. Empty means 1 minute.'**
  String get qs_after_delay_desc;

  /// No description provided for @qs_after_command_path.
  ///
  /// In en, this message translates to:
  /// **'Program (full path)'**
  String get qs_after_command_path;

  /// No description provided for @qs_after_command_args.
  ///
  /// In en, this message translates to:
  /// **'Arguments, one per line'**
  String get qs_after_command_args;

  /// No description provided for @qs_after_command_warning.
  ///
  /// In en, this message translates to:
  /// **'This program runs with your permissions whenever the queue finishes. Only use one you trust.'**
  String get qs_after_command_warning;

  /// No description provided for @qs_invalid_path.
  ///
  /// In en, this message translates to:
  /// **'Enter the full path of the program.'**
  String get qs_invalid_path;

  /// No description provided for @qs_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get qs_cancel;

  /// No description provided for @queue_countdown_title.
  ///
  /// In en, this message translates to:
  /// **'“{name}” has finished'**
  String queue_countdown_title(String name);

  /// No description provided for @queue_countdown_message.
  ///
  /// In en, this message translates to:
  /// **'{action} in {time}.'**
  String queue_countdown_message(String action, String time);

  /// No description provided for @queue_countdown_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel and stop the queue'**
  String get queue_countdown_cancel;

  /// No description provided for @queue_action_cancelled.
  ///
  /// In en, this message translates to:
  /// **'The action after “{name}” was cancelled.'**
  String queue_action_cancelled(String name);

  /// No description provided for @qs_schedule_custom.
  ///
  /// In en, this message translates to:
  /// **'These hours include minutes, which the weekly grid cannot show. They are kept as they are until you replace them.'**
  String get qs_schedule_custom;

  /// No description provided for @qs_schedule_use_grid.
  ///
  /// In en, this message translates to:
  /// **'Use the hourly grid'**
  String get qs_schedule_use_grid;

  /// No description provided for @queue_missing_title.
  ///
  /// In en, this message translates to:
  /// **'This queue does not exist any more'**
  String get queue_missing_title;

  /// No description provided for @queue_missing_message.
  ///
  /// In en, this message translates to:
  /// **'It was deleted, perhaps from another window. Pick another one in the sidebar.'**
  String get queue_missing_message;

  /// No description provided for @setup_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get setup_title;

  /// No description provided for @setup_intro.
  ///
  /// In en, this message translates to:
  /// **'A quick look at where your downloads go and what the download service found on this computer. You can come back to this from the command palette.'**
  String get setup_intro;

  /// No description provided for @setup_folder_title.
  ///
  /// In en, this message translates to:
  /// **'Download folder'**
  String get setup_folder_title;

  /// No description provided for @setup_folder_desc.
  ///
  /// In en, this message translates to:
  /// **'New downloads are saved here unless a category or queue says otherwise.'**
  String get setup_folder_desc;

  /// No description provided for @setup_folder_choose.
  ///
  /// In en, this message translates to:
  /// **'Choose…'**
  String get setup_folder_choose;

  /// No description provided for @setup_folder_dialog.
  ///
  /// In en, this message translates to:
  /// **'Choose the download folder'**
  String get setup_folder_dialog;

  /// No description provided for @setup_folder_unset.
  ///
  /// In en, this message translates to:
  /// **'Not chosen yet'**
  String get setup_folder_unset;

  /// No description provided for @setup_folder_saved.
  ///
  /// In en, this message translates to:
  /// **'Downloads will be saved in {path}'**
  String setup_folder_saved(String path);

  /// No description provided for @setup_tools_title.
  ///
  /// In en, this message translates to:
  /// **'Helper programs'**
  String get setup_tools_title;

  /// No description provided for @setup_tools_desc.
  ///
  /// In en, this message translates to:
  /// **'These are used for some downloads. A missing one is only a problem when a download needs it.'**
  String get setup_tools_desc;

  /// No description provided for @setup_tools_recheck.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get setup_tools_recheck;

  /// No description provided for @setup_tools_loading.
  ///
  /// In en, this message translates to:
  /// **'Looking for helper programs…'**
  String get setup_tools_loading;

  /// No description provided for @setup_tool_ffmpeg.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg'**
  String get setup_tool_ffmpeg;

  /// No description provided for @setup_tool_ffmpeg_desc.
  ///
  /// In en, this message translates to:
  /// **'Joins video and audio and converts media.'**
  String get setup_tool_ffmpeg_desc;

  /// No description provided for @setup_tool_ytdlp.
  ///
  /// In en, this message translates to:
  /// **'yt-dlp'**
  String get setup_tool_ytdlp;

  /// No description provided for @setup_tool_ytdlp_desc.
  ///
  /// In en, this message translates to:
  /// **'Downloads from video sites.'**
  String get setup_tool_ytdlp_desc;

  /// No description provided for @setup_tool_browser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get setup_tool_browser;

  /// No description provided for @setup_tool_browser_desc.
  ///
  /// In en, this message translates to:
  /// **'Opens pages that only work in a real browser.'**
  String get setup_tool_browser_desc;

  /// No description provided for @setup_tool_found.
  ///
  /// In en, this message translates to:
  /// **'Found · {version}'**
  String setup_tool_found(String version);

  /// No description provided for @setup_tool_found_noversion.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get setup_tool_found_noversion;

  /// No description provided for @setup_tool_missing.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get setup_tool_missing;

  /// No description provided for @setup_tool_missing_auto.
  ///
  /// In en, this message translates to:
  /// **'Not found · installed automatically when needed'**
  String get setup_tool_missing_auto;

  /// No description provided for @setup_tool_error.
  ///
  /// In en, this message translates to:
  /// **'Problem: {error}'**
  String setup_tool_error(String error);

  /// No description provided for @setup_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get setup_done;

  /// No description provided for @cmd_setup.
  ///
  /// In en, this message translates to:
  /// **'Setup and health check…'**
  String get cmd_setup;

  /// No description provided for @insp_label.
  ///
  /// In en, this message translates to:
  /// **'Download details'**
  String get insp_label;

  /// No description provided for @insp_tab_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get insp_tab_overview;

  /// No description provided for @insp_tab_files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get insp_tab_files;

  /// No description provided for @insp_tab_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get insp_tab_speed;

  /// No description provided for @insp_tab_source.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get insp_tab_source;

  /// No description provided for @insp_multi.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 download selected} other{{count} downloads selected}}'**
  String insp_multi(int count);

  /// No description provided for @insp_multi_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a single download to see its details.'**
  String get insp_multi_hint;

  /// No description provided for @insp_gone.
  ///
  /// In en, this message translates to:
  /// **'This download no longer exists.'**
  String get insp_gone;

  /// No description provided for @ov_group_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get ov_group_progress;

  /// No description provided for @ov_group_where.
  ///
  /// In en, this message translates to:
  /// **'Where it goes'**
  String get ov_group_where;

  /// No description provided for @ov_group_times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get ov_group_times;

  /// No description provided for @ov_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ov_status;

  /// No description provided for @ov_progress.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ov_progress;

  /// No description provided for @ov_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get ov_size;

  /// No description provided for @ov_size_unknown.
  ///
  /// In en, this message translates to:
  /// **'Not known yet'**
  String get ov_size_unknown;

  /// No description provided for @ov_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get ov_downloaded;

  /// No description provided for @ov_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get ov_speed;

  /// No description provided for @ov_time_left.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get ov_time_left;

  /// No description provided for @ov_connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get ov_connections;

  /// No description provided for @ov_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get ov_queue;

  /// No description provided for @ov_engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get ov_engine;

  /// No description provided for @ov_folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get ov_folder;

  /// No description provided for @ov_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get ov_priority;

  /// No description provided for @ov_labels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get ov_labels;

  /// No description provided for @ov_added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get ov_added;

  /// No description provided for @ov_started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get ov_started;

  /// No description provided for @ov_completed.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get ov_completed;

  /// No description provided for @ov_none.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get ov_none;

  /// No description provided for @ov_priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get ov_priority_low;

  /// No description provided for @ov_priority_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get ov_priority_normal;

  /// No description provided for @ov_priority_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get ov_priority_high;

  /// No description provided for @ov_error_title.
  ///
  /// In en, this message translates to:
  /// **'It stopped with an error'**
  String get ov_error_title;

  /// No description provided for @ov_error_detail.
  ///
  /// In en, this message translates to:
  /// **'{message} ({code})'**
  String ov_error_detail(String message, String code);

  /// No description provided for @ov_error_when.
  ///
  /// In en, this message translates to:
  /// **'{when}'**
  String ov_error_when(String when);

  /// No description provided for @ov_error_retryable.
  ///
  /// In en, this message translates to:
  /// **'Trying again may work.'**
  String get ov_error_retryable;

  /// No description provided for @ov_error_final.
  ///
  /// In en, this message translates to:
  /// **'Trying again will not help until something changes.'**
  String get ov_error_final;

  /// No description provided for @files_tree_label.
  ///
  /// In en, this message translates to:
  /// **'Files of this download'**
  String get files_tree_label;

  /// No description provided for @files_single.
  ///
  /// In en, this message translates to:
  /// **'This download is a single file.'**
  String get files_single;

  /// No description provided for @files_count.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} files selected'**
  String files_count(int selected, int total);

  /// No description provided for @files_none_selected.
  ///
  /// In en, this message translates to:
  /// **'No files are selected for download.'**
  String get files_none_selected;

  /// No description provided for @speed_title.
  ///
  /// In en, this message translates to:
  /// **'Download speed'**
  String get speed_title;

  /// No description provided for @speed_summary.
  ///
  /// In en, this message translates to:
  /// **'Now {current}, highest {peak} over the last {seconds} seconds.'**
  String speed_summary(String current, String peak, int seconds);

  /// No description provided for @speed_waiting.
  ///
  /// In en, this message translates to:
  /// **'The graph fills in while the download runs.'**
  String get speed_waiting;

  /// No description provided for @speed_series.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed_series;

  /// No description provided for @src_group_link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get src_group_link;

  /// No description provided for @src_group_history.
  ///
  /// In en, this message translates to:
  /// **'Link renewals'**
  String get src_group_history;

  /// No description provided for @src_current.
  ///
  /// In en, this message translates to:
  /// **'Current link'**
  String get src_current;

  /// No description provided for @src_original.
  ///
  /// In en, this message translates to:
  /// **'First link'**
  String get src_original;

  /// No description provided for @src_page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get src_page;

  /// No description provided for @src_referrer.
  ///
  /// In en, this message translates to:
  /// **'Referrer'**
  String get src_referrer;

  /// No description provided for @src_mirrors.
  ///
  /// In en, this message translates to:
  /// **'Mirrors'**
  String get src_mirrors;

  /// No description provided for @src_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get src_copy;

  /// No description provided for @src_refresh.
  ///
  /// In en, this message translates to:
  /// **'Renew link now'**
  String get src_refresh;

  /// No description provided for @src_await.
  ///
  /// In en, this message translates to:
  /// **'Wait for a new link'**
  String get src_await;

  /// No description provided for @src_edit.
  ///
  /// In en, this message translates to:
  /// **'Replace link…'**
  String get src_edit;

  /// No description provided for @src_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Replace the link'**
  String get src_edit_title;

  /// No description provided for @src_edit_label.
  ///
  /// In en, this message translates to:
  /// **'New link'**
  String get src_edit_label;

  /// No description provided for @src_edit_hint.
  ///
  /// In en, this message translates to:
  /// **'The daemon checks it against the file. If it is not the same file, the download starts again.'**
  String get src_edit_hint;

  /// No description provided for @src_edit_needs_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause the download first to replace its link.'**
  String get src_edit_needs_pause;

  /// No description provided for @src_edit_save.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get src_edit_save;

  /// No description provided for @src_history_empty.
  ///
  /// In en, this message translates to:
  /// **'The link has not needed renewing.'**
  String get src_history_empty;

  /// No description provided for @src_attempt.
  ///
  /// In en, this message translates to:
  /// **'{strategy} · {outcome}'**
  String src_attempt(String strategy, String outcome);

  /// No description provided for @src_attempt_cause.
  ///
  /// In en, this message translates to:
  /// **'Cause: {cause}'**
  String src_attempt_cause(String cause);

  /// No description provided for @toast_link_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Asking for a new link'**
  String get toast_link_refreshing;

  /// No description provided for @toast_link_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a new link'**
  String get toast_link_waiting;

  /// No description provided for @toast_link_replaced.
  ///
  /// In en, this message translates to:
  /// **'Link replaced'**
  String get toast_link_replaced;

  /// No description provided for @files_skipped.
  ///
  /// In en, this message translates to:
  /// **'not downloaded'**
  String get files_skipped;

  /// No description provided for @insp_tab_segments.
  ///
  /// In en, this message translates to:
  /// **'Segments'**
  String get insp_tab_segments;

  /// No description provided for @insp_tab_torrent.
  ///
  /// In en, this message translates to:
  /// **'Torrent'**
  String get insp_tab_torrent;

  /// No description provided for @seg_none.
  ///
  /// In en, this message translates to:
  /// **'This download is not split into segments.'**
  String get seg_none;

  /// No description provided for @seg_summary.
  ///
  /// In en, this message translates to:
  /// **'{count} segments, {percent}% done.'**
  String seg_summary(int count, int percent);

  /// No description provided for @seg_label.
  ///
  /// In en, this message translates to:
  /// **'Map of the segments of the download'**
  String get seg_label;

  /// No description provided for @seg_done.
  ///
  /// In en, this message translates to:
  /// **'downloaded'**
  String get seg_done;

  /// No description provided for @seg_todo.
  ///
  /// In en, this message translates to:
  /// **'still to do'**
  String get seg_todo;

  /// No description provided for @torrent_none.
  ///
  /// In en, this message translates to:
  /// **'There is no swarm to show yet: the torrent has not started.'**
  String get torrent_none;

  /// No description provided for @torrent_state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get torrent_state;

  /// No description provided for @torrent_hash.
  ///
  /// In en, this message translates to:
  /// **'Info hash'**
  String get torrent_hash;

  /// No description provided for @torrent_private.
  ///
  /// In en, this message translates to:
  /// **'Private torrent'**
  String get torrent_private;

  /// No description provided for @torrent_yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get torrent_yes;

  /// No description provided for @torrent_no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get torrent_no;

  /// No description provided for @torrent_peers.
  ///
  /// In en, this message translates to:
  /// **'Peers'**
  String get torrent_peers;

  /// No description provided for @torrent_peers_value.
  ///
  /// In en, this message translates to:
  /// **'{connected} connected, {known} known, {seeders} seeders'**
  String torrent_peers_value(int connected, int known, int seeders);

  /// No description provided for @torrent_shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get torrent_shared;

  /// No description provided for @torrent_shared_value.
  ///
  /// In en, this message translates to:
  /// **'{uploaded} uploaded, ratio {ratio}'**
  String torrent_shared_value(String uploaded, String ratio);

  /// No description provided for @torrent_seeding_time.
  ///
  /// In en, this message translates to:
  /// **'Seeding for'**
  String get torrent_seeding_time;

  /// No description provided for @torrent_trackers.
  ///
  /// In en, this message translates to:
  /// **'Trackers'**
  String get torrent_trackers;

  /// No description provided for @torrent_peer_list.
  ///
  /// In en, this message translates to:
  /// **'Connected peers'**
  String get torrent_peer_list;

  /// No description provided for @torrent_peer_rate.
  ///
  /// In en, this message translates to:
  /// **'{rate} down'**
  String torrent_peer_rate(String rate);

  /// No description provided for @files_edit.
  ///
  /// In en, this message translates to:
  /// **'Choose files'**
  String get files_edit;

  /// No description provided for @files_save.
  ///
  /// In en, this message translates to:
  /// **'Save selection'**
  String get files_save;

  /// No description provided for @files_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get files_cancel;

  /// No description provided for @files_locked.
  ///
  /// In en, this message translates to:
  /// **'Pause the download to change which files are downloaded.'**
  String get files_locked;

  /// No description provided for @files_select_all.
  ///
  /// In en, this message translates to:
  /// **'All files'**
  String get files_select_all;

  /// No description provided for @files_pick_one.
  ///
  /// In en, this message translates to:
  /// **'Select at least one file.'**
  String get files_pick_one;

  /// No description provided for @toast_files_saved.
  ///
  /// In en, this message translates to:
  /// **'Selection saved'**
  String get toast_files_saved;

  /// No description provided for @files_file_label.
  ///
  /// In en, this message translates to:
  /// **'Download {name}'**
  String files_file_label(String name);

  /// No description provided for @add_title.
  ///
  /// In en, this message translates to:
  /// **'Add downloads'**
  String get add_title;

  /// No description provided for @add_button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_button;

  /// No description provided for @add_links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get add_links;

  /// No description provided for @add_links_placeholder.
  ///
  /// In en, this message translates to:
  /// **'One link per line: web addresses, magnet links, or a pattern like http://host/img[1-20].jpg'**
  String get add_links_placeholder;

  /// No description provided for @add_looking.
  ///
  /// In en, this message translates to:
  /// **'Looking at the link…'**
  String get add_looking;

  /// No description provided for @add_files.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String add_files(int count);

  /// No description provided for @add_many.
  ///
  /// In en, this message translates to:
  /// **'{count} downloads'**
  String add_many(int count);

  /// No description provided for @add_more.
  ///
  /// In en, this message translates to:
  /// **'and more…'**
  String get add_more;

  /// No description provided for @add_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Already in the list: {name}'**
  String add_duplicate(String name);

  /// No description provided for @add_anyway.
  ///
  /// In en, this message translates to:
  /// **'Add it anyway'**
  String get add_anyway;

  /// No description provided for @add_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get add_queue;

  /// No description provided for @add_folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get add_folder;

  /// No description provided for @add_folder_default.
  ///
  /// In en, this message translates to:
  /// **'The default download folder'**
  String get add_folder_default;

  /// No description provided for @add_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get add_name;

  /// No description provided for @add_name_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Taken from the link'**
  String get add_name_placeholder;

  /// No description provided for @add_paused.
  ///
  /// In en, this message translates to:
  /// **'Add without starting'**
  String get add_paused;

  /// No description provided for @add_done_one.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String add_done_one(String name);

  /// No description provided for @add_done_many.
  ///
  /// In en, this message translates to:
  /// **'Added {count} downloads'**
  String add_done_many(int count);

  /// No description provided for @cmd_add.
  ///
  /// In en, this message translates to:
  /// **'Add downloads…'**
  String get cmd_add;

  /// No description provided for @toolbar_add.
  ///
  /// In en, this message translates to:
  /// **'Add downloads'**
  String get toolbar_add;

  /// No description provided for @view_menu.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view_menu;

  /// No description provided for @view_engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get view_engine;

  /// No description provided for @view_all_engines.
  ///
  /// In en, this message translates to:
  /// **'All engines'**
  String get view_all_engines;

  /// No description provided for @view_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved views'**
  String get view_saved;

  /// No description provided for @view_save.
  ///
  /// In en, this message translates to:
  /// **'Save current view…'**
  String get view_save;

  /// No description provided for @view_save_title.
  ///
  /// In en, this message translates to:
  /// **'Save this view'**
  String get view_save_title;

  /// No description provided for @view_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete view {name}'**
  String view_delete(String name);

  /// No description provided for @col_engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get col_engine;

  /// No description provided for @list_total.
  ///
  /// In en, this message translates to:
  /// **'{count} downloads'**
  String list_total(int count);

  /// No description provided for @action_refresh_link.
  ///
  /// In en, this message translates to:
  /// **'Get a new link'**
  String get action_refresh_link;

  /// No description provided for @action_move_to.
  ///
  /// In en, this message translates to:
  /// **'Move to queue'**
  String get action_move_to;

  /// No description provided for @action_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get action_priority;

  /// No description provided for @priority_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priority_high;

  /// No description provided for @priority_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priority_normal;

  /// No description provided for @priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priority_low;

  /// No description provided for @toast_moved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Moved 1 download to {queue}} other{Moved {count} downloads to {queue}}}'**
  String toast_moved(int count, String queue);

  /// No description provided for @toast_prioritised.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Priority changed for 1 download} other{Priority changed for {count} downloads}}'**
  String toast_prioritised(int count);

  /// No description provided for @toast_restarted_many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Restarting 1 download} other{Restarting {count} downloads}}'**
  String toast_restarted_many(int count);

  /// No description provided for @toast_refreshing_many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Asking for a new link for 1 download} other{Asking for new links for {count} downloads}}'**
  String toast_refreshing_many(int count);

  /// No description provided for @status_label.
  ///
  /// In en, this message translates to:
  /// **'Status bar'**
  String get status_label;

  /// No description provided for @status_reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get status_reconnecting;

  /// No description provided for @status_speed.
  ///
  /// In en, this message translates to:
  /// **'↓ {down}  ↑ {up}'**
  String status_speed(String down, String up);

  /// No description provided for @status_counts.
  ///
  /// In en, this message translates to:
  /// **'{active} active, {queued} waiting'**
  String status_counts(int active, int queued);

  /// No description provided for @status_quota.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total}'**
  String status_quota(String used, String total);

  /// No description provided for @status_quota_label.
  ///
  /// In en, this message translates to:
  /// **'Quota used'**
  String get status_quota_label;

  /// No description provided for @status_turbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get status_turbo;

  /// No description provided for @status_turbo_on.
  ///
  /// In en, this message translates to:
  /// **'Turbo on'**
  String get status_turbo_on;

  /// No description provided for @status_pause_all.
  ///
  /// In en, this message translates to:
  /// **'Pause all'**
  String get status_pause_all;

  /// No description provided for @status_resume_all.
  ///
  /// In en, this message translates to:
  /// **'Resume all'**
  String get status_resume_all;

  /// No description provided for @add_import.
  ///
  /// In en, this message translates to:
  /// **'Import list…'**
  String get add_import;

  /// No description provided for @add_import_title.
  ///
  /// In en, this message translates to:
  /// **'Import {name}'**
  String add_import_title(String name);

  /// No description provided for @add_import_go.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Add 1 download} other{Add {count} downloads}}'**
  String add_import_go(int count);

  /// No description provided for @add_results_title.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get add_results_title;

  /// No description provided for @add_results_summary.
  ///
  /// In en, this message translates to:
  /// **'{ok} added, {failed} not added.'**
  String add_results_summary(int ok, int failed);

  /// No description provided for @add_result_ok.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get add_result_ok;

  /// No description provided for @add_result_failed.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get add_result_failed;

  /// No description provided for @add_result_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Already in the list'**
  String get add_result_duplicate;

  /// No description provided for @add_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get add_close;

  /// No description provided for @add_folder_browse.
  ///
  /// In en, this message translates to:
  /// **'Browse folders'**
  String get add_folder_browse;

  /// No description provided for @folder_browser_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder'**
  String get folder_browser_title;

  /// No description provided for @folder_browser_roots.
  ///
  /// In en, this message translates to:
  /// **'Places you can choose from'**
  String get folder_browser_roots;

  /// No description provided for @folder_browser_empty.
  ///
  /// In en, this message translates to:
  /// **'No folders here.'**
  String get folder_browser_empty;

  /// No description provided for @folder_browser_choose.
  ///
  /// In en, this message translates to:
  /// **'Choose this folder'**
  String get folder_browser_choose;

  /// No description provided for @folder_browser_error.
  ///
  /// In en, this message translates to:
  /// **'The folders could not be listed.'**
  String get folder_browser_error;

  /// No description provided for @add_advanced.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get add_advanced;

  /// No description provided for @add_mode.
  ///
  /// In en, this message translates to:
  /// **'Treat the link as'**
  String get add_mode;

  /// No description provided for @add_mode_auto.
  ///
  /// In en, this message translates to:
  /// **'Let the app decide'**
  String get add_mode_auto;

  /// No description provided for @add_mode_direct.
  ///
  /// In en, this message translates to:
  /// **'A file'**
  String get add_mode_direct;

  /// No description provided for @add_mode_ytdlp.
  ///
  /// In en, this message translates to:
  /// **'A video or audio page (yt-dlp)'**
  String get add_mode_ytdlp;

  /// No description provided for @add_mode_browser.
  ///
  /// In en, this message translates to:
  /// **'A page that needs a browser'**
  String get add_mode_browser;

  /// No description provided for @add_referrer.
  ///
  /// In en, this message translates to:
  /// **'Referrer'**
  String get add_referrer;

  /// No description provided for @add_headers.
  ///
  /// In en, this message translates to:
  /// **'Headers'**
  String get add_headers;

  /// No description provided for @add_headers_hint.
  ///
  /// In en, this message translates to:
  /// **'One per line, like Name: value'**
  String get add_headers_hint;

  /// No description provided for @add_headers_invalid.
  ///
  /// In en, this message translates to:
  /// **'Every line needs a name, a colon and a value.'**
  String get add_headers_invalid;

  /// No description provided for @add_mirrors.
  ///
  /// In en, this message translates to:
  /// **'Mirrors'**
  String get add_mirrors;

  /// No description provided for @add_mirrors_hint.
  ///
  /// In en, this message translates to:
  /// **'Other places with the same file, one link per line'**
  String get add_mirrors_hint;

  /// No description provided for @add_checksum.
  ///
  /// In en, this message translates to:
  /// **'Checksum'**
  String get add_checksum;

  /// No description provided for @add_checksum_algorithm.
  ///
  /// In en, this message translates to:
  /// **'Checksum algorithm'**
  String get add_checksum_algorithm;

  /// No description provided for @add_checksum_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Expected value in hex'**
  String get add_checksum_placeholder;

  /// No description provided for @add_checksum_invalid.
  ///
  /// In en, this message translates to:
  /// **'Not a valid value for this algorithm.'**
  String get add_checksum_invalid;

  /// No description provided for @add_torrent.
  ///
  /// In en, this message translates to:
  /// **'Torrent file…'**
  String get add_torrent;

  /// No description provided for @add_torrent_too_big.
  ///
  /// In en, this message translates to:
  /// **'That torrent file is too large (16 MiB at most).'**
  String get add_torrent_too_big;

  /// No description provided for @add_torrent_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String add_torrent_remove(String name);

  /// No description provided for @nav_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nav_categories;

  /// No description provided for @drag_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 download} other{{count} downloads}}'**
  String drag_count(int count);

  /// No description provided for @view_density.
  ///
  /// In en, this message translates to:
  /// **'Row height'**
  String get view_density;

  /// No description provided for @view_density_comfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get view_density_comfortable;

  /// No description provided for @view_density_compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get view_density_compact;

  /// No description provided for @view_columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get view_columns;

  /// No description provided for @display_menu.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display_menu;

  /// No description provided for @settings_search.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settings_search;

  /// No description provided for @settings_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settings_save;

  /// No description provided for @settings_revert.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get settings_revert;

  /// No description provided for @settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settings_saved;

  /// No description provided for @settings_unsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get settings_unsaved;

  /// No description provided for @settings_no_match.
  ///
  /// In en, this message translates to:
  /// **'No setting matches your search.'**
  String get settings_no_match;

  /// No description provided for @settings_changed_elsewhere.
  ///
  /// In en, this message translates to:
  /// **'The settings were changed somewhere else. Their version is shown now; make your changes again.'**
  String get settings_changed_elsewhere;

  /// No description provided for @settings_level_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settings_level_default;

  /// No description provided for @settings_level_global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get settings_level_global;

  /// No description provided for @settings_level_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get settings_level_queue;

  /// No description provided for @settings_level_task.
  ///
  /// In en, this message translates to:
  /// **'This download'**
  String get settings_level_task;

  /// No description provided for @settings_restart.
  ///
  /// In en, this message translates to:
  /// **'Needs restart'**
  String get settings_restart;

  /// No description provided for @settings_unset.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settings_unset;

  /// No description provided for @settings_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset {name} to the inherited value'**
  String settings_reset(String name);

  /// No description provided for @settings_invalid_size.
  ///
  /// In en, this message translates to:
  /// **'Not a size, such as 10 MB or 512 K.'**
  String get settings_invalid_size;

  /// No description provided for @settings_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Not a number in the allowed range.'**
  String get settings_invalid_number;

  /// No description provided for @settings_invalid_duration.
  ///
  /// In en, this message translates to:
  /// **'Use a duration like 30s, 5m or 1h30m.'**
  String get settings_invalid_duration;

  /// No description provided for @settings_leave_title.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get settings_leave_title;

  /// No description provided for @settings_leave_message.
  ///
  /// In en, this message translates to:
  /// **'You changed settings that are not saved yet.'**
  String get settings_leave_message;

  /// No description provided for @settings_leave_confirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get settings_leave_confirm;

  /// No description provided for @settings_leave_stay.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get settings_leave_stay;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @insp_tab_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get insp_tab_settings;

  /// No description provided for @se_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get se_name;

  /// No description provided for @se_value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get se_value;

  /// No description provided for @se_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get se_remove;

  /// No description provided for @se_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get se_add;

  /// No description provided for @se_add_rule.
  ///
  /// In en, this message translates to:
  /// **'Add a rule'**
  String get se_add_rule;

  /// No description provided for @se_proxy_mode.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get se_proxy_mode;

  /// No description provided for @se_proxy_none.
  ///
  /// In en, this message translates to:
  /// **'No proxy'**
  String get se_proxy_none;

  /// No description provided for @se_proxy_system.
  ///
  /// In en, this message translates to:
  /// **'The system\'s proxy'**
  String get se_proxy_system;

  /// No description provided for @se_proxy_custom.
  ///
  /// In en, this message translates to:
  /// **'A proxy I choose'**
  String get se_proxy_custom;

  /// No description provided for @se_proxy_url.
  ///
  /// In en, this message translates to:
  /// **'Proxy address'**
  String get se_proxy_url;

  /// No description provided for @se_rule_hosts.
  ///
  /// In en, this message translates to:
  /// **'Hosts'**
  String get se_rule_hosts;

  /// No description provided for @se_rule_hosts_hint.
  ///
  /// In en, this message translates to:
  /// **'example.com, *.cdn.net'**
  String get se_rule_hosts_hint;

  /// No description provided for @se_lines.
  ///
  /// In en, this message translates to:
  /// **'One entry per line'**
  String get se_lines;

  /// No description provided for @se_move_up.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get se_move_up;

  /// No description provided for @se_move_down.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get se_move_down;

  /// No description provided for @se_pa_add.
  ///
  /// In en, this message translates to:
  /// **'Add an action'**
  String get se_pa_add;

  /// No description provided for @se_pa_extract.
  ///
  /// In en, this message translates to:
  /// **'Unpack archives'**
  String get se_pa_extract;

  /// No description provided for @se_pa_add_torrent.
  ///
  /// In en, this message translates to:
  /// **'Add a downloaded .torrent file'**
  String get se_pa_add_torrent;

  /// No description provided for @se_pa_command.
  ///
  /// In en, this message translates to:
  /// **'Run a program'**
  String get se_pa_command;

  /// No description provided for @se_pa_av_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan for viruses'**
  String get se_pa_av_scan;

  /// No description provided for @se_pa_dir.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get se_pa_dir;

  /// No description provided for @se_pa_dir_hint.
  ///
  /// In en, this message translates to:
  /// **'Next to the file'**
  String get se_pa_dir_hint;

  /// No description provided for @se_pa_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete the file afterwards'**
  String get se_pa_delete;

  /// No description provided for @se_pa_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get se_pa_password;

  /// No description provided for @se_pa_cmd.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get se_pa_cmd;

  /// No description provided for @se_pa_cmd_hint.
  ///
  /// In en, this message translates to:
  /// **'Full path, e.g. /usr/bin/clamscan'**
  String get se_pa_cmd_hint;

  /// No description provided for @se_pa_args.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get se_pa_args;

  /// No description provided for @se_pa_args_hint.
  ///
  /// In en, this message translates to:
  /// **'One per line; {token} is the file'**
  String se_pa_args_hint(String token);

  /// No description provided for @se_pa_timeout.
  ///
  /// In en, this message translates to:
  /// **'Time limit'**
  String get se_pa_timeout;

  /// No description provided for @se_pa_infected_exit.
  ///
  /// In en, this message translates to:
  /// **'Infected exit code'**
  String get se_pa_infected_exit;

  /// No description provided for @se_pa_on_infected.
  ///
  /// In en, this message translates to:
  /// **'When infected'**
  String get se_pa_on_infected;

  /// No description provided for @se_pa_infected_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete the file'**
  String get se_pa_infected_delete;

  /// No description provided for @se_pa_infected_keep.
  ///
  /// In en, this message translates to:
  /// **'Keep the file'**
  String get se_pa_infected_keep;

  /// No description provided for @se_pa_command_warning.
  ///
  /// In en, this message translates to:
  /// **'This runs a program on every finished download. Only use a program you trust.'**
  String get se_pa_command_warning;

  /// No description provided for @se_pa_av_warning.
  ///
  /// In en, this message translates to:
  /// **'An infected file fails the download and, unless you keep it, is deleted. Only use a scanner you trust.'**
  String get se_pa_av_warning;

  /// No description provided for @se_quota_bytes.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get se_quota_bytes;

  /// No description provided for @se_quota_per.
  ///
  /// In en, this message translates to:
  /// **'per'**
  String get se_quota_per;

  /// No description provided for @se_quota_period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get se_quota_period;

  /// No description provided for @nav_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get nav_manage;

  /// No description provided for @nav_manage_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nav_manage_categories;

  /// No description provided for @cat_intro.
  ///
  /// In en, this message translates to:
  /// **'A category sorts a finished download into a folder by its file extension or content type. The first category that matches wins, so the order matters.'**
  String get cat_intro;

  /// No description provided for @cat_add.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get cat_add;

  /// No description provided for @cat_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get cat_add_title;

  /// No description provided for @cat_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit the category'**
  String get cat_edit_title;

  /// No description provided for @cat_saved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get cat_saved;

  /// No description provided for @cat_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get cat_empty_title;

  /// No description provided for @cat_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Add one to have finished downloads sorted into folders.'**
  String get cat_empty_message;

  /// No description provided for @cat_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cat_name;

  /// No description provided for @cat_folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get cat_folder;

  /// No description provided for @cat_folder_desc.
  ///
  /// In en, this message translates to:
  /// **'Where files of this category are put.'**
  String get cat_folder_desc;

  /// No description provided for @cat_extensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get cat_extensions;

  /// No description provided for @cat_extensions_desc.
  ///
  /// In en, this message translates to:
  /// **'Separated by commas or spaces, like mkv, mp4.'**
  String get cat_extensions_desc;

  /// No description provided for @cat_extensions_invalid.
  ///
  /// In en, this message translates to:
  /// **'Extensions are letters and digits only.'**
  String get cat_extensions_invalid;

  /// No description provided for @cat_mime.
  ///
  /// In en, this message translates to:
  /// **'Content types'**
  String get cat_mime;

  /// No description provided for @cat_mime_desc.
  ///
  /// In en, this message translates to:
  /// **'One per line, like video/* or application/pdf.'**
  String get cat_mime_desc;

  /// No description provided for @cat_mime_invalid.
  ///
  /// In en, this message translates to:
  /// **'Use the form type/subtype, or type/*.'**
  String get cat_mime_invalid;

  /// No description provided for @cat_drag.
  ///
  /// In en, this message translates to:
  /// **'Drag {name} to change its order'**
  String cat_drag(String name);

  /// No description provided for @cat_move_up.
  ///
  /// In en, this message translates to:
  /// **'Move {name} up'**
  String cat_move_up(String name);

  /// No description provided for @cat_move_down.
  ///
  /// In en, this message translates to:
  /// **'Move {name} down'**
  String cat_move_down(String name);

  /// No description provided for @cat_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String cat_edit(String name);

  /// No description provided for @cat_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String cat_delete(String name);

  /// No description provided for @cat_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete the category {name}?'**
  String cat_delete_title(String name);

  /// No description provided for @cat_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Files already sorted by it stay where they are.'**
  String get cat_delete_message;

  /// No description provided for @cat_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get cat_delete_confirm;

  /// No description provided for @cat_test_title.
  ///
  /// In en, this message translates to:
  /// **'Try a file'**
  String get cat_test_title;

  /// No description provided for @cat_test_name.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get cat_test_name;

  /// No description provided for @cat_test_mime.
  ///
  /// In en, this message translates to:
  /// **'Content type'**
  String get cat_test_mime;

  /// No description provided for @cat_test_none.
  ///
  /// In en, this message translates to:
  /// **'No category matches: the file stays in the normal download folder.'**
  String get cat_test_none;

  /// No description provided for @cat_test_found.
  ///
  /// In en, this message translates to:
  /// **'Goes to {name}: {dir}'**
  String cat_test_found(String name, String dir);

  /// No description provided for @cat_test_error.
  ///
  /// In en, this message translates to:
  /// **'The daemon could not be asked.'**
  String get cat_test_error;

  /// No description provided for @nav_manage_logins.
  ///
  /// In en, this message translates to:
  /// **'Logins'**
  String get nav_manage_logins;

  /// No description provided for @nav_manage_cookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get nav_manage_cookies;

  /// No description provided for @field_show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get field_show;

  /// No description provided for @field_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get field_hide;

  /// No description provided for @login_intro.
  ///
  /// In en, this message translates to:
  /// **'Logins are sent to sites that ask for a user name and password. The password stays in the download service: it is never shown here again.'**
  String get login_intro;

  /// No description provided for @login_add.
  ///
  /// In en, this message translates to:
  /// **'Add a login'**
  String get login_add;

  /// No description provided for @login_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add a login'**
  String get login_add_title;

  /// No description provided for @login_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit the login'**
  String get login_edit_title;

  /// No description provided for @login_saved.
  ///
  /// In en, this message translates to:
  /// **'Login saved'**
  String get login_saved;

  /// No description provided for @login_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No logins yet'**
  String get login_empty_title;

  /// No description provided for @login_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Add one for a site that needs a user name and password.'**
  String get login_empty_message;

  /// No description provided for @login_host.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get login_host;

  /// No description provided for @login_host_desc.
  ///
  /// In en, this message translates to:
  /// **'A host name like example.com, or *.example.com for all its subdomains.'**
  String get login_host_desc;

  /// No description provided for @login_user.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get login_user;

  /// No description provided for @login_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password;

  /// No description provided for @login_password_keep.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the stored password.'**
  String get login_password_keep;

  /// No description provided for @login_scheme.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get login_scheme;

  /// No description provided for @login_scheme_auto.
  ///
  /// In en, this message translates to:
  /// **'Let the site decide'**
  String get login_scheme_auto;

  /// No description provided for @login_scheme_basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get login_scheme_basic;

  /// No description provided for @login_scheme_digest.
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get login_scheme_digest;

  /// No description provided for @login_updated.
  ///
  /// In en, this message translates to:
  /// **'changed {date}'**
  String login_updated(String date);

  /// No description provided for @login_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit the login for {host}'**
  String login_edit(String host);

  /// No description provided for @login_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete the login for {host}'**
  String login_delete(String host);

  /// No description provided for @login_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete the login for {host}?'**
  String login_delete_title(String host);

  /// No description provided for @login_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Downloads from that site will no longer sign in.'**
  String get login_delete_message;

  /// No description provided for @login_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete login'**
  String get login_delete_confirm;

  /// No description provided for @ck_intro.
  ///
  /// In en, this message translates to:
  /// **'Cookies keep you signed in to sites. Their values stay in the download service; an export is the only way to see them.'**
  String get ck_intro;

  /// No description provided for @ck_import.
  ///
  /// In en, this message translates to:
  /// **'Import cookies…'**
  String get ck_import;

  /// No description provided for @ck_export.
  ///
  /// In en, this message translates to:
  /// **'Export all…'**
  String get ck_export;

  /// No description provided for @ck_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No cookies stored'**
  String get ck_empty_title;

  /// No description provided for @ck_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Import a cookies file, or let the browser extension send them.'**
  String get ck_empty_message;

  /// No description provided for @ck_tree_label.
  ///
  /// In en, this message translates to:
  /// **'Cookies by domain'**
  String get ck_tree_label;

  /// No description provided for @ck_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 cookie} other{{count} cookies}}'**
  String ck_count(int count);

  /// No description provided for @ck_secure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get ck_secure;

  /// No description provided for @ck_http_only.
  ///
  /// In en, this message translates to:
  /// **'HTTP only'**
  String get ck_http_only;

  /// No description provided for @ck_session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get ck_session;

  /// No description provided for @ck_export_domain.
  ///
  /// In en, this message translates to:
  /// **'Export the cookies of {domain}'**
  String ck_export_domain(String domain);

  /// No description provided for @ck_delete_domain.
  ///
  /// In en, this message translates to:
  /// **'Delete the cookies of {domain}'**
  String ck_delete_domain(String domain);

  /// No description provided for @ck_delete_cookie.
  ///
  /// In en, this message translates to:
  /// **'Delete the cookie {name}'**
  String ck_delete_cookie(String name);

  /// No description provided for @ck_delete_domain_title.
  ///
  /// In en, this message translates to:
  /// **'Delete the cookies of {domain}?'**
  String ck_delete_domain_title(String domain);

  /// No description provided for @ck_delete_domain_message.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 cookie will be deleted.} other{{count} cookies will be deleted.}}'**
  String ck_delete_domain_message(int count);

  /// No description provided for @ck_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete cookies'**
  String get ck_delete_confirm;

  /// No description provided for @ck_import_title.
  ///
  /// In en, this message translates to:
  /// **'Import {name}'**
  String ck_import_title(String name);

  /// No description provided for @ck_import_summary.
  ///
  /// In en, this message translates to:
  /// **'{imported} imported, {skipped} skipped.'**
  String ck_import_summary(int imported, int skipped);

  /// No description provided for @ck_export_title.
  ///
  /// In en, this message translates to:
  /// **'Export cookies'**
  String get ck_export_title;

  /// No description provided for @ck_export_all.
  ///
  /// In en, this message translates to:
  /// **'All stored cookies.'**
  String get ck_export_all;

  /// No description provided for @ck_export_one.
  ///
  /// In en, this message translates to:
  /// **'The cookies of {domain}.'**
  String ck_export_one(String domain);

  /// No description provided for @ck_format.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get ck_format;

  /// No description provided for @ck_format_netscape.
  ///
  /// In en, this message translates to:
  /// **'Netscape cookies.txt'**
  String get ck_format_netscape;

  /// No description provided for @ck_format_json.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get ck_format_json;

  /// No description provided for @ck_export_warning.
  ///
  /// In en, this message translates to:
  /// **'The export contains the cookie values. Anyone who has them can sign in as you. Reveal them only where you can keep them safe.'**
  String get ck_export_warning;

  /// No description provided for @ck_reveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal the cookies'**
  String get ck_reveal;

  /// No description provided for @ck_export_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 cookie} other{{count} cookies}}'**
  String ck_export_count(int count);

  /// No description provided for @ck_export_text.
  ///
  /// In en, this message translates to:
  /// **'The exported cookies'**
  String get ck_export_text;

  /// No description provided for @ck_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get ck_copy;

  /// No description provided for @ck_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get ck_copied;

  /// No description provided for @ck_save.
  ///
  /// In en, this message translates to:
  /// **'Save to a file…'**
  String get ck_save;

  /// No description provided for @ck_saved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get ck_saved;

  /// No description provided for @nav_manage_webhooks.
  ///
  /// In en, this message translates to:
  /// **'Webhooks'**
  String get nav_manage_webhooks;

  /// No description provided for @wh_intro.
  ///
  /// In en, this message translates to:
  /// **'A webhook is an address that is sent the daemon\'s events as they happen, for example when a download finishes.'**
  String get wh_intro;

  /// No description provided for @wh_add.
  ///
  /// In en, this message translates to:
  /// **'Add a webhook'**
  String get wh_add;

  /// No description provided for @wh_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add a webhook'**
  String get wh_add_title;

  /// No description provided for @wh_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit the webhook'**
  String get wh_edit_title;

  /// No description provided for @wh_saved.
  ///
  /// In en, this message translates to:
  /// **'Webhook saved'**
  String get wh_saved;

  /// No description provided for @wh_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No webhooks yet'**
  String get wh_empty_title;

  /// No description provided for @wh_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Add one to have events sent to another program.'**
  String get wh_empty_message;

  /// No description provided for @wh_url.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get wh_url;

  /// No description provided for @wh_url_invalid.
  ///
  /// In en, this message translates to:
  /// **'Use an address that starts with http:// or https://.'**
  String get wh_url_invalid;

  /// No description provided for @wh_secret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get wh_secret;

  /// No description provided for @wh_secret_desc.
  ///
  /// In en, this message translates to:
  /// **'Deliveries are signed with it, so the receiver can check where they came from. Optional.'**
  String get wh_secret_desc;

  /// No description provided for @wh_secret_keep.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the stored secret.'**
  String get wh_secret_keep;

  /// No description provided for @wh_secret_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove the secret'**
  String get wh_secret_remove;

  /// No description provided for @wh_enabled_label.
  ///
  /// In en, this message translates to:
  /// **'Send deliveries'**
  String get wh_enabled_label;

  /// No description provided for @wh_enabled.
  ///
  /// In en, this message translates to:
  /// **'Send deliveries to {url}'**
  String wh_enabled(String url);

  /// No description provided for @wh_events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get wh_events;

  /// No description provided for @wh_events_desc.
  ///
  /// In en, this message translates to:
  /// **'Leave all unticked to receive every event.'**
  String get wh_events_desc;

  /// No description provided for @wh_all_events.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get wh_all_events;

  /// No description provided for @wh_events_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 event} other{{count} events}}'**
  String wh_events_count(int count);

  /// No description provided for @wh_signed.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get wh_signed;

  /// No description provided for @wh_test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get wh_test;

  /// No description provided for @wh_test_ok.
  ///
  /// In en, this message translates to:
  /// **'{url} accepted the test event.'**
  String wh_test_ok(String url);

  /// No description provided for @wh_test_failed.
  ///
  /// In en, this message translates to:
  /// **'{url} did not accept the test event.'**
  String wh_test_failed(String url);

  /// No description provided for @wh_log.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get wh_log;

  /// No description provided for @wh_log_title.
  ///
  /// In en, this message translates to:
  /// **'Deliveries to {url}'**
  String wh_log_title(String url);

  /// No description provided for @wh_log_desc.
  ///
  /// In en, this message translates to:
  /// **'The last attempts since the daemon started, newest first.'**
  String get wh_log_desc;

  /// No description provided for @wh_log_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing was sent yet.'**
  String get wh_log_empty;

  /// No description provided for @wh_log_error.
  ///
  /// In en, this message translates to:
  /// **'The deliveries could not be read.'**
  String get wh_log_error;

  /// No description provided for @wh_log_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get wh_log_refresh;

  /// No description provided for @wh_log_no_answer.
  ///
  /// In en, this message translates to:
  /// **'no answer'**
  String get wh_log_no_answer;

  /// No description provided for @wh_log_status.
  ///
  /// In en, this message translates to:
  /// **'HTTP {status}'**
  String wh_log_status(int status);

  /// No description provided for @wh_log_attempt.
  ///
  /// In en, this message translates to:
  /// **'attempt {n}'**
  String wh_log_attempt(int n);

  /// No description provided for @wh_log_retry.
  ///
  /// In en, this message translates to:
  /// **'will retry'**
  String get wh_log_retry;

  /// No description provided for @wh_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit {url}'**
  String wh_edit(String url);

  /// No description provided for @wh_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete {url}'**
  String wh_delete(String url);

  /// No description provided for @wh_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete the webhook {url}?'**
  String wh_delete_title(String url);

  /// No description provided for @wh_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Events will no longer be sent there.'**
  String get wh_delete_message;

  /// No description provided for @wh_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete webhook'**
  String get wh_delete_confirm;

  /// No description provided for @nav_manage_plugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get nav_manage_plugins;

  /// No description provided for @log_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get log_level;

  /// No description provided for @log_level_all.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get log_level_all;

  /// No description provided for @log_level_info.
  ///
  /// In en, this message translates to:
  /// **'Info and above'**
  String get log_level_info;

  /// No description provided for @log_level_warn.
  ///
  /// In en, this message translates to:
  /// **'Warnings and errors'**
  String get log_level_warn;

  /// No description provided for @log_level_error.
  ///
  /// In en, this message translates to:
  /// **'Errors only'**
  String get log_level_error;

  /// No description provided for @log_search.
  ///
  /// In en, this message translates to:
  /// **'Search the log'**
  String get log_search;

  /// No description provided for @log_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get log_refresh;

  /// No description provided for @log_empty.
  ///
  /// In en, this message translates to:
  /// **'No log records.'**
  String get log_empty;

  /// No description provided for @log_error.
  ///
  /// In en, this message translates to:
  /// **'The log could not be read.'**
  String get log_error;

  /// No description provided for @pl_intro.
  ///
  /// In en, this message translates to:
  /// **'Plugins are JavaScript extensions that resolve links, renew expired ones and react to downloads starting, failing and finishing. They run inside the daemon.'**
  String get pl_intro;

  /// No description provided for @pl_install.
  ///
  /// In en, this message translates to:
  /// **'Install a plugin'**
  String get pl_install;

  /// No description provided for @pl_install_title.
  ///
  /// In en, this message translates to:
  /// **'Install a plugin'**
  String get pl_install_title;

  /// No description provided for @pl_install_message.
  ///
  /// In en, this message translates to:
  /// **'The plugin is installed switched off. You review what it may do before it runs.'**
  String get pl_install_message;

  /// No description provided for @pl_install_go.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get pl_install_go;

  /// No description provided for @pl_source.
  ///
  /// In en, this message translates to:
  /// **'Where from'**
  String get pl_source;

  /// No description provided for @pl_source_desc.
  ///
  /// In en, this message translates to:
  /// **'A folder on the computer the daemon runs on, or a git address.'**
  String get pl_source_desc;

  /// No description provided for @pl_ref.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get pl_ref;

  /// No description provided for @pl_ref_desc.
  ///
  /// In en, this message translates to:
  /// **'A branch, tag or commit, for a git address. Optional.'**
  String get pl_ref_desc;

  /// No description provided for @pl_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace a plugin of the same name'**
  String get pl_replace;

  /// No description provided for @pl_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No plugins installed'**
  String get pl_empty_title;

  /// No description provided for @pl_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Install one from a folder or a git address.'**
  String get pl_empty_message;

  /// No description provided for @pl_enabled.
  ///
  /// In en, this message translates to:
  /// **'Run {name}'**
  String pl_enabled(String name);

  /// No description provided for @pl_permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get pl_permissions;

  /// No description provided for @pl_logs.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get pl_logs;

  /// No description provided for @pl_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String pl_remove(String name);

  /// No description provided for @pl_remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String pl_remove_title(String name);

  /// No description provided for @pl_remove_message.
  ///
  /// In en, this message translates to:
  /// **'The plugin, its files and the data it stored are deleted.'**
  String get pl_remove_message;

  /// No description provided for @pl_remove_confirm.
  ///
  /// In en, this message translates to:
  /// **'Remove plugin'**
  String get pl_remove_confirm;

  /// No description provided for @pl_logs_title.
  ///
  /// In en, this message translates to:
  /// **'Log of {name}'**
  String pl_logs_title(String name);

  /// No description provided for @pl_review_title.
  ///
  /// In en, this message translates to:
  /// **'What {name} may do'**
  String pl_review_title(String name);

  /// No description provided for @pl_review_fresh.
  ///
  /// In en, this message translates to:
  /// **'The plugin is installed but not running.'**
  String get pl_review_fresh;

  /// No description provided for @pl_review_source.
  ///
  /// In en, this message translates to:
  /// **'From {source}, version {version}.'**
  String pl_review_source(String source, String version);

  /// No description provided for @pl_hooks.
  ///
  /// In en, this message translates to:
  /// **'It reacts to'**
  String get pl_hooks;

  /// No description provided for @pl_hooks_none.
  ///
  /// In en, this message translates to:
  /// **'No events.'**
  String get pl_hooks_none;

  /// No description provided for @pl_hosts.
  ///
  /// In en, this message translates to:
  /// **'It may contact'**
  String get pl_hosts;

  /// No description provided for @pl_hosts_none.
  ///
  /// In en, this message translates to:
  /// **'No other computers.'**
  String get pl_hosts_none;

  /// No description provided for @pl_trust_warning.
  ///
  /// In en, this message translates to:
  /// **'A plugin runs inside the daemon and can contact the hosts listed. Only switch on plugins you trust.'**
  String get pl_trust_warning;

  /// No description provided for @pl_keep_off.
  ///
  /// In en, this message translates to:
  /// **'Keep it off'**
  String get pl_keep_off;

  /// No description provided for @pl_enable.
  ///
  /// In en, this message translates to:
  /// **'Switch it on'**
  String get pl_enable;

  /// No description provided for @nav_manage_browser.
  ///
  /// In en, this message translates to:
  /// **'Browser tool'**
  String get nav_manage_browser;

  /// No description provided for @br_intro.
  ///
  /// In en, this message translates to:
  /// **'Some pages only show their downloads in a real browser. Open one here and the daemon\'s headless browser lists what the page leads to: files, video and audio streams.'**
  String get br_intro;

  /// No description provided for @br_open_title.
  ///
  /// In en, this message translates to:
  /// **'Open a page'**
  String get br_open_title;

  /// No description provided for @br_url.
  ///
  /// In en, this message translates to:
  /// **'Page address'**
  String get br_url;

  /// No description provided for @br_url_invalid.
  ///
  /// In en, this message translates to:
  /// **'Use an address that starts with http:// or https://.'**
  String get br_url_invalid;

  /// No description provided for @br_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get br_open;

  /// No description provided for @br_opening.
  ///
  /// In en, this message translates to:
  /// **'Opening…'**
  String get br_opening;

  /// No description provided for @br_error.
  ///
  /// In en, this message translates to:
  /// **'The page could not be opened.'**
  String get br_error;

  /// No description provided for @br_result_info.
  ///
  /// In en, this message translates to:
  /// **'Opened {url} in the group {group}.'**
  String br_result_info(String url, String group);

  /// No description provided for @br_none.
  ///
  /// In en, this message translates to:
  /// **'The page led to no downloads.'**
  String get br_none;

  /// No description provided for @br_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get br_download;

  /// No description provided for @br_added.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String br_added(String name);

  /// No description provided for @br_profiles_title.
  ///
  /// In en, this message translates to:
  /// **'Browser profiles'**
  String get br_profiles_title;

  /// No description provided for @br_profiles_desc.
  ///
  /// In en, this message translates to:
  /// **'Each site group has its own profile, which keeps the logins of the pages opened there.'**
  String get br_profiles_desc;

  /// No description provided for @br_profiles_none.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet.'**
  String get br_profiles_none;

  /// No description provided for @br_profiles_error.
  ///
  /// In en, this message translates to:
  /// **'The profiles could not be listed.'**
  String get br_profiles_error;

  /// No description provided for @br_profile_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete the profile {group}'**
  String br_profile_delete(String group);

  /// No description provided for @br_profile_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete the profile of {group}?'**
  String br_profile_delete_title(String group);

  /// No description provided for @br_profile_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Its cookies and stored data are removed. It cannot be deleted while its browser runs.'**
  String get br_profile_delete_message;

  /// No description provided for @br_profile_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get br_profile_delete_confirm;

  /// No description provided for @br_state_title.
  ///
  /// In en, this message translates to:
  /// **'The headless browser'**
  String get br_state_title;

  /// No description provided for @br_state_in_use.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get br_state_in_use;

  /// No description provided for @br_state_unused.
  ///
  /// In en, this message translates to:
  /// **'Not used yet'**
  String get br_state_unused;

  /// No description provided for @br_state_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get br_state_running;

  /// No description provided for @br_state_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get br_state_none;

  /// No description provided for @br_state_max.
  ///
  /// In en, this message translates to:
  /// **'At most at once'**
  String get br_state_max;

  /// No description provided for @br_tools_title.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get br_tools_title;

  /// No description provided for @nav_manage_transfer.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get nav_manage_transfer;

  /// No description provided for @tr_intro.
  ///
  /// In en, this message translates to:
  /// **'Add many downloads from a list, or write your downloads out as a list. Nothing is added until you have seen what would happen.'**
  String get tr_intro;

  /// No description provided for @tr_import_title.
  ///
  /// In en, this message translates to:
  /// **'Import a list'**
  String get tr_import_title;

  /// No description provided for @tr_list.
  ///
  /// In en, this message translates to:
  /// **'The list'**
  String get tr_list;

  /// No description provided for @tr_list_desc.
  ///
  /// In en, this message translates to:
  /// **'Paste it here, or choose a file.'**
  String get tr_list_desc;

  /// No description provided for @tr_choose.
  ///
  /// In en, this message translates to:
  /// **'Choose a file…'**
  String get tr_choose;

  /// No description provided for @tr_format.
  ///
  /// In en, this message translates to:
  /// **'Kind of list'**
  String get tr_format;

  /// No description provided for @tr_format_urls.
  ///
  /// In en, this message translates to:
  /// **'One link per line'**
  String get tr_format_urls;

  /// No description provided for @tr_format_json.
  ///
  /// In en, this message translates to:
  /// **'dlm JSON'**
  String get tr_format_json;

  /// No description provided for @tr_format_aria2.
  ///
  /// In en, this message translates to:
  /// **'aria2 input file'**
  String get tr_format_aria2;

  /// No description provided for @tr_default_queue.
  ///
  /// In en, this message translates to:
  /// **'The default queue'**
  String get tr_default_queue;

  /// No description provided for @tr_duplicates.
  ///
  /// In en, this message translates to:
  /// **'Add duplicates too'**
  String get tr_duplicates;

  /// No description provided for @tr_duplicates_desc.
  ///
  /// In en, this message translates to:
  /// **'Otherwise links that are already in the list are skipped.'**
  String get tr_duplicates_desc;

  /// No description provided for @tr_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tr_preview;

  /// No description provided for @tr_preview_summary.
  ///
  /// In en, this message translates to:
  /// **'Would add {ok}, would not add {failed}.'**
  String tr_preview_summary(int ok, int failed);

  /// No description provided for @tr_export_title.
  ///
  /// In en, this message translates to:
  /// **'Export downloads'**
  String get tr_export_title;

  /// No description provided for @tr_export_format.
  ///
  /// In en, this message translates to:
  /// **'File kind to export'**
  String get tr_export_format;

  /// No description provided for @tr_export_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get tr_export_queue;

  /// No description provided for @tr_all_queues.
  ///
  /// In en, this message translates to:
  /// **'All queues'**
  String get tr_all_queues;

  /// No description provided for @tr_export_status.
  ///
  /// In en, this message translates to:
  /// **'Which downloads'**
  String get tr_export_status;

  /// No description provided for @tr_all_statuses.
  ///
  /// In en, this message translates to:
  /// **'All of them'**
  String get tr_all_statuses;

  /// No description provided for @tr_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get tr_export;

  /// No description provided for @tr_export_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 download} other{{count} downloads}}'**
  String tr_export_count(int count);

  /// No description provided for @tr_export_text.
  ///
  /// In en, this message translates to:
  /// **'The exported list'**
  String get tr_export_text;

  /// No description provided for @nav_manage_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get nav_manage_statistics;

  /// No description provided for @st_error.
  ///
  /// In en, this message translates to:
  /// **'The statistics could not be read.'**
  String get st_error;

  /// No description provided for @st_totals.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get st_totals;

  /// No description provided for @st_tasks.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get st_tasks;

  /// No description provided for @st_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded in all'**
  String get st_downloaded;

  /// No description provided for @st_by_status.
  ///
  /// In en, this message translates to:
  /// **'By state'**
  String get st_by_status;

  /// No description provided for @st_by_engine.
  ///
  /// In en, this message translates to:
  /// **'By engine'**
  String get st_by_engine;

  /// No description provided for @st_completed_in.
  ///
  /// In en, this message translates to:
  /// **'Finished in the last {period}'**
  String st_completed_in(String period);

  /// No description provided for @st_bucket.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get st_bucket;

  /// No description provided for @st_bucket_hour.
  ///
  /// In en, this message translates to:
  /// **'Per hour'**
  String get st_bucket_hour;

  /// No description provided for @st_bucket_day.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get st_bucket_day;

  /// No description provided for @st_group.
  ///
  /// In en, this message translates to:
  /// **'Split by'**
  String get st_group;

  /// No description provided for @st_group_none.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get st_group_none;

  /// No description provided for @st_group_engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get st_group_engine;

  /// No description provided for @st_group_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get st_group_queue;

  /// No description provided for @st_timeline.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get st_timeline;

  /// No description provided for @st_timeline_summary.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {down}, uploaded {up} in this range.'**
  String st_timeline_summary(String down, String up);

  /// No description provided for @st_timeline_empty.
  ///
  /// In en, this message translates to:
  /// **'No traffic in this range.'**
  String get st_timeline_empty;

  /// No description provided for @st_all_traffic.
  ///
  /// In en, this message translates to:
  /// **'All traffic'**
  String get st_all_traffic;

  /// No description provided for @st_history.
  ///
  /// In en, this message translates to:
  /// **'Finished downloads'**
  String get st_history;

  /// No description provided for @st_history_search.
  ///
  /// In en, this message translates to:
  /// **'Search by name or link'**
  String get st_history_search;

  /// No description provided for @st_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No finished downloads.'**
  String get st_history_empty;

  /// No description provided for @st_history_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get st_history_more;

  /// No description provided for @st_cleanup_title.
  ///
  /// In en, this message translates to:
  /// **'Clean up'**
  String get st_cleanup_title;

  /// No description provided for @st_cleanup_desc.
  ///
  /// In en, this message translates to:
  /// **'Removes finished downloads from the list. The automatic cleanup of the retention setting never deletes files.'**
  String get st_cleanup_desc;

  /// No description provided for @st_cleanup_days.
  ///
  /// In en, this message translates to:
  /// **'Older than'**
  String get st_cleanup_days;

  /// No description provided for @st_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get st_days;

  /// No description provided for @st_cleanup_files.
  ///
  /// In en, this message translates to:
  /// **'Also delete the files'**
  String get st_cleanup_files;

  /// No description provided for @st_cleanup_files_desc.
  ///
  /// In en, this message translates to:
  /// **'Off keeps the files on disk and only removes the list entries.'**
  String get st_cleanup_files_desc;

  /// No description provided for @st_cleanup_preview.
  ///
  /// In en, this message translates to:
  /// **'Check what would go'**
  String get st_cleanup_preview;

  /// No description provided for @st_cleanup_preview_result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 download} other{{count} downloads}} ({size}) would be removed.'**
  String st_cleanup_preview_result(int count, String size);

  /// No description provided for @st_cleanup_go.
  ///
  /// In en, this message translates to:
  /// **'Clean up'**
  String get st_cleanup_go;

  /// No description provided for @st_cleanup_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Remove {count, plural, one{1 download} other{{count} downloads}}?'**
  String st_cleanup_confirm_title(int count);

  /// No description provided for @st_cleanup_confirm_list.
  ///
  /// In en, this message translates to:
  /// **'They leave the list; the files stay where they are.'**
  String get st_cleanup_confirm_list;

  /// No description provided for @st_cleanup_confirm_files.
  ///
  /// In en, this message translates to:
  /// **'They leave the list and their files are deleted from the disk. This cannot be undone.'**
  String get st_cleanup_confirm_files;

  /// No description provided for @st_cleanup_done.
  ///
  /// In en, this message translates to:
  /// **'Removed {count, plural, one{1 download} other{{count} downloads}}'**
  String st_cleanup_done(int count);

  /// No description provided for @st_cleanup_done_failed.
  ///
  /// In en, this message translates to:
  /// **'Removed {deleted}; {failed} could not be removed'**
  String st_cleanup_done_failed(int deleted, int failed);

  /// No description provided for @nav_manage_daemon.
  ///
  /// In en, this message translates to:
  /// **'Daemon'**
  String get nav_manage_daemon;

  /// No description provided for @dm_intro.
  ///
  /// In en, this message translates to:
  /// **'How the download service itself starts: where it listens, its engines and programs, its logging. Most changes take effect after a restart.'**
  String get dm_intro;

  /// No description provided for @dm_file.
  ///
  /// In en, this message translates to:
  /// **'Read from {file}'**
  String dm_file(String file);

  /// No description provided for @dm_file_error.
  ///
  /// In en, this message translates to:
  /// **'The configuration file has a problem: {error}'**
  String dm_file_error(String error);

  /// No description provided for @dm_pending_title.
  ///
  /// In en, this message translates to:
  /// **'A restart is needed'**
  String get dm_pending_title;

  /// No description provided for @dm_pending_message.
  ///
  /// In en, this message translates to:
  /// **'Some saved changes are waiting for the daemon to restart.'**
  String get dm_pending_message;

  /// No description provided for @dm_restart_now.
  ///
  /// In en, this message translates to:
  /// **'Restart now'**
  String get dm_restart_now;

  /// No description provided for @dm_pending_value.
  ///
  /// In en, this message translates to:
  /// **'after the restart: {value}'**
  String dm_pending_value(String value);

  /// No description provided for @dm_read_only.
  ///
  /// In en, this message translates to:
  /// **'set by a flag or the environment'**
  String get dm_read_only;

  /// No description provided for @dm_saved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved'**
  String get dm_saved;

  /// No description provided for @dm_needs_restart.
  ///
  /// In en, this message translates to:
  /// **'These changes take effect after a restart.'**
  String get dm_needs_restart;

  /// No description provided for @dm_restart_title.
  ///
  /// In en, this message translates to:
  /// **'Restart the daemon?'**
  String get dm_restart_title;

  /// No description provided for @dm_restart_message.
  ///
  /// In en, this message translates to:
  /// **'Downloads that are running are requeued and start again afterwards.'**
  String get dm_restart_message;

  /// No description provided for @dm_restart_confirm.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get dm_restart_confirm;

  /// No description provided for @dm_restarting.
  ///
  /// In en, this message translates to:
  /// **'The daemon is restarting'**
  String get dm_restarting;

  /// No description provided for @dm_log_title.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get dm_log_title;

  /// No description provided for @nav_manage_access.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get nav_manage_access;

  /// No description provided for @ac_identity.
  ///
  /// In en, this message translates to:
  /// **'This app'**
  String get ac_identity;

  /// No description provided for @ac_signed_in.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get ac_signed_in;

  /// No description provided for @ac_who.
  ///
  /// In en, this message translates to:
  /// **'{name} ({scope}, {kind})'**
  String ac_who(String name, String scope, String kind);

  /// No description provided for @ac_scope_admin.
  ///
  /// In en, this message translates to:
  /// **'can change everything'**
  String get ac_scope_admin;

  /// No description provided for @ac_scope_read.
  ///
  /// In en, this message translates to:
  /// **'read only'**
  String get ac_scope_read;

  /// No description provided for @ac_primary.
  ///
  /// In en, this message translates to:
  /// **'the main token'**
  String get ac_primary;

  /// No description provided for @ac_named.
  ///
  /// In en, this message translates to:
  /// **'a named token'**
  String get ac_named;

  /// No description provided for @ac_rotate.
  ///
  /// In en, this message translates to:
  /// **'Replace the main token'**
  String get ac_rotate;

  /// No description provided for @ac_rotate_desc.
  ///
  /// In en, this message translates to:
  /// **'Makes a new main token and stops the old one working at once.'**
  String get ac_rotate_desc;

  /// No description provided for @ac_rotate_title.
  ///
  /// In en, this message translates to:
  /// **'Replace the main token?'**
  String get ac_rotate_title;

  /// No description provided for @ac_rotate_message.
  ///
  /// In en, this message translates to:
  /// **'Every client that uses the old token, such as a browser extension or a script, stops working until it is given the new one. This app is signed in again automatically.'**
  String get ac_rotate_message;

  /// No description provided for @ac_rotate_confirm.
  ///
  /// In en, this message translates to:
  /// **'Replace it'**
  String get ac_rotate_confirm;

  /// No description provided for @ac_rotated_title.
  ///
  /// In en, this message translates to:
  /// **'The new main token'**
  String get ac_rotated_title;

  /// No description provided for @ac_tokens.
  ///
  /// In en, this message translates to:
  /// **'Named tokens'**
  String get ac_tokens;

  /// No description provided for @ac_tokens_desc.
  ///
  /// In en, this message translates to:
  /// **'Give a dashboard, a script or another device a token of its own, and revoke it when it is no longer needed.'**
  String get ac_tokens_desc;

  /// No description provided for @ac_tokens_none.
  ///
  /// In en, this message translates to:
  /// **'No named tokens.'**
  String get ac_tokens_none;

  /// No description provided for @ac_tokens_error.
  ///
  /// In en, this message translates to:
  /// **'The tokens could not be listed.'**
  String get ac_tokens_error;

  /// No description provided for @ac_add.
  ///
  /// In en, this message translates to:
  /// **'Add a token'**
  String get ac_add;

  /// No description provided for @ac_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add a token'**
  String get ac_add_title;

  /// No description provided for @ac_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get ac_name;

  /// No description provided for @ac_name_hint.
  ///
  /// In en, this message translates to:
  /// **'dashboard'**
  String get ac_name_hint;

  /// No description provided for @ac_scope.
  ///
  /// In en, this message translates to:
  /// **'Can'**
  String get ac_scope;

  /// No description provided for @ac_scope_desc.
  ///
  /// In en, this message translates to:
  /// **'A read-only token can look at everything except cookies, and change nothing.'**
  String get ac_scope_desc;

  /// No description provided for @ac_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get ac_create;

  /// No description provided for @ac_created_title.
  ///
  /// In en, this message translates to:
  /// **'The token {name}'**
  String ac_created_title(String name);

  /// No description provided for @ac_created.
  ///
  /// In en, this message translates to:
  /// **'created {date}'**
  String ac_created(String date);

  /// No description provided for @ac_never_used.
  ///
  /// In en, this message translates to:
  /// **'never used'**
  String get ac_never_used;

  /// No description provided for @ac_last_used.
  ///
  /// In en, this message translates to:
  /// **'last used {date}'**
  String ac_last_used(String date);

  /// No description provided for @ac_delete.
  ///
  /// In en, this message translates to:
  /// **'Revoke the token {name}'**
  String ac_delete(String name);

  /// No description provided for @ac_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Revoke the token {name}?'**
  String ac_delete_title(String name);

  /// No description provided for @ac_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Whatever uses it stops working.'**
  String get ac_delete_message;

  /// No description provided for @ac_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Revoke token'**
  String get ac_delete_confirm;

  /// No description provided for @ac_secret_once.
  ///
  /// In en, this message translates to:
  /// **'This is the only time the token is shown. Copy it now and keep it somewhere safe.'**
  String get ac_secret_once;

  /// No description provided for @ac_secret_done.
  ///
  /// In en, this message translates to:
  /// **'I have copied it'**
  String get ac_secret_done;

  /// No description provided for @ac_secret_gone.
  ///
  /// In en, this message translates to:
  /// **'The token is not shown again'**
  String get ac_secret_gone;

  /// No description provided for @ac_nh_title.
  ///
  /// In en, this message translates to:
  /// **'Browser extension'**
  String get ac_nh_title;

  /// No description provided for @ac_nh_desc.
  ///
  /// In en, this message translates to:
  /// **'The extension talks to the download service through a native host that is registered with each browser. Installing works only on the computer the daemon runs on.'**
  String get ac_nh_desc;

  /// No description provided for @ac_nh_origins.
  ///
  /// In en, this message translates to:
  /// **'Allowed extensions'**
  String get ac_nh_origins;

  /// No description provided for @ac_nh_no_origins.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get ac_nh_no_origins;

  /// No description provided for @ac_nh_error.
  ///
  /// In en, this message translates to:
  /// **'The extension host cannot be managed from here.'**
  String get ac_nh_error;

  /// No description provided for @ac_nh_ids.
  ///
  /// In en, this message translates to:
  /// **'Extension IDs'**
  String get ac_nh_ids;

  /// No description provided for @ac_nh_ids_desc.
  ///
  /// In en, this message translates to:
  /// **'Separated by commas or spaces. Needed to install.'**
  String get ac_nh_ids_desc;

  /// No description provided for @ac_nh_install.
  ///
  /// In en, this message translates to:
  /// **'Install for all browsers'**
  String get ac_nh_install;

  /// No description provided for @ac_nh_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get ac_nh_remove;

  /// No description provided for @ac_nh_done.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Done for 1 browser} other{Done for {count} browsers}}'**
  String ac_nh_done(int count);

  /// No description provided for @ac_mcp_title.
  ///
  /// In en, this message translates to:
  /// **'Assistants (MCP)'**
  String get ac_mcp_title;

  /// No description provided for @ac_mcp_desc.
  ///
  /// In en, this message translates to:
  /// **'An AI assistant that speaks the Model Context Protocol can add and manage downloads. It signs in with a token.'**
  String get ac_mcp_desc;

  /// No description provided for @ac_mcp_url.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get ac_mcp_url;

  /// No description provided for @ac_mcp_claude.
  ///
  /// In en, this message translates to:
  /// **'Claude Code'**
  String get ac_mcp_claude;

  /// No description provided for @ac_mcp_json.
  ///
  /// In en, this message translates to:
  /// **'Settings file (JSON)'**
  String get ac_mcp_json;

  /// No description provided for @ac_mcp_token_note.
  ///
  /// In en, this message translates to:
  /// **'Replace <token> with a token from this page. A read-only token lets an assistant look but not change anything.'**
  String get ac_mcp_token_note;

  /// No description provided for @nav_manage_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get nav_manage_preferences;

  /// No description provided for @pref_intro.
  ///
  /// In en, this message translates to:
  /// **'How the app looks and asks. Changes apply at once.'**
  String get pref_intro;

  /// No description provided for @pref_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get pref_appearance;

  /// No description provided for @pref_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get pref_theme;

  /// No description provided for @pref_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get pref_theme_system;

  /// No description provided for @pref_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get pref_theme_light;

  /// No description provided for @pref_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get pref_theme_dark;

  /// No description provided for @pref_accent.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get pref_accent;

  /// No description provided for @pref_accent_default.
  ///
  /// In en, this message translates to:
  /// **'The system\'s'**
  String get pref_accent_default;

  /// No description provided for @pref_accent_blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get pref_accent_blue;

  /// No description provided for @pref_accent_green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get pref_accent_green;

  /// No description provided for @pref_accent_orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get pref_accent_orange;

  /// No description provided for @pref_accent_red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get pref_accent_red;

  /// No description provided for @pref_accent_purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get pref_accent_purple;

  /// No description provided for @pref_accent_pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pref_accent_pink;

  /// No description provided for @pref_skin.
  ///
  /// In en, this message translates to:
  /// **'Look and feel'**
  String get pref_skin;

  /// No description provided for @pref_skin_desc.
  ///
  /// In en, this message translates to:
  /// **'The app follows your system; choose another to see the app dressed as on that system.'**
  String get pref_skin_desc;

  /// No description provided for @pref_skin_auto.
  ///
  /// In en, this message translates to:
  /// **'Match this system'**
  String get pref_skin_auto;

  /// No description provided for @pref_skin_macos.
  ///
  /// In en, this message translates to:
  /// **'macOS'**
  String get pref_skin_macos;

  /// No description provided for @pref_skin_fluent.
  ///
  /// In en, this message translates to:
  /// **'Windows (Fluent)'**
  String get pref_skin_fluent;

  /// No description provided for @pref_skin_adwaita.
  ///
  /// In en, this message translates to:
  /// **'GNOME (Adwaita)'**
  String get pref_skin_adwaita;

  /// No description provided for @pref_skin_breeze.
  ///
  /// In en, this message translates to:
  /// **'KDE (Breeze)'**
  String get pref_skin_breeze;

  /// No description provided for @pref_density.
  ///
  /// In en, this message translates to:
  /// **'Row height'**
  String get pref_density;

  /// No description provided for @pref_confirmations.
  ///
  /// In en, this message translates to:
  /// **'Asking first'**
  String get pref_confirmations;

  /// No description provided for @pref_confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Ask before deleting downloads'**
  String get pref_confirm_delete;

  /// No description provided for @pref_confirm_delete_desc.
  ///
  /// In en, this message translates to:
  /// **'Off deletes at once, keeping the files on disk.'**
  String get pref_confirm_delete_desc;

  /// No description provided for @nav_manage_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get nav_manage_about;

  /// No description provided for @ab_title.
  ///
  /// In en, this message translates to:
  /// **'dlm'**
  String get ab_title;

  /// No description provided for @ab_blurb.
  ///
  /// In en, this message translates to:
  /// **'A download manager for files, torrents and streams, made of this app and a download service that does the work.'**
  String get ab_blurb;

  /// No description provided for @ab_app.
  ///
  /// In en, this message translates to:
  /// **'This app'**
  String get ab_app;

  /// No description provided for @ab_daemon.
  ///
  /// In en, this message translates to:
  /// **'The download service'**
  String get ab_daemon;

  /// No description provided for @ab_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get ab_version;

  /// No description provided for @ab_api.
  ///
  /// In en, this message translates to:
  /// **'Talks API revision'**
  String get ab_api;

  /// No description provided for @ab_api_value.
  ///
  /// In en, this message translates to:
  /// **'revision {current}, works with {oldest} and newer'**
  String ab_api_value(int current, int oldest);

  /// No description provided for @ab_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get ab_system;

  /// No description provided for @ab_address.
  ///
  /// In en, this message translates to:
  /// **'Listens on'**
  String get ab_address;

  /// No description provided for @ab_compat.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get ab_compat;

  /// No description provided for @ab_compat_ok.
  ///
  /// In en, this message translates to:
  /// **'They work together.'**
  String get ab_compat_ok;

  /// No description provided for @ab_compat_app_old.
  ///
  /// In en, this message translates to:
  /// **'The service needs a newer version of this app.'**
  String get ab_compat_app_old;

  /// No description provided for @ab_compat_daemon_old.
  ///
  /// In en, this message translates to:
  /// **'The service is older than this app supports.'**
  String get ab_compat_daemon_old;

  /// No description provided for @ab_compat_unknown.
  ///
  /// In en, this message translates to:
  /// **'Not connected.'**
  String get ab_compat_unknown;

  /// No description provided for @ab_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get ab_support;

  /// No description provided for @ab_diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get ab_diagnostics;

  /// No description provided for @ab_diagnostics_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get ab_diagnostics_copy;

  /// No description provided for @ab_diagnostics_desc.
  ///
  /// In en, this message translates to:
  /// **'Puts versions, the connections (without tokens) and the recent log on the clipboard, with secrets removed, for you to paste into a bug report.'**
  String get ab_diagnostics_desc;

  /// No description provided for @ab_diagnostics_copied.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied'**
  String get ab_diagnostics_copied;

  /// No description provided for @ab_licences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get ab_licences;

  /// No description provided for @ab_licences_list.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get ab_licences_list;

  /// No description provided for @ab_licences_show.
  ///
  /// In en, this message translates to:
  /// **'Show the licences'**
  String get ab_licences_show;

  /// No description provided for @ab_licences_desc.
  ///
  /// In en, this message translates to:
  /// **'dlm is built from open-source packages. Their licences are listed here.'**
  String get ab_licences_desc;

  /// No description provided for @ab_licences_none.
  ///
  /// In en, this message translates to:
  /// **'No licences are registered in this build.'**
  String get ab_licences_none;

  /// No description provided for @ab_licences_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 licence text} other{{count} licence texts}}'**
  String ab_licences_count(int count);

  /// No description provided for @nav_tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get nav_tools;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
