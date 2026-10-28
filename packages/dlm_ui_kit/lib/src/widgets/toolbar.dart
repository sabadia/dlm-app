import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// The bar above the content: [leading] controls, a [title], and [actions]
/// at the trailing edge. The skin decides whether it is unified with the
/// title bar, a command bar, a header bar or a tool bar.
class DlmToolbar extends StatelessWidget {
  /// Creates a toolbar.
  const DlmToolbar({
    this.leading = const [],
    this.title,
    this.actions = const [],
    this.semanticLabel,
    super.key,
  });

  /// Controls before the title (back, sidebar toggle).
  final List<Widget> leading;

  /// The title text, shown after [leading].
  final String? title;

  /// Controls at the trailing edge, in order.
  final List<Widget> actions;

  /// Accessible name of the toolbar.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final gap = SizedBox(width: theme.metrics.spacing.sm);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: theme.components.toolbar(
        context,
        child: Row(
          children: [
            for (final w in leading) ...[w, gap],
            if (title != null)
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.subtitle,
                  ),
                ),
              )
            else
              const Spacer(),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) gap,
              actions[i],
            ],
          ],
        ),
      ),
    );
  }
}
