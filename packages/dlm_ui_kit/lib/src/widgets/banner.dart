import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/theme.dart';
import 'button.dart';
import 'icon.dart';

/// The icon that goes with [tone].
DlmIconName dlmToneIcon(DlmTone tone) => switch (tone) {
  DlmTone.success => DlmIconName.success,
  DlmTone.warning => DlmIconName.warning,
  DlmTone.danger => DlmIconName.error,
  DlmTone.neutral || DlmTone.accent || DlmTone.info => DlmIconName.info,
};

/// An inline message box: icon, optional title, message, optional action and
/// optional dismiss button. Announced to assistive technology when shown.
class DlmBanner extends StatelessWidget {
  /// Creates a banner.
  const DlmBanner({
    required this.message,
    this.tone = DlmTone.info,
    this.title,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.dismissLabel,
    super.key,
  }) : assert(
         onDismiss == null || dismissLabel != null,
         'A dismissible banner needs a localised dismissLabel.',
       ),
       assert(
         onAction == null || actionLabel != null,
         'An action needs a localised actionLabel.',
       );

  /// The message.
  final String message;

  /// The meaning, which sets colour and icon.
  final DlmTone tone;

  /// A short headline above the message.
  final String? title;

  /// Text of the action button.
  final String? actionLabel;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

  /// Called when the dismiss button is pressed.
  final VoidCallback? onDismiss;

  /// Accessible name of the dismiss button (localised).
  final String? dismissLabel;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final gap = SizedBox(width: theme.metrics.spacing.md);
    return Semantics(
      container: true,
      liveRegion: true,
      child: theme.components.banner(
        context,
        tone: tone,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DlmIcon(dlmToneIcon(tone)),
            gap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(title!, style: theme.typography.bodyStrong),
                  Text(message),
                ],
              ),
            ),
            if (onAction != null) ...[
              gap,
              DlmButton(
                label: actionLabel,
                size: DlmControlSize.small,
                onPressed: onAction,
              ),
            ],
            if (onDismiss != null)
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.close),
                semanticLabel: dismissLabel!,
                size: DlmControlSize.small,
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
