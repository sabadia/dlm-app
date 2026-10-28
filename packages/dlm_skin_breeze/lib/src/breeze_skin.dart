import 'dart:ui' show Brightness;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';

import 'breeze_components.dart';

/// The KDE skin: Breeze tokens (Noto Sans 10 pt, 30 px controls, 5 px radii),
/// a list-pane sidebar, a tool bar and System-Settings-style pages. The window
/// manager draws the title bar.
class BreezeSkin extends DlmSkin {
  /// Creates the KDE Breeze skin.
  const BreezeSkin();

  /// The accent used when the system reports none.
  static const Color defaultAccent = Color(0xFF1F7FC4);

  @override
  String get id => 'breeze';

  @override
  DlmComponents get components => const BreezeComponents();

  @override
  DlmShellPattern get shell => const DlmShellPattern(
    titleBar: DlmTitleBarStyle.system,
    sidebar: DlmSidebarStyle.listPane,
    toolbar: DlmToolbarStyle.toolBar,
    settings: DlmSettingsStyle.systemSettingsPages,
    feedback: DlmFeedbackStyle.inlineMessage,
    inspectorOnTrailingEdge: true,
    contentUnderTitleBar: false,
  );

  @override
  DlmTokens tokens(DlmAppearance appearance) {
    final dark = appearance.brightness == Brightness.dark;
    final high = appearance.highContrast;
    final content = dark ? const Color(0xFF232629) : const Color(0xFFFCFCFC);
    final window = dark ? const Color(0xFF31363B) : const Color(0xFFEFF0F1);
    final text = high
        ? (dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
        : (dark ? const Color(0xFFFCFCFC) : const Color(0xFF232629));
    final secondary = high
        ? text
        : (dark ? const Color(0xFFBDC3C7) : const Color(0xFF5B6368));
    final accent = AccentPalette.derive(
      appearance.accent ?? defaultAccent,
      surface: content,
      minTextContrast: high ? 7 : 4.5,
      minOnAccentContrast: high ? 7 : 4.5,
      dark: dark,
    );
    final colors = DlmColors.derive(
      brightness: appearance.brightness,
      highContrast: high,
      window: window,
      content: content,
      sidebar: dark ? const Color(0xFF2A2E32) : const Color(0xFFE6E8EA),
      overlay: dark ? const Color(0xFF31363B) : const Color(0xFFFCFCFC),
      raised: dark ? const Color(0xFF2A2E32) : const Color(0xFFF7F7F7),
      text: text,
      textSecondary: secondary,
      textDisabled: dark ? const Color(0xFF7F8C8D) : const Color(0xFFA4A9AD),
      accent: accent,
      border: high
          ? text
          : (dark ? const Color(0xFF7F8C8D) : const Color(0xFF8E9296)),
    );

    TextStyle style(double size, [FontWeight weight = FontWeight.w400]) =>
        TextStyle(
          fontFamily: 'Noto Sans',
          fontFamilyFallback: const ['Segoe UI', 'DejaVu Sans'],
          fontSize: size,
          fontWeight: weight,
          color: text,
          height: 1.3,
        );

    return DlmTokens(
      colors: colors,
      typography: DlmTypography(
        caption: style(11),
        body: style(13),
        bodyStrong: style(13, FontWeight.w600),
        label: style(13),
        subtitle: style(15, FontWeight.w600),
        title: style(20, FontWeight.w600),
        headline: style(26, FontWeight.w700),
        mono: style(13 - 1).copyWith(
          fontFamily: 'Hack',
          fontFamilyFallback: const ['Noto Sans Mono', 'DejaVu Sans Mono'],
        ),
      ),
      metrics: const DlmMetrics(
        spacing: DlmSpacing(),
        radii: DlmRadii(small: 3, control: 5, container: 6, window: 0),
        controlHeightSmall: 24,
        controlHeight: 30,
        controlHeightLarge: 36,
        rowHeight: 28,
        minHitTarget: 24,
        borderWidth: 1,
        focusRingWidth: 2,
        focusRingOffset: 0,
        iconSmall: 14,
        icon: 16,
        iconLarge: 24,
        toolbarHeight: 42,
        titleBarHeight: 28,
        sidebarWidth: DlmRange(min: 180, ideal: 240, max: 320),
        inspectorWidth: DlmRange(min: 280, ideal: 320, max: 480),
      ),
      materials: DlmMaterials.opaque,
      motion: const DlmMotion(),
    );
  }
}
