import 'dart:ui' show Brightness;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';

/// The macOS skin: system-style colours, SF type, 13 pt body, unified toolbar
/// and a translucent sidebar. Window-level glass is applied by the native
/// window (see `dlm_platform` window chrome); Flutter draws the tint.
class MacosSkin extends DlmSkin {
  /// Creates the macOS skin.
  const MacosSkin();

  /// The accent used when the OS reports none: the brand accent.
  static const Color defaultAccent = dlmBrandAccent;

  @override
  String get id => 'macos';

  @override
  DlmShellPattern get shell => const DlmShellPattern(
    titleBar: DlmTitleBarStyle.unifiedTransparent,
    sidebar: DlmSidebarStyle.translucentSource,
    toolbar: DlmToolbarStyle.unified,
    settings: DlmSettingsStyle.insetGroups,
    feedback: DlmFeedbackStyle.floatingBanner,
    inspectorOnTrailingEdge: true,
    contentUnderTitleBar: true,
  );

  @override
  DlmTokens tokens(DlmAppearance appearance) {
    final dark = appearance.brightness == Brightness.dark;
    final high = appearance.highContrast;
    final content = dark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final window = dark ? const Color(0xFF2A2A2A) : const Color(0xFFECECEC);
    final text = high
        ? (dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
        : (dark ? const Color(0xFFF2F2F2) : const Color(0xFF1D1D1F));
    final secondary = high
        ? text
        : (dark ? const Color(0xFFAEAEB2) : const Color(0xFF636366));
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
      sidebar: dark ? const Color(0xFF2F2F31) : const Color(0xFFE4E4E6),
      overlay: dark ? const Color(0xFF323234) : const Color(0xFFFFFFFF),
      raised: dark ? const Color(0xFF262628) : const Color(0xFFFAFAFA),
      text: text,
      textSecondary: secondary,
      textDisabled: dark ? const Color(0xFF6E6E73) : const Color(0xFFAAAAAE),
      accent: accent,
      border: high
          ? text
          : (dark ? const Color(0xFF636366) : const Color(0xFFB4B4B8)),
      success: const Color(0xFF248A3D),
      warning: const Color(0xFFB25000),
      danger: const Color(0xFFD70015),
      info: const Color(0xFF0071E3),
    );

    TextStyle style(double size, [FontWeight weight = FontWeight.w400]) =>
        TextStyle(
          fontFamily: '.AppleSystemUIFont',
          fontFamilyFallback: const ['SF Pro Text', 'Helvetica Neue'],
          fontSize: size,
          fontWeight: weight,
          color: text,
          height: 1.25,
        );

    return DlmTokens(
      colors: colors,
      typography: DlmTypography(
        caption: style(11),
        body: style(13),
        bodyStrong: style(13, FontWeight.w600),
        label: style(13),
        subtitle: style(15, FontWeight.w600),
        title: style(22, FontWeight.w600),
        headline: style(28, FontWeight.w700),
        mono: style(12).copyWith(
          fontFamily: 'SF Mono',
          fontFamilyFallback: const ['Menlo', 'Monaco'],
        ),
      ),
      metrics: const DlmMetrics(
        spacing: DlmSpacing(),
        radii: DlmRadii(small: 5, control: 8, container: 14, window: 0),
        controlHeightSmall: 24,
        controlHeight: 28,
        controlHeightLarge: 34,
        rowHeight: 28,
        minHitTarget: 24,
        borderWidth: 1,
        focusRingWidth: 3,
        focusRingOffset: 0,
        iconSmall: 14,
        icon: 16,
        iconLarge: 22,
        toolbarHeight: 52,
        titleBarHeight: 28,
        sidebarWidth: DlmRange(min: 200, ideal: 240, max: 320),
        inspectorWidth: DlmRange(min: 280, ideal: 320, max: 480),
      ),
      materials: const DlmMaterials(
        titleBar: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 24,
          tintOpacity: 0.78,
        ),
        toolbar: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 24,
          tintOpacity: 0.78,
        ),
        sidebar: DlmMaterial(
          kind: DlmMaterialKind.glass,
          blurSigma: 30,
          tintOpacity: 0.62,
        ),
        popover: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 30,
          tintOpacity: 0.86,
        ),
      ),
      motion: const DlmMotion(
        fast: Duration(milliseconds: 120),
        normal: Duration(milliseconds: 220),
        slow: Duration(milliseconds: 380),
      ),
    );
  }
}
