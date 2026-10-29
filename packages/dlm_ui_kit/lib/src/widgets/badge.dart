import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'button.dart';
import 'icon.dart';

/// A small status pill. Colour is never the only signal: the [label] always
/// says what the status is.
class DlmBadge extends StatelessWidget {
  /// Creates a badge.
  const DlmBadge({
    required this.label,
    this.tone = DlmTone.neutral,
    this.icon,
    super.key,
  });

  /// The text.
  final String label;

  /// The colour meaning.
  final DlmTone tone;

  /// An icon before the text.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return theme.components.badge(
      context,
      tone: tone,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?icon,
          if (icon != null) SizedBox(width: theme.metrics.spacing.xs),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// A chip: a label that can be selected ([onSelected]) and/or removed
/// ([onDeleted]).
class DlmChip extends StatelessWidget {
  /// Creates a chip.
  const DlmChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.deleteLabel,
    super.key,
  }) : assert(
         onDeleted == null || deleteLabel != null,
         'A removable chip needs a deleteLabel for assistive technology.',
       );

  /// The text.
  final String label;

  /// Whether the chip is selected.
  final bool selected;

  /// Called with the new selection; null makes the chip static.
  final ValueChanged<bool>? onSelected;

  /// Called when the remove button is pressed.
  final VoidCallback? onDeleted;

  /// Accessible name of the remove button (localised by the caller).
  final String? deleteLabel;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final chip = DlmInteractive(
      role: DlmRole.item,
      selected: selected,
      semanticLabel: label,
      ensureHitTarget: false,
      onTap: onSelected == null ? null : () => onSelected!(!selected),
      builder: (context, states) => theme.components.chip(
        context,
        states: states.copyWith(disabled: false),
        content: Text(label),
      ),
    );
    if (onDeleted == null) return chip;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip,
        DlmIconButton(
          icon: const DlmIcon(DlmIconName.close),
          semanticLabel: deleteLabel!,
          size: DlmControlSize.small,
          onPressed: onDeleted,
        ),
      ],
    );
  }
}
