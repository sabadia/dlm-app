import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// A titled group of [DlmFormRow]s: the building block of settings pages.
class DlmFormGroup extends StatelessWidget {
  /// Creates a group of rows.
  const DlmFormGroup({
    required this.children,
    this.title,
    this.footer,
    super.key,
  });

  /// The rows.
  final List<Widget> children;

  /// A heading above the group.
  final String? title;

  /// Explanatory text under the group.
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final sep = theme.colors.separator;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: theme.components.formGroup(
        context,
        title: title == null
            ? null
            : Semantics(header: true, child: Text(title!)),
        footer: footer == null ? null : Text(footer!),
        rows: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                SizedBox(
                  height: theme.metrics.borderWidth,
                  child: ColoredBox(color: sep),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One row of a form: a [label] with optional [description] on the leading
/// side and the [control] on the trailing side. Below [stackBelow] the
/// control moves under the text.
class DlmFormRow extends StatelessWidget {
  /// Creates a row.
  const DlmFormRow({
    required this.label,
    required this.control,
    this.description,
    this.stackBelow = 420,
    super.key,
  });

  /// What the setting is.
  final String label;

  /// A sentence about what it does.
  final String? description;

  /// The control that edits it.
  final Widget control;

  /// Container width below which the control stacks under the text.
  final double stackBelow;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final m = theme.metrics;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.typography.body),
        if (description != null)
          Text(
            description!,
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
      ],
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.spacing.lg,
        vertical: m.spacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, box) => box.maxWidth < stackBelow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  text,
                  SizedBox(height: m.spacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: control,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: text),
                  SizedBox(width: m.spacing.lg),
                  control,
                ],
              ),
      ),
    );
  }
}
