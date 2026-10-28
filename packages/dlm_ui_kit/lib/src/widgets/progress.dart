import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// Drives the moving segment of an indeterminate indicator; static under
/// reduce motion.
mixin _IndeterminateTicker<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  AnimationController? _controller;

  /// 0..1, repeating, or a fixed value when not animating.
  double get phase => _controller?.value ?? 0.35;

  void syncTicker({required bool animate}) {
    if (animate && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..addListener(() => setState(() {}));
      _controller!.repeat();
    } else if (!animate && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  void disposeTicker() => _controller?.dispose();
}

/// A horizontal progress bar. [value] is 0..1; null means indeterminate.
class DlmProgressBar extends StatefulWidget {
  /// Creates a progress bar.
  const DlmProgressBar({
    required this.value,
    this.tone = DlmTone.neutral,
    this.semanticLabel,
    super.key,
  });

  /// Completed fraction, or null when unknown.
  final double? value;

  /// The colour meaning.
  final DlmTone tone;

  /// Accessible name.
  final String? semanticLabel;

  @override
  State<DlmProgressBar> createState() => _DlmProgressBarState();
}

class _DlmProgressBarState extends State<DlmProgressBar>
    with TickerProviderStateMixin, _IndeterminateTicker {
  @override
  void dispose() {
    disposeTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    syncTicker(animate: widget.value == null && !theme.appearance.reduceMotion);
    final v = widget.value;
    return Semantics(
      label: widget.semanticLabel,
      value: v == null ? null : '${(v.clamp(0, 1) * 100).round()}%',
      child: ExcludeSemantics(
        child: theme.components.progressBar(
          context,
          value: v,
          phase: phase,
          tone: widget.tone,
        ),
      ),
    );
  }
}

/// A circular progress indicator. [value] is 0..1; null means indeterminate.
class DlmProgressRing extends StatefulWidget {
  /// Creates a progress ring.
  const DlmProgressRing({
    required this.value,
    this.size = 20,
    this.tone = DlmTone.neutral,
    this.semanticLabel,
    super.key,
  });

  /// Completed fraction, or null when unknown.
  final double? value;

  /// Edge length.
  final double size;

  /// The colour meaning.
  final DlmTone tone;

  /// Accessible name.
  final String? semanticLabel;

  @override
  State<DlmProgressRing> createState() => _DlmProgressRingState();
}

class _DlmProgressRingState extends State<DlmProgressRing>
    with TickerProviderStateMixin, _IndeterminateTicker {
  @override
  void dispose() {
    disposeTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    syncTicker(animate: widget.value == null && !theme.appearance.reduceMotion);
    final v = widget.value;
    return Semantics(
      label: widget.semanticLabel,
      value: v == null ? null : '${(v.clamp(0, 1) * 100).round()}%',
      child: ExcludeSemantics(
        child: theme.components.progressRing(
          context,
          value: v,
          phase: phase,
          tone: widget.tone,
          size: widget.size,
        ),
      ),
    );
  }
}
