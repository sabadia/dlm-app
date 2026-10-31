import '../format/sizes.dart';
import 'preferences.dart';
import 'saved_view.dart';

/// The colour scheme the user wants.
enum ThemeChoice {
  /// Follow the operating system.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// Which published builds the update check considers.
enum UpdateChannel {
  /// Tagged releases only.
  stable,

  /// Tagged releases and prereleases.
  beta,
}

/// How tightly lists are packed.
enum Density {
  /// Roomy rows.
  comfortable,

  /// More rows per screen.
  compact,
}

/// Where the window was, so it comes back there.
class WindowState {
  /// Creates the state.
  const WindowState({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.maximized = false,
  });

  /// Decodes a stored state; null when it is unusable.
  static WindowState? fromJson(Object? raw) {
    if (raw is! Map<String, Object?>) return null;
    final x = raw['x'];
    final y = raw['y'];
    final w = raw['width'];
    final h = raw['height'];
    if (x is! num || y is! num || w is! num || h is! num || w <= 0 || h <= 0) {
      return null;
    }
    return WindowState(
      x: x.toDouble(),
      y: y.toDouble(),
      width: w.toDouble(),
      height: h.toDouble(),
      maximized: raw['maximized'] == true,
    );
  }

  /// Left edge.
  final double x;

  /// Top edge.
  final double y;

  /// Width.
  final double width;

  /// Height.
  final double height;

  /// Whether it was maximised.
  final bool maximized;

  /// The stored form.
  Map<String, Object?> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'maximized': maximized,
  };

  @override
  bool operator ==(Object other) =>
      other is WindowState &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      other.maximized == maximized;

  @override
  int get hashCode => Object.hash(x, y, width, height, maximized);
}

/// Every UI preference of the app. Reading and writing goes through a
/// `PreferencesStore`.
// A namespace for the definitions, so call sites read `UiPrefs.density`.
// ignore: avoid_classes_with_only_static_members
abstract final class UiPrefs {
  /// Light, dark or follow the system.
  static final theme = enumPref(
    'ui.theme',
    ThemeChoice.values,
    ThemeChoice.system,
  );

  /// Force a skin by id (`macos`, `fluent`, `adwaita`, `breeze`); null picks the
  /// skin of this operating system.
  static const skinOverride = Pref<String?>.plain('ui.skin', null);

  /// Accent colour as an ARGB value; null follows the system accent (or the
  /// skin's own when the system has none).
  static const accent = Pref<int?>.plain('ui.accent', null);

  /// Width of the sidebar in logical pixels.
  static const sidebarWidth = Pref<double>.plain('ui.sidebarWidth', 240);

  /// Width of the details pane in logical pixels.
  static const inspectorWidth = Pref<double>.plain('ui.inspectorWidth', 340);

  /// The connection profile the app talks to; `local` is the bundled daemon.
  static const activeProfile = Pref<String>.plain(
    'connection.profile',
    'local',
  );

  /// Whether the first-run setup was finished (or skipped).
  static const onboardingDone = Pref<bool>.plain('ui.onboardingDone', false);

  /// Whether the details pane is open.
  static const inspectorVisible = Pref<bool>.plain('ui.inspectorVisible', true);

  /// Row density.
  static final density = enumPref(
    'ui.density',
    Density.values,
    Density.comfortable,
  );

  /// IEC (KiB) or SI (kB) sizes.
  static final unitSystem = enumPref(
    'ui.units',
    UnitSystem.values,
    UnitSystem.iec,
  );

  /// Language code (`de`); null follows the system.
  static const language = Pref<String?>.plain('ui.language', null);

  /// Which GitHub releases count as an update.
  static final updateChannel = enumPref(
    'ui.updateChannel',
    UpdateChannel.values,
    UpdateChannel.stable,
  );

  /// Whether the tray / menu-bar item shows.
  static const trayEnabled = Pref<bool>.plain('ui.tray', true);

  /// Start with the window hidden, only the tray item.
  static const startMinimised = Pref<bool>.plain('ui.startMinimised', false);

  /// Ask before deleting downloads.
  static const confirmDelete = Pref<bool>.plain('ui.confirmDelete', true);

  /// Notify when a download finishes or fails.
  static const notifyOnFinish = Pref<bool>.plain('ui.notifyOnFinish', true);

  /// Watch the clipboard for download links. Off until the user turns it on.
  static const clipboardWatch = Pref<bool>.plain('ui.clipboardWatch', false);

  /// Shortcut overrides, command id to a chord such as `primary+42`. Empty
  /// means the built-in chords.
  static final shortcuts = Pref<Map<String, String>>(
    'ui.shortcuts',
    const {},
    _decodeShortcuts,
    (v) => v,
  );

  static Map<String, String>? _decodeShortcuts(Object? raw) {
    if (raw is! Map) return null;
    return {
      for (final e in raw.entries)
        if (e.key is String && e.value is String)
          e.key as String: e.value as String,
    };
  }

  /// The window's place and size.
  static const windowState = Pref<WindowState?>(
    'ui.window',
    null,
    WindowState.fromJson,
    _encodeWindow,
  );

  static Object? _encodeWindow(WindowState? w) => w?.toJson();

  /// The views the user saved for the downloads list.
  static final savedViews = Pref<List<SavedView>>(
    'list.savedViews',
    const [],
    (raw) => raw is List<Object?>
        ? [
            for (final v in raw)
              if (SavedView.fromJson(v) case final SavedView view) view,
          ]
        : null,
    (v) => [for (final view in v) view.toJson()],
  );

  /// The visible columns of list [list] in order; empty means the view's
  /// default. Kept per connection profile.
  static Pref<List<String>> columns(String list) => Pref<List<String>>(
    'list.$list.columns',
    const [],
    (raw) => raw is List<Object?> ? [for (final c in raw) c! as String] : null,
    (v) => v,
  );
}
