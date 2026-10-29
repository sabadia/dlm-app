import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Splits a Windows toast argument into a button id and a payload.
///
/// Windows hands back only the argument of whatever was activated, and the
/// plugin copies that string into both the payload and the action id. A button
/// therefore carries both pieces, separated by [windowsActionSeparator]. A
/// click on the toast itself is the payload alone.
const String windowsActionSeparator = '\u001f';

/// The argument stored on a Windows button.
String windowsActionArgument(String buttonId, String? payload) =>
    '$buttonId$windowsActionSeparator${payload ?? ''}';

/// Turns a plugin callback into a [NotificationTap].
///
/// On Windows, [actionId] is the same string as [payload]. Everywhere else the
/// plugin already separates the button id from the payload.
NotificationTap interpretNotificationResponse({
  required String? payload,
  required String? actionId,
  required bool windows,
}) {
  if (windows) {
    final raw = (actionId != null && actionId.isNotEmpty) ? actionId : payload;
    final cut = raw?.indexOf(windowsActionSeparator) ?? -1;
    if (raw != null && cut >= 0) {
      final button = raw.substring(0, cut);
      final body = raw.substring(cut + 1);
      return NotificationTap(
        payload: body.isEmpty ? null : body,
        buttonId: button.isEmpty ? null : button,
      );
    }
    return NotificationTap(payload: raw);
  }
  return NotificationTap(
    payload: payload,
    buttonId: actionId == null || actionId.isEmpty ? null : actionId,
  );
}

/// A button on a notification.
class NotificationButton {
  /// Creates a button; [id] comes back in [NotificationTap.buttonId].
  const NotificationButton(this.id, this.label);

  /// What identifies the button.
  final String id;

  /// The text.
  final String label;
}

/// A notification to show.
class AppNotification {
  /// Creates a notification.
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.category = '',
    this.payload,
    this.buttons = const [],
  });

  /// Shown again with the same id replaces the earlier one.
  final int id;

  /// The headline.
  final String title;

  /// The text.
  final String body;

  /// The kind, which decides the buttons on macOS (registered up front, see
  /// [LocalDesktopNotifier.categories]).
  final String category;

  /// Handed back on a tap, to know what the notification was about.
  final String? payload;

  /// Buttons on Windows and Linux (and macOS through [category]).
  final List<NotificationButton> buttons;
}

/// The user clicked a notification or one of its buttons.
class NotificationTap {
  /// Creates the tap.
  const NotificationTap({this.payload, this.buttonId});

  /// The [AppNotification.payload].
  final String? payload;

  /// The button, or null for a click on the notification itself.
  final String? buttonId;
}

/// Desktop notifications with buttons.
abstract interface class DesktopNotifier {
  /// Prepares the system; false when notifications are not available or the
  /// user did not allow them. [categories] are the buttons macOS shows for
  /// each kind of notification; it needs them before the first one.
  Future<bool> init({
    Map<String, List<NotificationButton>> categories = const {},
  });

  /// Clicks on notifications and their buttons.
  Stream<NotificationTap> get taps;

  /// Shows [notification].
  Future<void> show(AppNotification notification);
}

/// No notifications on this platform: nothing shows.
class UnsupportedDesktopNotifier implements DesktopNotifier {
  /// Creates the no-op notifier.
  const UnsupportedDesktopNotifier();

  @override
  Future<bool> init({
    Map<String, List<NotificationButton>> categories = const {},
  }) async => false;

  @override
  Stream<NotificationTap> get taps => const Stream.empty();

  @override
  Future<void> show(AppNotification notification) async {}
}

/// [DesktopNotifier] over `flutter_local_notifications`.
class LocalDesktopNotifier implements DesktopNotifier {
  /// Creates the notifier. [categories] lists, per kind of notification, the
  /// buttons macOS shows: it needs them registered before the first one.
  LocalDesktopNotifier({
    required this.appName,
    this.appUserModelId = 'io.github.sabadia.dlm',
    this.guid = 'b3a9f1c0-6a47-4d0e-9c0b-5d2f6c1e7a10',
    this.defaultActionName = 'Open',
    this.categories = const {},
  });

  /// The name Windows shows.
  final String appName;

  /// The Windows AppUserModelID.
  final String appUserModelId;

  /// The Windows toast activator GUID; fixed for the life of the app.
  final String guid;

  /// The Linux label of a click on the notification itself.
  final String defaultActionName;

  /// Buttons per notification category (macOS).
  final Map<String, List<NotificationButton>> categories;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationTap> _taps = StreamController.broadcast();

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  @override
  Future<bool> init({
    Map<String, List<NotificationButton>> categories = const {},
  }) async {
    final registered = categories.isEmpty ? this.categories : categories;
    final ok = await _plugin.initialize(
      settings: InitializationSettings(
        macOS: DarwinInitializationSettings(
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            for (final e in registered.entries)
              DarwinNotificationCategory(
                e.key,
                actions: [
                  for (final b in e.value)
                    DarwinNotificationAction.plain(b.id, b.label),
                ],
              ),
          ],
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: defaultActionName,
        ),
        windows: WindowsInitializationSettings(
          appName: appName,
          appUserModelId: appUserModelId,
          guid: guid,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        _taps.add(
          interpretNotificationResponse(
            payload: r.payload,
            actionId: r.actionId,
            windows: Platform.isWindows,
          ),
        );
      },
    );
    return ok ?? false;
  }

  @override
  Future<void> show(AppNotification n) => _plugin.show(
    id: n.id,
    title: n.title,
    body: n.body,
    payload: n.payload,
    notificationDetails: NotificationDetails(
      macOS: DarwinNotificationDetails(categoryIdentifier: n.category),
      linux: LinuxNotificationDetails(
        actions: [
          for (final b in n.buttons)
            LinuxNotificationAction(key: b.id, label: b.label),
        ],
      ),
      windows: WindowsNotificationDetails(
        actions: [
          for (final b in n.buttons)
            WindowsAction(
              content: b.label,
              arguments: windowsActionArgument(b.id, n.payload),
            ),
        ],
      ),
    ),
  );
}
