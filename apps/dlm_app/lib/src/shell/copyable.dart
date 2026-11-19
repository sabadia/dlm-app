import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feedback.dart';

/// Copies [value] to the clipboard and says so.
Future<void> copyText(BuildContext context, WidgetRef ref, String value) async {
  final l = AppLocalizations.of(context);
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) showNotice(context, ref, l.toast_copied);
}

/// A value the user may want elsewhere (a link, a path, a hash): selectable,
/// with a button that copies all of it.
class CopyableText extends ConsumerWidget {
  /// Creates the value.
  const CopyableText(
    this.value, {
    super.key,
    this.textAlign = TextAlign.end,
    this.style,
  });

  /// What is shown and copied.
  final String value;

  /// How the text is aligned in its space.
  final TextAlign textAlign;

  /// The text style; the theme's body by default.
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          // Selectable by hand as well as copyable by the button.
          child: SelectableRegion(
            selectionControls: emptyTextSelectionControls,
            child: Text(
              value,
              textAlign: textAlign,
              style: style ?? DlmTheme.of(context).typography.body,
            ),
          ),
        ),
        DlmIconButton(
          icon: const DlmIcon(DlmIconName.copy),
          semanticLabel: l.src_copy,
          onPressed: () => copyText(context, ref, value),
        ),
      ],
    );
  }
}
