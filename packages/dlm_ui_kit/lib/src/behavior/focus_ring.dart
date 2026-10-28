import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Draws the keyboard focus indicator around [child] when [visible].
///
/// The ring sits outside the child by the theme's focus offset, so it never
/// changes the layout. Skins use it in their builders.
class DlmFocusRing extends StatelessWidget {
  /// Creates a focus ring around [child].
  const DlmFocusRing({
    required this.visible,
    required this.child,
    this.radius = 0,
    super.key,
  });

  /// Whether the ring is drawn.
  final bool visible;

  /// The corner radius of the ringed shape.
  final double radius;

  /// The control the ring surrounds.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    final reach = m.focusRingOffset + m.focusRingWidth;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: -reach,
          top: -reach,
          right: -reach,
          bottom: -reach,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + reach),
                border: Border.all(
                  color: theme.colors.focusRing,
                  width: m.focusRingWidth,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
