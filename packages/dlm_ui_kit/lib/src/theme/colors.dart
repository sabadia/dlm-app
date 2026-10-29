import 'dart:ui';

import 'contrast.dart';
import 'token_value.dart';

/// The brand accent: used by every skin when the operating system reports no
/// accent of its own (and never over one it does report).
const Color dlmBrandAccent = Color(0xFF4F5BD5);

/// Semantic colour roles. Widgets use roles, never literal colours.
///
/// The five surfaces are always opaque: a skin whose sidebar is translucent
/// supplies the opaque colour used when the material is unavailable (reduce
/// transparency, no window effect) and describes the translucency in
/// `DlmMaterials`.
class DlmColors extends DlmTokenValue {
  /// Creates a [DlmColors].
  const DlmColors({
    required this.brightness,
    required this.highContrast,
    required this.window,
    required this.content,
    required this.raised,
    required this.sidebar,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnAccent,
    required this.textLink,
    required this.accent,
    required this.accentSubtle,
    required this.separator,
    required this.border,
    required this.focusRing,
    required this.controlFill,
    required this.controlFillHover,
    required this.controlFillPressed,
    required this.controlFillDisabled,
    required this.rowHover,
    required this.selection,
    required this.selectionInactive,
    required this.scrim,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  /// Builds a complete palette from the handful of colours a skin actually
  /// decides, deriving the rest (hover and pressed fills, separators,
  /// selection, status colours) so every skin treats them the same way.
  ///
  /// [text] is the primary text colour; [window] and [content] are opaque.
  /// Surfaces left null reuse [content] (or [window] for the sidebar). Status
  /// colours are moved until they reach 3:1 on [content] (4.5:1 in high
  /// contrast). [accent] is the already derived palette (see
  /// `AccentPalette.derive`).
  factory DlmColors.derive({
    required Brightness brightness,
    required bool highContrast,
    required Color window,
    required Color content,
    required Color text,
    required Color textSecondary,
    required Color textDisabled,
    required AccentPalette accent,
    required Color border,
    Color? raised,
    Color? sidebar,
    Color? overlay,
    Color? separator,
    Color success = const Color(0xFF2E9B4F),
    Color warning = const Color(0xFFB36B00),
    Color danger = const Color(0xFFD13438),
    Color info = const Color(0xFF0A5FCC),
  }) {
    final dark = brightness == Brightness.dark;
    final controlFill = content;
    Color tint(Color base, double a) =>
        Color.alphaBlend(text.withValues(alpha: a), base);
    final graphics = highContrast ? 4.5 : 3.0;
    // Accent-coloured text (plain buttons, links) sits on the window, the
    // sidebar, cards and the content: it must be readable on every one.
    var linkOnAll = accent.accentText;
    for (final surface in [
      window,
      sidebar ?? window,
      raised ?? content,
      content,
    ]) {
      linkOnAll = ensureContrast(
        linkOnAll,
        surface,
        minRatio: highContrast ? 7.0 : 4.5,
      );
    }
    return DlmColors(
      brightness: brightness,
      highContrast: highContrast,
      window: window,
      content: content,
      raised: raised ?? content,
      sidebar: sidebar ?? window,
      overlay: overlay ?? content,
      textPrimary: text,
      textSecondary: textSecondary,
      textDisabled: textDisabled,
      textOnAccent: accent.onAccent,
      textLink: linkOnAll,
      accent: accent.accent,
      accentSubtle: accent.accentSubtle,
      separator: separator ?? text.withValues(alpha: highContrast ? 0.6 : 0.12),
      border: border,
      focusRing: accent.accentText,
      controlFill: controlFill,
      controlFillHover: tint(controlFill, 0.06),
      controlFillPressed: tint(controlFill, 0.12),
      controlFillDisabled: tint(window, 0.04),
      rowHover: text.withValues(alpha: 0.05),
      selection: accent.accentSubtle,
      selectionInactive: text.withValues(alpha: 0.14),
      scrim: Color(dark ? 0x8C000000 : 0x66000000),
      success: ensureContrast(success, content, minRatio: graphics),
      warning: ensureContrast(warning, content, minRatio: graphics),
      danger: ensureContrast(danger, content, minRatio: graphics),
      info: ensureContrast(info, content, minRatio: graphics),
    );
  }

  /// Light or dark.
  final Brightness brightness;

  /// Whether this is the skin's high-contrast variant.
  final bool highContrast;

  // Surfaces.
  /// Behind everything: the window background.
  final Color window;

  /// The main content area (lists, pages).
  final Color content;

  /// Cards, grouped form sections, table headers.
  final Color raised;

  /// The sidebar (opaque fallback of its material).
  final Color sidebar;

  /// Popovers, menus, dialogs and sheets.
  final Color overlay;

  // Text.
  /// Default text.
  final Color textPrimary;

  /// Secondary text.
  final Color textSecondary;

  /// Disabled text: exempt from contrast rules, still legible.
  final Color textDisabled;

  /// Text on an [accent] fill.
  final Color textOnAccent;

  /// Links and text-weight accent uses on [content].
  final Color textLink;

  // Accent.
  /// Accent fill of selected and primary controls.
  final Color accent;

  /// Translucent tint of the accent (selection background).
  final Color accentSubtle;

  // Lines.
  /// Hairline between regions and rows.
  final Color separator;

  /// Outline of controls.
  final Color border;

  /// Keyboard focus indicator.
  final Color focusRing;

  // Controls and rows.
  /// Control fill.
  final Color controlFill;

  /// Control fill hover.
  final Color controlFillHover;

  /// Control fill pressed.
  final Color controlFillPressed;

  /// Control fill disabled.
  final Color controlFillDisabled;

  /// Row hover.
  final Color rowHover;

  /// Selected row in the focused window.
  final Color selection;

  /// Selected row when the window or list is inactive.
  final Color selectionInactive;

  /// Dim layer behind modal dialogs.
  final Color scrim;

  // Status.
  /// Completed and healthy states.
  final Color success;

  /// States that need attention.
  final Color warning;

  /// Errors and destructive actions.
  final Color danger;

  /// Neutral information.
  final Color info;

  /// The surfaces, for validation and iteration.
  List<Color> get surfaces => [window, content, raised, sidebar, overlay];

  @override
  List<Object?> get props => [
    brightness,
    highContrast,
    window,
    content,
    raised,
    sidebar,
    overlay,
    textPrimary,
    textSecondary,
    textDisabled,
    textOnAccent,
    textLink,
    accent,
    accentSubtle,
    separator,
    border,
    focusRing,
    controlFill,
    controlFillHover,
    controlFillPressed,
    controlFillDisabled,
    rowHover,
    selection,
    selectionInactive,
    scrim,
    success,
    warning,
    danger,
    info,
  ];
}
