import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../theme/theme.dart';

/// One option of a [DlmSegmented] or [DlmTabBar].
class DlmOption<T> {
  /// Creates an option with a visible [label] and/or [icon].
  const DlmOption({
    required this.value,
    this.label,
    this.icon,
    this.semanticLabel,
  }) : assert(
         label != null || icon != null,
         'An option needs a label or icon.',
       );

  /// The value chosen when the option is selected.
  final T value;

  /// Visible text.
  final String? label;

  /// An icon shown before the label.
  final Widget? icon;

  /// Accessible name when there is no [label].
  final String? semanticLabel;

  /// The content row of the option.
  Widget content(BuildContext context) {
    final gap = DlmTheme.of(context).metrics.spacing.sm;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?icon,
        if (icon != null && label != null) SizedBox(width: gap),
        if (label != null) Text(label!),
      ],
    );
  }
}

/// A row of mutually exclusive options in one framed control.
class DlmSegmented<T> extends StatelessWidget {
  /// Creates a segmented control.
  const DlmSegmented({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The options, in order.
  final List<DlmOption<T>> options;

  /// The selected value.
  final T value;

  /// Called with the chosen value; null disables the control.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return Semantics(
      container: true,
      child: theme.components.segmentedFrame(
        context,
        child: IntrinsicWidth(
          child: Row(
            children: [
              for (var i = 0; i < options.length; i++)
                Expanded(
                  child: DlmInteractive(
                    role: DlmRole.tab,
                    selected: options[i].value == value,
                    semanticLabel: options[i].semanticLabel ?? options[i].label,
                    ensureHitTarget: false,
                    onTap: onChanged == null
                        ? null
                        : () => onChanged!(options[i].value),
                    builder: (context, states) => theme.components.segment(
                      context,
                      isFirst: i == 0,
                      isLast: i == options.length - 1,
                      states: states,
                      content: options[i].content(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of tabs; the caller shows the selected tab's page.
class DlmTabBar<T> extends StatelessWidget {
  /// Creates a tab bar.
  const DlmTabBar({
    required this.tabs,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The tabs, in order.
  final List<DlmOption<T>> tabs;

  /// The selected tab.
  final T value;

  /// Called with the chosen tab.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final tab in tabs)
          DlmInteractive(
            role: DlmRole.tab,
            selected: tab.value == value,
            semanticLabel: tab.semanticLabel ?? tab.label,
            onTap: () => onChanged(tab.value),
            builder: (context, states) => theme.components.tab(
              context,
              states: states,
              content: tab.content(context),
            ),
          ),
      ],
    );
  }
}
