import 'dart:async';

import 'package:flutter/widgets.dart';

import '../components/components.dart';
import 'appearance.dart';
import 'appearance_source.dart';
import 'colors.dart';
import 'materials.dart';
import 'metrics.dart';
import 'motion.dart';
import 'shell.dart';
import 'skin.dart';
import 'token_value.dart';
import 'typography.dart';

/// The resolved theme widgets read through [DlmTheme.of].
class DlmThemeData extends DlmTokenValue {
  const DlmThemeData._({
    required this.skinId,
    required this.shell,
    required this.appearance,
    required this.density,
    required this.colors,
    required this.typography,
    required this.metrics,
    required this.materials,
    required this.motion,
    required this.components,
  });

  /// Builds the theme of [skin] for [appearance] and [density]: the skin's
  /// tokens with density, reduce-motion and reduce-transparency applied.
  factory DlmThemeData.resolve(
    DlmSkin skin,
    DlmAppearance appearance, {
    DlmDensity density = DlmDensity.regular,
  }) {
    final tokens = skin.tokens(appearance);
    return DlmThemeData._(
      skinId: skin.id,
      shell: skin.shell,
      appearance: appearance,
      density: density,
      colors: tokens.colors,
      typography: tokens.typography,
      metrics: tokens.metrics.scaled(density),
      materials: appearance.reduceTransparency
          ? DlmMaterials.opaque
          : tokens.materials,
      motion: appearance.reduceMotion ? DlmMotion.reduced : tokens.motion,
      components: skin.components,
    );
  }

  /// Skin id.
  final String skinId;

  /// Shell.
  final DlmShellPattern shell;

  /// Appearance.
  final DlmAppearance appearance;

  /// Density.
  final DlmDensity density;

  /// Colors.
  final DlmColors colors;

  /// Typography.
  final DlmTypography typography;

  /// Metrics.
  final DlmMetrics metrics;

  /// Materials.
  final DlmMaterials materials;

  /// Motion.
  final DlmMotion motion;

  /// The skin's component builders.
  final DlmComponents components;

  /// The fill behind the whole window. Transparent when the skin uses
  /// translucent materials and the window provides a backdrop effect (the app
  /// reports reduce-transparency when it does not); the window colour
  /// otherwise. Regions that are not translucent paint their own opaque
  /// colour on top.
  Color get windowBackground =>
      appearance.reduceTransparency ||
          !materials.all.any((m) => m.isTranslucent)
      ? colors.window
      : const Color(0x00000000);

  /// Height at the top of the content that the window controls cover (the
  /// macOS traffic lights over a transparent title bar); zero when the system
  /// draws the title bar outside the content.
  double get titleBarInset =>
      shell.titleBar == DlmTitleBarStyle.unifiedTransparent
      ? metrics.titleBarHeight
      : 0;

  /// Light or dark.
  Brightness get brightness => colors.brightness;

  @override
  List<Object?> get props => [
    skinId,
    shell,
    appearance,
    density,
    colors,
    typography,
    metrics,
    materials,
    motion,
    components,
  ];
}

/// Provides [DlmThemeData] to the widgets below it.
class DlmTheme extends InheritedWidget {
  /// Creates a [DlmTheme].
  const DlmTheme({required this.data, required super.child, super.key});

  /// Data.
  final DlmThemeData data;

  /// The theme in scope; asserts when there is none.
  static DlmThemeData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'No DlmThemeScope above this context.');
    return data!;
  }

  /// The theme in scope, or null when there is none.
  static DlmThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DlmTheme>()?.data;

  @override
  bool updateShouldNotify(DlmTheme oldWidget) => data != oldWidget.data;
}

/// Builds the theme from a skin, the system appearance and the user's
/// overrides, and rebuilds when any of them changes.
///
/// It also sets the text scaler and the animation preference of the
/// `MediaQuery` below it from the resolved appearance, so the user's text
/// scale and reduce-motion override apply to every widget, and provides the
/// default text style and icon theme so plain `Text` and icons follow the
/// skin.
class DlmThemeScope extends StatefulWidget {
  /// Creates a [DlmThemeScope].
  const DlmThemeScope({
    required this.skin,
    required this.source,
    required this.child,
    this.userOverride = AppearanceOverride.none,
    super.key,
  });

  /// Skin.
  final DlmSkin skin;

  /// Source.
  final AppearanceSource source;

  /// User override.
  final AppearanceOverride userOverride;

  /// Child.
  final Widget child;

  @override
  State<DlmThemeScope> createState() => _DlmThemeScopeState();
}

class _DlmThemeScopeState extends State<DlmThemeScope> {
  StreamSubscription<DlmAppearance>? _subscription;
  late DlmThemeData _data;

  @override
  void initState() {
    super.initState();
    _subscribe();
    _data = _resolve();
  }

  @override
  void didUpdateWidget(DlmThemeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _subscribe();
    final next = _resolve();
    if (next != _data) _data = next;
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = widget.source.changes.listen((_) {
      setState(() => _data = _resolve());
    });
  }

  DlmThemeData _resolve() => DlmThemeData.resolve(
    widget.skin,
    resolveAppearance(widget.source.current, widget.userOverride),
    density: widget.userOverride.density,
  );

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        MediaQuery.maybeOf(context) ??
        MediaQueryData.fromView(View.of(context));
    return MediaQuery(
      data: base.copyWith(
        textScaler: TextScaler.linear(_data.appearance.textScale),
        disableAnimations: _data.appearance.reduceMotion,
      ),
      child: DlmTheme(
        data: _data,
        child: DefaultTextStyle(
          style: _data.typography.body,
          child: IconTheme(
            data: IconThemeData(
              color: _data.colors.textSecondary,
              size: _data.metrics.icon,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
