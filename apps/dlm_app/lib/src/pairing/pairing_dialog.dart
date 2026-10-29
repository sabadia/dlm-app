import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../queues/queue_countdown.dart';
import '../shell/feedback.dart';
import 'pairing_requests.dart';

/// A browser's name as a person says it.
String browserName(String browser) => switch (browser) {
  'chrome' => 'Chrome',
  'chromium' => 'Chromium',
  'edge' => 'Edge',
  'brave' => 'Brave',
  'opera' => 'Opera',
  'vivaldi' => 'Vivaldi',
  'firefox' => 'Firefox',
  _ => browser.isEmpty ? '' : browser[0].toUpperCase() + browser.substring(1),
};

/// `482913` as `482 913`, so two groups of three can be compared by eye.
String spacedCode(String code) =>
    code.length == 6 ? '${code.substring(0, 3)} ${code.substring(3)}' : code;

/// Asks the user to allow or refuse [pairing]. The dialog closes by itself when
/// the request ends elsewhere (answered on the command line, or out of time).
Future<void> showPairingPrompt(
  BuildContext context,
  WidgetRef ref,
  Pairing pairing,
) {
  final l = AppLocalizations.of(context);
  return showDlmDialog<void>(
    context,
    semanticLabel: l.pair_title,
    barrierDismissible: false,
    builder: (_) => _PairingDialog(pairing: pairing),
  );
}

class _PairingDialog extends ConsumerStatefulWidget {
  const _PairingDialog({required this.pairing});

  final Pairing pairing;

  @override
  ConsumerState<_PairingDialog> createState() => _PairingDialogState();
}

class _PairingDialogState extends ConsumerState<_PairingDialog> {
  bool _busy = false;
  bool _closing = false;
  Timer? _expiry;

  @override
  void initState() {
    super.initState();
    final left = widget.pairing.expiresAt.difference(ref.read(clockProvider)());
    // A request nobody answers is dropped by the daemon after two minutes;
    // the event may only come with the next request, so the clock decides.
    _expiry = Timer(left.isNegative ? Duration.zero : left, _close);
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    ref.read(pairingRequestsProvider.notifier).dismiss(widget.pairing.id);
    unawaited(Navigator.of(context).maybePop());
  }

  Future<void> _answer({required bool allow}) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(daemonRepositoryProvider);
    final p = widget.pairing;
    setState(() => _busy = true);
    try {
      if (allow) {
        await repo.approvePairing(p.id);
      } else {
        await repo.denyPairing(p.id);
      }
      if (!mounted) return;
      showNotice(
        context,
        ref,
        allow ? l.pair_allowed(p.name) : l.pair_denied(p.name),
      );
      _close();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final p = widget.pairing;
    // It ended somewhere else (the command line, another window).
    final stillWaiting = ref
        .watch(pairingRequestsProvider)
        .any((x) => x.id == p.id);
    if (!stillWaiting && !_closing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }
    final version = p.clientVersion == null ? '' : ' ${p.clientVersion}';
    return DlmDialogContent(
      title: l.pair_title,
      message: l.pair_message(p.name, '${browserName(p.browser)}$version'),
      child: Semantics(
        label: '${l.pair_code_label} ${p.code}',
        excludeSemantics: true,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: theme.metrics.spacing.sm),
          child: Row(
            children: [
              Text(
                l.pair_code_label,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
              SizedBox(width: theme.metrics.spacing.md),
              Text(
                spacedCode(p.code),
                style: theme.typography.title.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        DlmButton(
          label: l.pair_deny,
          onPressed: _busy ? null : () => unawaited(_answer(allow: false)),
        ),
        DlmButton(
          label: l.pair_allow,
          variant: DlmButtonVariant.primary,
          onPressed: _busy ? null : () => unawaited(_answer(allow: true)),
        ),
      ],
    );
  }
}
