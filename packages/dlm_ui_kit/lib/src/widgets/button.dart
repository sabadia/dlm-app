import 'package:flutter/widgets.dart';

import '../behavior/interactive.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// A push button with a text [label], an optional [icon], or both.
class DlmButton extends StatelessWidget {
  /// Creates a button; `onPressed: null` disables it.
  const DlmButton({
    required this.onPressed,
    this.label,
    this.icon,
    this.variant = DlmButtonVariant.secondary,
    this.size = DlmControlSize.regular,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         label != null || icon != null,
         'A button needs a label or an icon.',
       );

  /// Called when the button is activated.
  final VoidCallback? onPressed;

  /// The button text.
  final String? label;

  /// An icon shown before the label.
  final Widget? icon;

  /// The emphasis of the button.
  final DlmButtonVariant variant;

  /// The height class of the button.
  final DlmControlSize size;

  /// Accessible name when it differs from [label] or there is no label.
  final String? semanticLabel;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  /// Request focus when first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return DlmInteractive(
      onTap: onPressed,
      semanticLabel: semanticLabel ?? label,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, states) => theme.components.button(
        context,
        variant: variant,
        size: size,
        states: states,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?icon,
            if (icon != null && label != null)
              SizedBox(width: theme.metrics.spacing.sm),
            if (label != null) Text(label!),
          ],
        ),
      ),
    );
  }
}

/// A button that shows only an icon; [semanticLabel] names it for assistive
/// technology and doubles as its tooltip text where one is provided.
class DlmIconButton extends StatelessWidget {
  /// Creates an icon button; `onPressed: null` disables it.
  const DlmIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = DlmButtonVariant.plain,
    this.size = DlmControlSize.regular,
    this.focusNode,
    super.key,
  });

  /// The icon.
  final Widget icon;

  /// The accessible name; required because there is no visible text.
  final String semanticLabel;

  /// Called when the button is activated.
  final VoidCallback? onPressed;

  /// The emphasis of the button.
  final DlmButtonVariant variant;

  /// The height class of the button.
  final DlmControlSize size;

  /// Focus node to use instead of an internal one.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return DlmInteractive(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      builder: (context, states) => SizedBox(
        width: switch (size) {
          DlmControlSize.small => theme.metrics.controlHeightSmall,
          DlmControlSize.regular => theme.metrics.controlHeight,
          DlmControlSize.large => theme.metrics.controlHeightLarge,
        },
        child: theme.components.button(
          context,
          variant: variant,
          size: size,
          states: states,
          content: icon,
        ),
      ),
    );
  }
}
