import 'dart:ui' show Brightness;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';

import 'fluent_components.dart';

/// The Windows skin: Fluent tokens (Segoe UI Variable, 32 px controls, 4/8 px radii),
/// a NavigationView sidebar, a command bar and a custom caption title bar.
/// Mica or Acrylic is applied by the window (`dlm_platform`); Flutter draws the tint.
class FluentSkin extends DlmSkin {
  /// Creates the Windows Fluent skin.
  const FluentSkin();

  /// The accent used when the OS reports none: the brand accent.
  static const Color defaultAccent = dlmBrandAccent;

  @override
  String get id => 'fluent';

  @override
  DlmComponents get components => const FluentComponents();

  @override
  DlmShellPattern get shell => const DlmShellPattern(
    titleBar: DlmTitleBarStyle.customCaption,
    sidebar: DlmSidebarStyle.navigationPane,
    toolbar: DlmToolbarStyle.commandBar,
    settings: DlmSettingsStyle.settingsCards,
    feedback: DlmFeedbackStyle.infoBar,
    inspectorOnTrailingEdge: true,
    contentUnderTitleBar: false,
  );

  @override
  DlmTokens tokens(DlmAppearance appearance) {
    final dark = appearance.brightness == Brightness.dark;
    final high = appearance.highContrast;
    final content = dark ? const Color(0xFF272727) : const Color(0xFFFFFFFF);
    final window = dark ? const Color(0xFF202020) : const Color(0xFFF3F3F3);
    final text = high
        ? (dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
        : (dark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A));
    final secondary = high
        ? text
        : (dark ? const Color(0xFFC8C8C8) : const Color(0xFF5C5C5C));
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
      sidebar: dark ? const Color(0xFF2B2B2B) : const Color(0xFFEEEEEE),
      overlay: dark ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF),
      raised: dark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F9F9),
      text: text,
      textSecondary: secondary,
      textDisabled: dark ? const Color(0xFF777777) : const Color(0xFFA0A0A0),
      accent: accent,
      border: high
          ? text
          : (dark ? const Color(0xFF7A7A7A) : const Color(0xFF8A8A8A)),
    );

    TextStyle style(double size, [FontWeight weight = FontWeight.w400]) =>
        TextStyle(
          fontFamily: 'Segoe UI Variable Text',
          fontFamilyFallback: const ['Segoe UI', 'Noto Sans'],
          fontSize: size,
          fontWeight: weight,
          color: text,
          height: 1.3,
        );

    return DlmTokens(
      colors: colors,
      typography: DlmTypography(
        caption: style(12),
        body: style(14),
        bodyStrong: style(14, FontWeight.w600),
        label: style(14),
        subtitle: style(20, FontWeight.w600),
        title: style(28, FontWeight.w600),
        headline: style(40, FontWeight.w700),
        mono: style(14 - 1).copyWith(
          fontFamily: 'Cascadia Mono',
          fontFamilyFallback: const ['Consolas', 'Menlo'],
        ),
      ),
      metrics: const DlmMetrics(
        spacing: DlmSpacing(),
        radii: DlmRadii(small: 4, control: 4, container: 8, window: 0),
        controlHeightSmall: 24,
        controlHeight: 32,
        controlHeightLarge: 40,
        rowHeight: 40,
        minHitTarget: 24,
        borderWidth: 1,
        focusRingWidth: 2,
        focusRingOffset: 1,
        iconSmall: 14,
        icon: 16,
        iconLarge: 24,
        toolbarHeight: 48,
        titleBarHeight: 32,
        sidebarWidth: DlmRange(min: 200, ideal: 260, max: 360),
        inspectorWidth: DlmRange(min: 280, ideal: 320, max: 480),
      ),
      materials: const DlmMaterials(
        titleBar: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 30,
          tintOpacity: 0.8,
        ),
        sidebar: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 30,
          tintOpacity: 0.8,
        ),
        popover: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 30,
          tintOpacity: 0.9,
        ),
      ),
      motion: const DlmMotion(
        fast: Duration(milliseconds: 83),
        normal: Duration(milliseconds: 167),
        slow: Duration(milliseconds: 250),
      ),
    );
  }
}
