import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';

/// The state of the live event stream of the connected daemon.
final hubStateProvider = StreamProvider<HubConnectionState>(
  (ref) => ref.watch(syncEngineProvider).connection,
);

/// The state of the bundled daemon's process. Empty for a remote profile.
final daemonStatusProvider = StreamProvider<DaemonStatus>((ref) {
  final profile = ref.watch(activeProfileProvider);
  if (!profile.isLocal) return const Stream.empty();
  return ref.watch(localDaemonProvider).status;
});

/// Banners for trouble that is not about one screen: the event stream lost
/// and being re-established, the bundled daemon restarting or giving up.
/// Nothing shows while all is well.
class StatusBanners extends ConsumerWidget {
  /// Creates the banner area.
  const StatusBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final hub = ref.watch(hubStateProvider).value;
    final daemon = ref.watch(daemonStatusProvider).value;

    final banners = <Widget>[];
    if (daemon != null &&
        (daemon.phase == DaemonPhase.restarting ||
            daemon.phase == DaemonPhase.failed)) {
      final failed = daemon.phase == DaemonPhase.failed;
      banners.add(
        DlmBanner(
          tone: failed ? DlmTone.danger : DlmTone.warning,
          title: failed
              ? l.banner_daemon_failed_title
              : l.banner_daemon_restarting_title,
          message: failed
              ? l.banner_daemon_failed_message(daemon.reason ?? '')
              : l.banner_daemon_restarting_message,
          actionLabel: failed ? l.banner_daemon_restart : null,
          onAction: failed
              ? () => unawaited(ref.read(localDaemonProvider).restart())
              : null,
        ),
      );
    } else if (hub == HubConnectionState.reconnecting) {
      banners.add(
        DlmBanner(
          tone: DlmTone.warning,
          title: l.banner_reconnecting_title,
          message: l.banner_reconnecting_message,
        ),
      );
    }
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      child: Column(children: banners),
    );
  }
}
