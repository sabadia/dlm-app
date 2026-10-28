import 'dart:ui';

import 'token_value.dart';

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
