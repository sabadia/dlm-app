import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/theme.dart';
import 'button.dart';
import 'icon.dart';
import 'progress.dart';

Widget _centered(BuildContext context, List<Widget> children) {
  final theme = DlmTheme.of(context);
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: EdgeInsets.all(theme.metrics.spacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    ),
  );
}

/// What a list or page shows when there is nothing to show.
class DlmEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const DlmEmptyState({
    required this.title,
    this.message,
    this.icon,
    this.action,
    super.key,
  });

  /// Headline.
  final String title;

  /// One or two sentences saying what to do.
  final String? message;

  /// A large icon above the title.
  final Widget? icon;

  /// A primary action button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final gap = SizedBox(height: theme.metrics.spacing.md);
    return Semantics(
      container: true,
      child: _centered(context, [
        if (icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(
              size: theme.metrics.iconLarge * 2,
              color: theme.colors.textDisabled,
            ),
            child: icon!,
          ),
          gap,
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.typography.subtitle,
        ),
        if (message != null) ...[
          SizedBox(height: theme.metrics.spacing.xs),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ],
        if (action != null) ...[gap, action!],
      ]),
    );
  }
}

/// A failed load, with an optional retry.
class DlmErrorState extends StatelessWidget {
  /// Creates an error state.
  const DlmErrorState({
    required this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
    super.key,
  }) : assert(
         onRetry == null || retryLabel != null,
         'A retry action needs a localised retryLabel.',
       );

  /// Headline.
  final String title;

  /// What went wrong, in words the user can act on.
  final String? message;

  /// Text of the retry button.
  final String? retryLabel;

  /// Called when the user asks to retry.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: _centered(context, [
        DlmIcon(
          DlmIconName.error,
          size: theme.metrics.iconLarge * 2,
          color: theme.colors.danger,
        ),
        SizedBox(height: theme.metrics.spacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.typography.subtitle,
        ),
        if (message != null) ...[
          SizedBox(height: theme.metrics.spacing.xs),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ],
        if (onRetry != null) ...[
          SizedBox(height: theme.metrics.spacing.md),
          DlmButton(label: retryLabel, onPressed: onRetry),
        ],
      ]),
    );
  }
}

/// A load in progress.
class DlmLoadingState extends StatelessWidget {
  /// Creates a loading state.
  const DlmLoadingState({required this.label, super.key});

  /// Localised text, also the accessible name.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: _centered(context, [
          const DlmProgressRing(value: null, size: 28),
          SizedBox(height: theme.metrics.spacing.md),
          Text(
            label,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ]),
      ),
    );
  }
}

/// A placeholder block shown while content loads. It pulses gently unless
/// the user asked to reduce motion.
class DlmSkeleton extends StatefulWidget {
  /// Creates a skeleton block.
  const DlmSkeleton({this.width, this.height = 14, super.key});

  /// Width; fills the available width when null.
  final double? width;

  /// Height.
  final double height;

  @override
  State<DlmSkeleton> createState() => _DlmSkeletonState();
}

class _DlmSkeletonState extends State<DlmSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _animating = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final animate = !theme.appearance.reduceMotion;
    if (animate && !_animating) {
      _animating = true;
      _pulse.repeat(reverse: true);
    } else if (!animate && _animating) {
      _animating = false;
      _pulse.stop();
    }
    final c = theme.colors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: Color.lerp(
              c.controlFillHover,
              c.controlFillPressed,
              _animating ? _pulse.value : 0,
            ),
            borderRadius: BorderRadius.circular(theme.metrics.radii.small),
          ),
          child: SizedBox(width: widget.width, height: widget.height),
        ),
      ),
    );
  }
}
