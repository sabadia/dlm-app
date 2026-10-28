import 'dart:async';

import 'package:dlm_gallery/gallery_page.dart';
import 'package:dlm_platform/dlm_platform.dart';
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
    this.effect = WindowEffect.glass,
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

  /// The window backdrop effect to request.
  final WindowEffect effect;

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
    WindowEffect? effect,
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
    effect: effect ?? this.effect,
  );

  /// The system appearance these settings stand for.
  DlmAppearance appearanceFor({required bool windowHasEffect}) => DlmAppearance(
    brightness: dark ? Brightness.dark : Brightness.light,
    contrast: highContrast ? DlmContrast.high : DlmContrast.standard,
    accent: accent,
    reduceMotion: reduceMotion,
    reduceTransparency: reduceTransparency || !windowHasEffect,
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
    this.chrome = const UnsupportedWindowChrome(),
    super.key,
  });

  /// The skins to choose from.
  final List<DlmSkin> skins;

  /// The settings the gallery starts with.
  final GallerySettings initial;

  /// The native window chrome (macOS glass); a no-op elsewhere.
  final WindowChrome chrome;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late GallerySettings _settings = widget.initial;
  WindowChromeResult _chrome = WindowChromeResult.none;
  late final ManualAppearanceSource _source = ManualAppearanceSource(
    _settings.appearanceFor(windowHasEffect: false),
  );

  DlmSkin get _skin =>
      widget.skins[_settings.skinIndex.clamp(0, widget.skins.length - 1)];

  @override
  void initState() {
    super.initState();
    // The window exists after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyChrome());
  }

  Future<void> _applyChrome() async {
    final shell = _skin.shell;
    try {
      final result = await widget.chrome.apply(
        WindowChromeConfig(
          transparentTitleBar:
              shell.titleBar == DlmTitleBarStyle.unifiedTransparent,
          effect: _settings.effect,
          brightness: _settings.dark ? Brightness.dark : Brightness.light,
        ),
      );
      if (!mounted) return;
      _chrome = result;
      _source.update(
        _settings.appearanceFor(
          windowHasEffect: result.effect != WindowEffect.none,
        ),
      );
    } on WindowChromeException {
      // The window was not ready; keep the opaque look.
    }
  }

  void _update(GallerySettings next) {
    final restyle =
        next.dark != _settings.dark ||
        next.effect != _settings.effect ||
        next.skinIndex != _settings.skinIndex;
    setState(() => _settings = next);
    _source.update(
      next.appearanceFor(windowHasEffect: _chrome.effect != WindowEffect.none),
    );
    if (restyle) unawaited(_applyChrome());
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      builder: (context, navigator) => DlmThemeScope(
        skin: _skin,
        source: _source,
        userOverride: AppearanceOverride(density: _settings.density),
        child: navigator!,
      ),
      home: GalleryPage(
        skins: widget.skins,
        settings: _settings,
        chrome: widget.chrome,
        onChanged: _update,
      ),
    );
  }
}
