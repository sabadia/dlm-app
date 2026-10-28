import 'package:flutter/animation.dart';

import 'token_value.dart';

/// Durations and curves of transitions.
class DlmMotion extends DlmTokenValue {
  /// Creates a [DlmMotion].
  const DlmMotion({
    this.fast = const Duration(milliseconds: 100),
    this.normal = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 350),
    this.standard = Curves.easeInOutCubic,
    this.enter = Curves.easeOutCubic,
    this.exit = Curves.easeInCubic,
  });

  /// No animation (reduce motion): zero durations.
  static const DlmMotion reduced = DlmMotion(
    fast: Duration.zero,
    normal: Duration.zero,
    slow: Duration.zero,
    standard: Curves.linear,
    enter: Curves.linear,
    exit: Curves.linear,
  );

  /// Hover, press and focus feedback.
  final Duration fast;

  /// Most transitions (selection, expand).
  final Duration normal;

  /// Panes and sheets sliding in.
  final Duration slow;

  /// Standard.
  final Curve standard;

  /// Enter.
  final Curve enter;

  /// Exit.
  final Curve exit;

  @override
  List<Object?> get props => [fast, normal, slow, standard, enter, exit];
}
