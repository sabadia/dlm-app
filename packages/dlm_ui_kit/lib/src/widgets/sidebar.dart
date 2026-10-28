import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../theme/theme.dart';
import 'badge.dart';

/// One destination in a [DlmSidebar].
class DlmSidebarItem<T> {
  /// Creates a sidebar item.
  const DlmSidebarItem({
    required this.id,
    required this.label,
    this.icon,
    this.count,
    this.trailing,
  });

  /// The value reported when the item is chosen.
  final T id;

  /// The visible text.
  final String label;

  /// An icon before the text.
  final Widget? icon;

  /// A number badge at the trailing edge (null hides it, 0 shows nothing
  /// either).
  final int? count;

  /// A custom trailing widget (overrides [count]).
  final Widget? trailing;
}

/// A titled group of sidebar items.
class DlmSidebarSection<T> {
  /// Creates a section; a null [title] has no heading.
  const DlmSidebarSection({required this.items, this.title});

  /// The heading text.
  final String? title;

  /// The items.
  final List<DlmSidebarItem<T>> items;
}

/// The navigation sidebar: sections of items with one selected. Up/Down move
/// between items, Enter or Space chooses.
class DlmSidebar<T> extends StatelessWidget {
  /// Creates a sidebar.
  const DlmSidebar({
    required this.sections,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
    this.header,
    this.footer,
    super.key,
  });

  /// The sections, top to bottom.
  final List<DlmSidebarSection<T>> sections;

  /// The id of the selected item.
  final T? selected;

  /// Called with the id of the chosen item.
  final ValueChanged<T> onSelected;

  /// Accessible name of the navigation landmark.
  final String semanticLabel;

  /// A widget above the sections (search, profile switcher).
  final Widget? header;

  /// A widget below the sections (connection status).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: theme.components.sidebarSurface(
        context,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                FocusManager.instance.primaryFocus?.nextFocus(),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                FocusManager.instance.primaryFocus?.previousFocus(),
          },
          child: FocusTraversalGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?header,
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(m.spacing.sm),
                    children: [
                      for (final section in sections) ...[
                        if (section.title != null)
                          Semantics(
                            header: true,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                m.spacing.sm,
                                m.spacing.md,
                                m.spacing.sm,
                                m.spacing.xs,
                              ),
                              child: Text(
                                section.title!,
                                style: theme.typography.caption.copyWith(
                                  color: theme.colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        for (final item in section.items)
                          Padding(
                            padding: EdgeInsets.only(bottom: m.spacing.xxs),
                            child: _item(context, theme, item),
                          ),
                      ],
                    ],
                  ),
                ),
                ?footer,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    DlmThemeData theme,
    DlmSidebarItem<T> item,
  ) {
    final isSelected = item.id == selected;
    final gap = SizedBox(width: theme.metrics.spacing.sm);
    final count = item.count;
    return DlmInteractive(
      role: DlmRole.item,
      selected: isSelected,
      semanticLabel: count == null || count == 0
          ? item.label
          : '${item.label}, $count',
      ensureHitTarget: false,
      onTap: () => onSelected(item.id),
      builder: (context, states) => theme.components.sidebarItem(
        context,
        states: states,
        content: Row(
          children: [
            if (item.icon != null) ...[item.icon!, gap],
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.trailing != null)
              item.trailing!
            else if (count != null && count > 0)
              DlmBadge(label: count > 999 ? '999+' : '$count'),
          ],
        ),
      ),
    );
  }
}
