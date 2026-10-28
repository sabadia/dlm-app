import 'package:flutter/painting.dart';

import 'token_value.dart';

/// The type scale. Styles carry the skin's font and the text colours of the
/// resolved theme; sizes are unscaled (the OS text scale is applied by
/// `MediaQuery.textScaler`).
class DlmTypography extends DlmTokenValue {
  /// Creates a [DlmTypography].
  const DlmTypography({
    required this.caption,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.subtitle,
    required this.title,
    required this.headline,
    required this.mono,
  });

  /// Secondary and helper text.
  final TextStyle caption;

  /// Default reading text.
  final TextStyle body;

  /// Emphasised body text (row titles).
  final TextStyle bodyStrong;

  /// Control labels.
  final TextStyle label;

  /// Section headings.
  final TextStyle subtitle;

  /// Page titles.
  final TextStyle title;

  /// Large headings (empty states, onboarding).
  final TextStyle headline;

  /// Paths, hashes, URLs, logs.
  final TextStyle mono;

  /// The styles from smallest to largest, for validation.
  List<TextStyle> get scale => [caption, body, subtitle, title, headline];

  @override
  List<Object?> get props => [
    caption,
    body,
    bodyStrong,
    label,
    subtitle,
    title,
    headline,
    mono,
  ];
}
