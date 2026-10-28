import '../format/sizes.dart';
import 'preferences.dart';

/// The colour scheme the user wants.
enum ThemeChoice {
  /// Follow the operating system.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
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

  /// Whether the tray / menu-bar item shows.
  static const trayEnabled = Pref<bool>.plain('ui.tray', true);

  /// Start with the window hidden, only the tray item.
  static const startMinimised = Pref<bool>.plain('ui.startMinimised', false);

  /// Ask before deleting downloads.
  static const confirmDelete = Pref<bool>.plain('ui.confirmDelete', true);

  /// Notify when a download finishes or fails.
  static const notifyOnFinish = Pref<bool>.plain('ui.notifyOnFinish', true);

  /// The window's place and size.
  static const windowState = Pref<WindowState?>(
    'ui.window',
    null,
    WindowState.fromJson,
    _encodeWindow,
  );

  static Object? _encodeWindow(WindowState? w) => w?.toJson();

  /// The visible columns of list [list] in order; empty means the view's
  /// default. Kept per connection profile.
  static Pref<List<String>> columns(String list) => Pref<List<String>>(
    'list.$list.columns',
    const [],
    (raw) => raw is List<Object?> ? [for (final c in raw) c! as String] : null,
    (v) => v,
  );
}
