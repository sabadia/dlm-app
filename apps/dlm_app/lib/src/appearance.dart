import 'dart:async';
import 'dart:ui' show Color;

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';

/// The system appearance as the app sees it: what Flutter knows (brightness,
/// contrast, reduce motion, text scale) combined with what the platform reader
/// adds (accent, the user's colour scheme, reduce transparency).
///
/// `dlm_platform` and the kit know nothing about each other, so this is where
/// they meet. When the reader reports a value it wins over Flutter's guess;
/// flags such as high contrast and reduce motion are on if either says so.
class PlatformAppearanceSource implements AppearanceSource {
  /// Creates the source; [flutter] is normally a `FlutterAppearanceSource`.
  PlatformAppearanceSource({
    required AppearanceSource flutter,
    required SystemAppearanceReader system,
  }) : _flutter = flutter,
       _system = system {
    _flutterSub = _flutter.changes.listen((_) => _emit());
    _systemSub = _system.changes.listen((s) {
      _reported = s;
      _emit();
    });
    unawaited(
      _system.read().then((s) {
        _reported = s;
        _emit();
      }),
    );
  }

  final AppearanceSource _flutter;
  final SystemAppearanceReader _system;
  final StreamController<DlmAppearance> _changes =
      StreamController<DlmAppearance>.broadcast(sync: true);
  late final StreamSubscription<DlmAppearance> _flutterSub;
  late final StreamSubscription<SystemAppearance> _systemSub;
  SystemAppearance _reported = SystemAppearance.none;
  DlmAppearance? _last;

  @override
  DlmAppearance get current => merge(_flutter.current, _reported);

  @override
  Stream<DlmAppearance> get changes => _changes.stream;

  void _emit() {
    final now = current;
    if (now == _last) return;
    _last = now;
    if (!_changes.isClosed) _changes.add(now);
  }

  /// Combines Flutter's view with the platform reader's.
  static DlmAppearance merge(DlmAppearance flutter, SystemAppearance system) {
    return DlmAppearance(
      brightness: system.brightness ?? flutter.brightness,
      contrast: system.highContrast || flutter.highContrast
          ? DlmContrast.high
          : DlmContrast.standard,
      accent: system.accent ?? flutter.accent,
      reduceMotion: system.reduceMotion || flutter.reduceMotion,
      reduceTransparency:
          system.reduceTransparency || flutter.reduceTransparency,
      textScale: flutter.textScale,
    );
  }

  @override
  void dispose() {
    unawaited(_flutterSub.cancel());
    unawaited(_systemSub.cancel());
    unawaited(_changes.close());
    _system.dispose();
    _flutter.dispose();
  }
}

/// The user's appearance preferences as a kit override.
AppearanceOverride appearanceOverrideFor({
  required ThemeChoice theme,
  required Density density,
  Color? accent,
  double textScale = 1,
}) => AppearanceOverride(
  mode: switch (theme) {
    ThemeChoice.system => DlmThemeMode.native,
    ThemeChoice.light => DlmThemeMode.light,
    ThemeChoice.dark => DlmThemeMode.dark,
  },
  density: switch (density) {
    Density.comfortable => DlmDensity.regular,
    Density.compact => DlmDensity.compact,
  },
  accent: accent,
  textScale: textScale,
);
