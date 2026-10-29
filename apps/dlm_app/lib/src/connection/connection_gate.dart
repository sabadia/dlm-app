import 'package:dlm_api/dlm_api.dart' show PresentedCertificate;
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_controller.dart';

/// Shows the app once a daemon is connected, and the state of the connection
/// until then (starting, failed, token refused, incompatible, untrusted
/// certificate).
class ConnectionGate extends ConsumerWidget {
  /// Creates the gate around the routed [child].
  const ConnectionGate({required this.child, super.key});

  /// The app, built only while connected.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionProvider);
    if (status is Ready) {
      // Keyed by the session: a new connection starts a new synchronisation.
      return _SyncHost(key: ObjectKey(status.session), child: child);
    }
    return _ConnectionScreen(status: status);
  }
}

/// Starts the event synchronisation for the connected session.
class _SyncHost extends ConsumerStatefulWidget {
  const _SyncHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<_SyncHost> createState() => _SyncHostState();
}

class _SyncHostState extends ConsumerState<_SyncHost> {
  @override
  void initState() {
    super.initState();
    ref.read(syncEngineProvider).start();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ConnectionScreen extends ConsumerWidget {
  const _ConnectionScreen({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final name = status.profile.name;
    void retry() => ref.read(connectionProvider.notifier).connect();

    final body = switch (status) {
      Connecting() => DlmLoadingState(
        label:
            '${l.connection_connecting_title}\n'
            '${l.connection_connecting_message(name)}',
      ),
      Ready() => const SizedBox.shrink(),
      ConnectionFailedStatus(:final reason, :final certificateChanged) =>
        DlmErrorState(
          title: l.connection_failed_title,
          message: [
            if (certificateChanged) l.connection_certificate_changed,
            l.connection_failed_message(name),
            if (reason != null && reason.isNotEmpty)
              l.connection_reason(reason),
          ].join('\n'),
          retryLabel: l.connection_retry,
          onRetry: retry,
        ),
      TokenRejectedStatus() => DlmErrorState(
        title: l.connection_token_rejected_title,
        message: l.connection_token_rejected_message(name),
        retryLabel: l.connection_retry,
        onRetry: retry,
      ),
      IncompatibleStatus() => DlmErrorState(
        title: l.connection_incompatible_title,
        message: l.connection_incompatible_message,
        retryLabel: l.connection_retry,
        onRetry: retry,
      ),
      NeedsTrustStatus(:final certificate) => _TrustPrompt(
        name: name,
        certificate: certificate,
        onTrust: () => ref.read(connectionProvider.notifier).trust(certificate),
      ),
    };
    return ColoredBox(color: theme.colors.window, child: body);
  }
}

class _TrustPrompt extends StatelessWidget {
  const _TrustPrompt({
    required this.name,
    required this.certificate,
    required this.onTrust,
  });

  final String name;
  final PresentedCertificate certificate;
  final VoidCallback onTrust;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final gap = SizedBox(height: theme.metrics.spacing.sm);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.all(theme.metrics.spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l.connection_trust_title,
                  style: theme.typography.title,
                ),
              ),
              gap,
              Text(l.connection_trust_message(name)),
              SizedBox(height: theme.metrics.spacing.lg),
              DlmFormGroup(
                children: [
                  DlmFormRow(
                    label: l.connection_trust_subject,
                    control: Text(certificate.subject),
                  ),
                  DlmFormRow(
                    label: l.connection_trust_issuer,
                    control: Text(certificate.issuer),
                  ),
                  DlmFormRow(
                    label: l.connection_trust_expires,
                    control: Text(certificate.validUntil.toIso8601String()),
                  ),
                  DlmFormRow(
                    label: l.connection_trust_fingerprint,
                    control: Text(
                      certificate.pin,
                      style: theme.typography.mono,
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.metrics.spacing.lg),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: DlmButton(
                  label: l.connection_trust_accept,
                  variant: DlmButtonVariant.primary,
                  onPressed: onTrust,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
