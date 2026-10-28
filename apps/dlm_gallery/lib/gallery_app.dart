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
    this.useSystemAccent = false,
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

  /// Use the operating system's accent colour instead of [accent].
  final bool useSystemAccent;

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
    bool? useSystemAccent,
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
    useSystemAccent: useSystemAccent ?? this.useSystemAccent,
  );

  /// The system appearance these settings stand for.
  DlmAppearance appearanceFor({
    required bool windowHasEffect,
    SystemAppearance system = SystemAppearance.none,
  }) => DlmAppearance(
    brightness: dark ? Brightness.dark : Brightness.light,
    contrast: highContrast || system.highContrast
        ? DlmContrast.high
        : DlmContrast.standard,
    accent: useSystemAccent ? system.accent : accent,
    reduceMotion: reduceMotion || system.reduceMotion,
    reduceTransparency:
        reduceTransparency || system.reduceTransparency || !windowHasEffect,
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
    this.system = const UnsupportedSystemAppearance(),
    super.key,
  });

  /// The skins to choose from.
  final List<DlmSkin> skins;

  /// The settings the gallery starts with.
  final GallerySettings initial;

  /// The native window chrome (macOS glass); a no-op elsewhere.
  final WindowChrome chrome;

  /// The system accent and accessibility options.
  final SystemAppearanceReader system;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late GallerySettings _settings = widget.initial;
  WindowChromeResult _chrome = WindowChromeResult.none;
  SystemAppearance _system = SystemAppearance.none;
  StreamSubscription<SystemAppearance>? _systemSub;
  late final ManualAppearanceSource _source = ManualAppearanceSource(
    _settings.appearanceFor(windowHasEffect: false),
  );

  DlmAppearance _appearance() => _settings.appearanceFor(
    windowHasEffect: _chrome.effect != WindowEffect.none,
    system: _system,
  );

  DlmSkin get _skin =>
      widget.skins[_settings.skinIndex.clamp(0, widget.skins.length - 1)];

  @override
  void initState() {
    super.initState();
    // The window exists after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyChrome());
    _systemSub = widget.system.changes.listen((s) {
      _system = s;
      _source.update(_appearance());
    });
    unawaited(
      widget.system.read().then((s) {
        if (!mounted) return;
        _system = s;
        _source.update(_appearance());
      }),
    );
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
      _source.update(_appearance());
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
    _source.update(_appearance());
    if (restyle) unawaited(_applyChrome());
  }

  @override
  void dispose() {
    unawaited(_systemSub?.cancel());
    _source.dispose();
    super.dispose();
  }

  /// The system-provided macOS menus (localised by macOS itself); empty where
  /// the platform has none. The app's own menus come with F5.9.
  List<PlatformMenuItem> _menus() {
    List<PlatformProvidedMenuItem> provided(
      List<PlatformProvidedMenuItemType> types,
    ) => [
      for (final t in types)
        if (PlatformProvidedMenuItem.hasMenu(t))
          PlatformProvidedMenuItem(type: t),
    ];
    final app = provided(const [PlatformProvidedMenuItemType.about]);
    final hide = provided(const [
      PlatformProvidedMenuItemType.hide,
      PlatformProvidedMenuItemType.hideOtherApplications,
    ]);
    final quit = provided(const [PlatformProvidedMenuItemType.quit]);
    final window = provided(const [
      PlatformProvidedMenuItemType.minimizeWindow,
      PlatformProvidedMenuItemType.zoomWindow,
      PlatformProvidedMenuItemType.toggleFullScreen,
    ]);
    if (app.isEmpty && quit.isEmpty) return const [];
    return [
      PlatformMenu(
        label: 'dlm gallery',
        menus: [
          ...app,
          if (hide.isNotEmpty) PlatformMenuItemGroup(members: hide),
          ...quit,
        ],
      ),
      if (window.isNotEmpty) PlatformMenu(label: 'Window', menus: window),
    ];
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
      builder: (context, navigator) {
        final scoped = DlmThemeScope(
          skin: _skin,
          source: _source,
          userOverride: AppearanceOverride(density: _settings.density),
          child: navigator!,
        );
        final menus = _menus();
        return menus.isEmpty
            ? scoped
            : PlatformMenuBar(menus: menus, child: scoped);
      },
      home: GalleryPage(
        skins: widget.skins,
        settings: _settings,
        chrome: widget.chrome,
        onChanged: _update,
      ),
    );
  }
}
