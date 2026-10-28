import 'dart:ui' show Brightness;

import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/painting.dart';

/// A minimal conforming skin for the kit's own tests. [tweak] lets a test
/// break one token to prove the validator notices.
class TestSkin extends DlmSkin {
  const TestSkin({this.skinId = 'test', this.tweak});

  final String skinId;
  final DlmTokens Function(DlmTokens tokens)? tweak;

  @override
  String get id => skinId;

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
    final window = dark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
    final content = dark ? const Color(0xFF252525) : const Color(0xFFFFFFFF);
    final text = dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondary = high
        ? text
        : dark
        ? const Color(0xFFC8C8C8)
        : const Color(0xFF4A4A4A);
    final palette = AccentPalette.derive(
      appearance.accent ?? const Color(0xFF0A5FCC),
      surface: content,
      minTextContrast: high ? 7 : 4.5,
      minOnAccentContrast: high ? 7 : 4.5,
      dark: dark,
    );
    final colors = DlmColors(
      brightness: appearance.brightness,
      highContrast: high,
      window: window,
      content: content,
      raised: content,
      sidebar: window,
      overlay: content,
      textPrimary: text,
      textSecondary: secondary,
      textDisabled: const Color(0xFF8A8A8A),
      textOnAccent: palette.onAccent,
      textLink: palette.accentText,
      accent: palette.accent,
      accentSubtle: palette.accentSubtle,
      separator: const Color(0x33808080),
      border: high ? text : const Color(0xFF9A9A9A),
      focusRing: palette.accentText,
      controlFill: content,
      controlFillHover: window,
      controlFillPressed: window,
      controlFillDisabled: window,
      rowHover: const Color(0x14808080),
      selection: palette.accentSubtle,
      selectionInactive: const Color(0x26808080),
      scrim: const Color(0x66000000),
      success: ensureContrast(const Color(0xFF2E9B4F), content, minRatio: 7),
      warning: ensureContrast(const Color(0xFFB36B00), content, minRatio: 7),
      danger: ensureContrast(const Color(0xFFD13438), content, minRatio: 7),
      info: ensureContrast(const Color(0xFF0A5FCC), content, minRatio: 7),
    );
    TextStyle style(double size, [FontWeight weight = FontWeight.w400]) =>
        TextStyle(fontSize: size, fontWeight: weight, color: text);
    final tokens = DlmTokens(
      colors: colors,
      typography: DlmTypography(
        caption: style(11),
        body: style(13),
        bodyStrong: style(13, FontWeight.w600),
        label: style(13),
        subtitle: style(15, FontWeight.w600),
        title: style(20, FontWeight.w600),
        headline: style(28, FontWeight.w600),
        mono: style(12),
      ),
      metrics: const DlmMetrics(
        spacing: DlmSpacing(),
        radii: DlmRadii(small: 3, control: 5, container: 8, window: 0),
        controlHeightSmall: 24,
        controlHeight: 28,
        controlHeightLarge: 36,
        rowHeight: 32,
        minHitTarget: 24,
        borderWidth: 1,
        focusRingWidth: 2,
        focusRingOffset: 1,
        iconSmall: 14,
        icon: 16,
        iconLarge: 24,
        toolbarHeight: 40,
        titleBarHeight: 32,
        sidebarWidth: DlmRange(min: 180, ideal: 220, max: 320),
        inspectorWidth: DlmRange(min: 260, ideal: 320, max: 480),
      ),
      materials: const DlmMaterials(
        sidebar: DlmMaterial(
          kind: DlmMaterialKind.translucent,
          blurSigma: 20,
          tintOpacity: 0.7,
        ),
      ),
      motion: const DlmMotion(),
    );
    return tweak?.call(tokens) ?? tokens;
  }
}
