import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell.dart';

/// Tells the user, in words, what went wrong. A cancelled request says
/// nothing. Connection trouble is the connection banner's job (F3.9); here
/// everything shows as a toast.
void showFailure(BuildContext context, WidgetRef ref, Object error) {
  final l = AppLocalizations.of(context);
  final presented = presentFailure(error);
  if (presented == null) return;
  final text =
      problemMessage(l, presented.messageKey, presented.params) ??
      (presented.fallback.isNotEmpty
          ? presented.fallback
          : l.toast_failure_unknown);
  ref
      .read(toastControllerProvider)
      .show(
        DlmToast(
          message: text,
          tone: DlmTone.danger,
          dismissLabel: l.action_dismiss,
          duration: const Duration(seconds: 10),
        ),
      );
}

/// Shows a short confirmation, optionally with an Undo action.
void showNotice(
  BuildContext context,
  WidgetRef ref,
  String message, {
  VoidCallback? onUndo,
  DlmTone tone = DlmTone.success,
}) {
  final l = AppLocalizations.of(context);
  ref
      .read(toastControllerProvider)
      .show(
        DlmToast(
          message: message,
          tone: tone,
          dismissLabel: l.action_dismiss,
          actionLabel: onUndo == null ? null : l.action_undo,
          onAction: onUndo,
          duration: Duration(seconds: onUndo == null ? 4 : 8),
        ),
      );
}
