import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../theme/theme.dart';

/// A row of a list: optional [leading] widget, [title] with an optional
/// [subtitle], and optional [trailing] widget.
class DlmListRow extends StatelessWidget {
  /// Creates a list row.
  const DlmListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.semanticLabel,
    this.focusNode,
    super.key,
  });

  /// The main text.
  final String title;

  /// Secondary text under the title.
  final String? subtitle;

  /// A widget before the text (icon, checkbox).
  final Widget? leading;

  /// A widget after the text (badge, value, button).
  final Widget? trailing;

  /// Whether the row is selected.
  final bool selected;

  /// Called on click or Enter/Space.
  final VoidCallback? onTap;

  /// Called on double click.
  final VoidCallback? onDoubleTap;

  /// Called on right click.
  final VoidCallback? onSecondaryTap;

  /// Accessible name; defaults to the title and subtitle.
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final gap = SizedBox(width: theme.metrics.spacing.md);
    return DlmInteractive(
      role: DlmRole.item,
      selected: selected,
      semanticLabel:
          semanticLabel ?? (subtitle == null ? title : '$title, $subtitle'),
      focusNode: focusNode,
      ensureHitTarget: false,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTap: onSecondaryTap,
      builder: (context, states) => theme.components.listRow(
        context,
        states: states,
        content: Row(
          children: [
            if (leading != null) ...[leading!, gap],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[gap, trailing!],
          ],
        ),
      ),
    );
  }
}
