import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/theme.dart';
import 'button.dart';

/// Shows [builder]'s content as a modal dialog or sheet over the window and
/// returns what it was closed with. Escape and clicking the dimmed area close
/// it unless [barrierDismissible] is false; focus is kept inside and restored
/// afterwards. [maxWidth] widens the dialog for content such as a two-pane
/// window.
Future<T?> showDlmDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required String semanticLabel,
  DlmDialogKind kind = DlmDialogKind.dialog,
  bool barrierDismissible = true,
  double maxWidth = 520,
}) {
  final theme = DlmTheme.of(context);
  return Navigator.of(context, rootNavigator: true).push<T>(
    RawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: semanticLabel,
      barrierColor: theme.colors.scrim,
      transitionDuration: theme.motion.normal,
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: theme.motion.enter,
          reverseCurve: theme.motion.exit,
        );
        return FadeTransition(
          opacity: curved,
          child: kind == DlmDialogKind.sheet
              ? SlideTransition(
                  position: Tween(
                    begin: const Offset(0, -0.04),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                )
              : ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                  child: child,
                ),
        );
      },
      pageBuilder: (routeContext, _, _) => DlmTheme(
        data: theme,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: FocusScope(
            autofocus: true,
            child: CallbackShortcuts(
              bindings: {
                if (barrierDismissible)
                  const SingleActivator(LogicalKeyboardKey.escape): () =>
                      Navigator.of(routeContext).maybePop(),
              },
              child: Align(
                alignment: kind == DlmDialogKind.sheet
                    ? Alignment.topCenter
                    : Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: EdgeInsets.all(
                      kind == DlmDialogKind.sheet
                          ? 0
                          : theme.metrics.spacing.xl,
                    ),
                    child: theme.components.dialogSurface(
                      routeContext,
                      kind: kind,
                      child: Builder(builder: builder),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The standard content of a dialog: a title, a body and a row of actions
/// with the primary action last.
class DlmDialogContent extends StatelessWidget {
  /// Creates dialog content.
  const DlmDialogContent({
    required this.title,
    required this.actions,
    this.message,
    this.child,
    super.key,
  });

  /// Headline.
  final String title;

  /// A paragraph of text under the title.
  final String? message;

  /// Custom content under the message (a form).
  final Widget? child;

  /// Buttons, primary last.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    final gap = theme.metrics.spacing.lg;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          header: true,
          child: Text(title, style: theme.typography.title),
        ),
        if (message != null) ...[
          SizedBox(height: theme.metrics.spacing.sm),
          Text(
            message!,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ],
        if (child != null) ...[SizedBox(height: gap), child!],
        SizedBox(height: gap + theme.metrics.spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(width: theme.metrics.spacing.sm),
              actions[i],
            ],
          ],
        ),
      ],
    );
  }
}

/// Asks the user to confirm an action. Resolves true on confirm, false on
/// cancel or dismissal. A destructive confirm is drawn as such and the
/// *cancel* button has initial focus, so Enter never destroys by accident.
Future<bool> showDlmConfirm(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String? message,
  bool destructive = false,
}) async {
  final result = await showDlmDialog<bool>(
    context,
    semanticLabel: title,
    builder: (context) => DlmDialogContent(
      title: title,
      message: message,
      actions: [
        DlmButton(
          label: cancelLabel,
          autofocus: destructive,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        DlmButton(
          label: confirmLabel,
          autofocus: !destructive,
          variant: destructive
              ? DlmButtonVariant.destructive
              : DlmButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}
