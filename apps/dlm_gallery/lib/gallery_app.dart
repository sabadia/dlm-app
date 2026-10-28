import 'package:dlm_gallery/gallery_page.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// What the gallery's control panel sets; the gallery builds the whole system
/// appearance from it (it ignores the real OS settings on purpose, so any
/// combination can be inspected).
class GallerySettings {
  /// Creates settings; the defaults are the plain light look.
  const GallerySettings({
    this.skinIndex = 0,
    this.dark = false,
    this.highContrast = false,
    this.accent,
    this.density = DlmDensity.regular,
    this.textScale = 1,
    this.reduceMotion = false,
    this.reduceTransparency = false,
    this.section,
  });

  /// Index into the skin list.
  final int skinIndex;

  /// Dark colour scheme.
  final bool dark;

  /// High-contrast palette.
  final bool highContrast;

  /// System accent colour; null uses the skin's own.
  final Color? accent;

  /// Packing of controls.
  final DlmDensity density;

  /// Text scale factor.
  final double textScale;

  /// Reduce motion.
  final bool reduceMotion;

  /// Reduce transparency.
  final bool reduceTransparency;

  /// Title of the only section to show; null shows all.
  final String? section;

  /// A copy with the given fields replaced; [clearAccent] resets the accent.
  GallerySettings copyWith({
    int? skinIndex,
    bool? dark,
    bool? highContrast,
    Color? accent,
    bool clearAccent = false,
    DlmDensity? density,
    double? textScale,
    bool? reduceMotion,
    bool? reduceTransparency,
    String? section,
    bool clearSection = false,
  }) => GallerySettings(
    skinIndex: skinIndex ?? this.skinIndex,
    dark: dark ?? this.dark,
    highContrast: highContrast ?? this.highContrast,
    accent: clearAccent ? null : (accent ?? this.accent),
    density: density ?? this.density,
    textScale: textScale ?? this.textScale,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
    section: clearSection ? null : (section ?? this.section),
  );

  /// The system appearance these settings stand for.
  DlmAppearance get appearance => DlmAppearance(
    brightness: dark ? Brightness.dark : Brightness.light,
    contrast: highContrast ? DlmContrast.high : DlmContrast.standard,
    accent: accent,
    reduceMotion: reduceMotion,
    reduceTransparency: reduceTransparency,
    textScale: textScale,
  );
}

/// The gallery: a control panel and every kit component, under the chosen skin
/// and appearance.
class GalleryApp extends StatefulWidget {
  /// Creates the gallery for [skins].
  const GalleryApp({
    required this.skins,
    this.initial = const GallerySettings(),
    super.key,
  });

  /// The skins to choose from.
  final List<DlmSkin> skins;

  /// The settings the gallery starts with.
  final GallerySettings initial;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late GallerySettings _settings = widget.initial;
  late final ManualAppearanceSource _source = ManualAppearanceSource(
    _settings.appearance,
  );

  void _update(GallerySettings next) {
    setState(() => _settings = next);
    _source.update(next.appearance);
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin =
        widget.skins[_settings.skinIndex.clamp(0, widget.skins.length - 1)];
    return WidgetsApp(
      color: const Color(0xFF000000),
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      builder: (context, navigator) => DlmThemeScope(
        skin: skin,
        source: _source,
        userOverride: AppearanceOverride(density: _settings.density),
        child: navigator!,
      ),
      home: GalleryPage(
        skins: widget.skins,
        settings: _settings,
        onChanged: _update,
      ),
    );
  }
}
