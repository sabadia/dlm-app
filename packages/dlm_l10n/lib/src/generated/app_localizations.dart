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
