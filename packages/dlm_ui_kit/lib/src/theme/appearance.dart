import 'dart:ui';

import 'metrics.dart';
import 'token_value.dart';

/// Whether the system asks for increased contrast.
enum DlmContrast {
  /// The normal palette.
  standard,

  /// The skin's high-contrast palette.
  high,
}

/// What the operating system (or desktop environment) says about how the UI
/// should look right now.
class DlmAppearance extends DlmTokenValue {
  /// Creates a [DlmAppearance].
  const DlmAppearance({
    this.brightness = Brightness.light,
    this.contrast = DlmContrast.standard,
    this.accent,
    this.reduceMotion = false,
    this.reduceTransparency = false,
    this.textScale = 1,
  });

  /// Brightness.
  final Brightness brightness;

  /// Contrast.
  final DlmContrast contrast;

  /// The system accent colour, or null when the OS has none (the skin uses its
  /// own).
  final Color? accent;

  /// The user or system asks for no animation.
  final bool reduceMotion;

  /// The user or system asks for opaque surfaces.
  final bool reduceTransparency;

  /// The OS text scale factor (1 = default).
  final double textScale;

  /// High contrast.
  bool get highContrast => contrast == DlmContrast.high;

  /// A copy with the given fields replaced.
  DlmAppearance copyWith({
    Brightness? brightness,
    DlmContrast? contrast,
    Color? accent,
    bool? reduceMotion,
    bool? reduceTransparency,
    double? textScale,
  }) => DlmAppearance(
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    accent: accent ?? this.accent,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
    textScale: textScale ?? this.textScale,
  );

  @override
  List<Object?> get props => [
    brightness,
    contrast,
    accent,
    reduceMotion,
    reduceTransparency,
    textScale,
  ];
}

/// The user's choice between following the system and forcing a look.
enum DlmThemeMode {
  /// Follow the system.
  native,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// The user's overrides of the system appearance (Preferences, F2.8).
class AppearanceOverride extends DlmTokenValue {
  /// Creates a [AppearanceOverride].
  const AppearanceOverride({
    this.mode = DlmThemeMode.native,
    this.accent,
    this.textScale = 1,
    this.density = DlmDensity.regular,
    this.reduceMotion,
  });

  /// Follow the system everywhere.
  static const AppearanceOverride none = AppearanceOverride();

  /// Mode.
  final DlmThemeMode mode;

  /// Replaces the system accent when set.
  final Color? accent;

  /// Multiplier on top of the OS text scale.
  final double textScale;

  /// Density.
  final DlmDensity density;

  /// Forces reduce-motion on or off when set; null follows the system.
  final bool? reduceMotion;

  @override
  List<Object?> get props => [mode, accent, textScale, density, reduceMotion];
}

/// The appearance the theme is built from: [system] with [userOverride] applied.
DlmAppearance resolveAppearance(
  DlmAppearance system,
  AppearanceOverride userOverride,
) {
  return DlmAppearance(
    brightness: switch (userOverride.mode) {
      DlmThemeMode.native => system.brightness,
      DlmThemeMode.light => Brightness.light,
      DlmThemeMode.dark => Brightness.dark,
    },
    contrast: system.contrast,
    accent: userOverride.accent ?? system.accent,
    reduceMotion: userOverride.reduceMotion ?? system.reduceMotion,
    reduceTransparency: system.reduceTransparency,
    textScale: system.textScale * userOverride.textScale,
  );
}
