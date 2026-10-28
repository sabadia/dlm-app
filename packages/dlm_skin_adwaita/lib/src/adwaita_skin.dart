import 'dart:ui' show Brightness;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';

import 'adwaita_components.dart';

/// The GNOME skin: libadwaita tokens (Adwaita Sans/Cantarell, 34 px buttons,
/// 6/12 px radii), header bars, a split-view sidebar and preferences rows.
/// All surfaces are opaque, as in libadwaita.
class AdwaitaSkin extends DlmSkin {
  /// Creates the GNOME Adwaita skin.
  const AdwaitaSkin();

  /// The accent used when the system reports none.
  static const Color defaultAccent = Color(0xFF3584E4);

  @override
  String get id => 'adwaita';

  @override
  DlmComponents get components => const AdwaitaComponents();

  @override
  DlmShellPattern get shell => const DlmShellPattern(
    titleBar: DlmTitleBarStyle.headerBar,
    sidebar: DlmSidebarStyle.splitView,
    toolbar: DlmToolbarStyle.headerBarActions,
    settings: DlmSettingsStyle.preferencesRows,
    feedback: DlmFeedbackStyle.toastOverlay,
    inspectorOnTrailingEdge: true,
    contentUnderTitleBar: false,
  );

  @override
  DlmTokens tokens(DlmAppearance appearance) {
    final dark = appearance.brightness == Brightness.dark;
    final high = appearance.highContrast;
    final content = dark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final window = dark ? const Color(0xFF242424) : const Color(0xFFFAFAFA);
    final text = high
        ? (dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
        : (dark ? const Color(0xFFFFFFFF) : const Color(0xFF2E2E2E));
    final secondary = high
        ? text
        : (dark ? const Color(0xFFC0BFBC) : const Color(0xFF5E5C64));
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
      sidebar: dark ? const Color(0xFF303030) : const Color(0xFFEBEBEB),
      overlay: dark ? const Color(0xFF383838) : const Color(0xFFFFFFFF),
      raised: dark ? const Color(0xFF303030) : const Color(0xFFFFFFFF),
      text: text,
      textSecondary: secondary,
      textDisabled: dark ? const Color(0xFF77767B) : const Color(0xFF9A9996),
      accent: accent,
      border: high
          ? text
          : (dark ? const Color(0xFF77767B) : const Color(0xFF8D8B93)),
    );

    TextStyle style(double size, [FontWeight weight = FontWeight.w400]) =>
        TextStyle(
          fontFamily: 'Adwaita Sans',
          fontFamilyFallback: const ['Cantarell', 'Noto Sans', 'DejaVu Sans'],
          fontSize: size,
          fontWeight: weight,
          color: text,
          height: 1.3,
        );

    return DlmTokens(
      colors: colors,
      typography: DlmTypography(
        caption: style(12),
        body: style(15),
        bodyStrong: style(15, FontWeight.w600),
        label: style(15),
        subtitle: style(17, FontWeight.w600),
        title: style(20, FontWeight.w600),
        headline: style(28, FontWeight.w700),
        mono: style(15 - 1).copyWith(
          fontFamily: 'Adwaita Mono',
          fontFamilyFallback: const ['Source Code Pro', 'DejaVu Sans Mono'],
        ),
      ),
      metrics: const DlmMetrics(
        spacing: DlmSpacing(),
        radii: DlmRadii(small: 6, control: 6, container: 12, window: 12),
        controlHeightSmall: 26,
        controlHeight: 34,
        controlHeightLarge: 42,
        rowHeight: 50,
        minHitTarget: 24,
        borderWidth: 1,
        focusRingWidth: 2,
        focusRingOffset: 1,
        iconSmall: 14,
        icon: 16,
        iconLarge: 24,
        toolbarHeight: 47,
        titleBarHeight: 47,
        sidebarWidth: DlmRange(min: 200, ideal: 260, max: 360),
        inspectorWidth: DlmRange(min: 280, ideal: 320, max: 480),
      ),
      materials: DlmMaterials.opaque,
      motion: const DlmMotion(),
    );
  }
}
