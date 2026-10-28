import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// WCAG 2.x contrast ratio between two opaque colours, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Returns [foreground], moved toward black or white in small steps of
/// lightness until it reaches [minRatio] against [background].
///
/// The direction is the one with more room (away from the background's
/// luminance). Returns the best reachable colour if the ratio cannot be met.
Color ensureContrast(
  Color foreground,
  Color background, {
  double minRatio = 4.5,
}) {
  if (contrastRatio(foreground, background) >= minRatio) return foreground;
  final towardWhite = background.computeLuminance() < 0.5;
  final hsl = HSLColor.fromColor(foreground);
  var lightness = hsl.lightness;
  var candidate = foreground;
  while (contrastRatio(candidate, background) < minRatio) {
    lightness += towardWhite ? 0.02 : -0.02;
    if (lightness < 0 || lightness > 1) {
      return towardWhite ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    }
    candidate = hsl.withLightness(lightness).toColor();
  }
  return candidate;
}

/// Colours derived from one accent colour, so every skin handles a system or
/// user accent the same way.
class AccentPalette {
  const AccentPalette._({
    required this.accent,
    required this.onAccent,
    required this.accentSubtle,
    required this.accentText,
  });

  /// Derives the palette from [accent] for text and controls drawn on
  /// [surface].
  ///
  /// - [accent] is the fill of selected and primary controls, as given.
  /// - [onAccent] is black or white, whichever reads better on [accent]
  ///   (at least 4.5:1 for any accent).
  /// - When [minOnAccentContrast] is higher than the accent allows (7 in
  ///   high contrast), the accent fill is moved toward black or white until
  ///   [onAccent] reaches it; otherwise the accent is returned as given.
  /// - [accentSubtle] is a translucent tint for selection backgrounds.
  /// - [accentText] is the accent adjusted to be readable as text or an
  ///   outline on [surface] ([minTextContrast], 3 for outlines, 4.5 for
  ///   text).
  factory AccentPalette.derive(
    Color accent, {
    required Color surface,
    double minTextContrast = 4.5,
    double minOnAccentContrast = 4.5,
    bool dark = false,
  }) {
    final given = accent.withValues(alpha: 1);
    const white = Color(0xFFFFFFFF);
    const black = Color(0xFF000000);
    final onAccent = contrastRatio(white, given) >= contrastRatio(black, given)
        ? white
        : black;
    final opaque = ensureContrast(
      given,
      onAccent,
      minRatio: minOnAccentContrast,
    );
    return AccentPalette._(
      accent: opaque,
      onAccent: onAccent,
      accentSubtle: opaque.withValues(alpha: dark ? 0.24 : 0.16),
      accentText: ensureContrast(opaque, surface, minRatio: minTextContrast),
    );
  }

  /// Accent.
  final Color accent;

  /// On accent.
  final Color onAccent;

  /// Accent subtle.
  final Color accentSubtle;

  /// Accent text.
  final Color accentText;
}
