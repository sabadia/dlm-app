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
