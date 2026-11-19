import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../about/updates.dart';
import '../bundled_daemon.dart';
import '../connection/connection_controller.dart';
import '../platform/app_restart.dart';
import '../platform/url_opener.dart';
import '../refresh/link_requests.dart';

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
    // A daemon left running by an earlier version of the app was taken over, not
    // started, so the update did not reach it: offer to restart it into the
    // bundled one.
    final running = daemon?.info?.version;
    if (daemon != null &&
        daemon.phase == DaemonPhase.running &&
        daemon.adopted &&
        running != null &&
        ref.watch(bundledDaemonVersionProvider).isNotEmpty &&
        isNewerVersion(ref.watch(bundledDaemonVersionProvider), running)) {
      banners.add(
        DlmBanner(
          tone: DlmTone.warning,
          title: l.banner_daemon_old_title,
          message: l.banner_daemon_old_message(
            running,
            ref.watch(bundledDaemonVersionProvider),
          ),
          actionLabel: l.banner_daemon_old_action,
          onAction: () => unawaited(ref.read(localDaemonProvider).restart()),
        ),
      );
    }
    if (ref.watch(restartNeededProvider)) {
      banners.add(
        DlmBanner(
          tone: DlmTone.warning,
          title: l.restart_needed_title,
          message: l.restart_needed_message,
          actionLabel: l.restart_needed_action,
          onAction: () => unawaited(restartApp(context, ref)),
        ),
      );
    }
    // Every download that waits for a new link gets its own banner, the newest
    // first (the one just asked for), so a second request never hides behind
    // the first. A long queue of them is cut short.
    final waiting = ref.watch(linkRequestsProvider).reversed.toList();
    const shown = 3;
    for (final request in waiting.take(shown)) {
      banners.add(
        DlmBanner(
          tone: DlmTone.warning,
          title: l.link_wait_title,
          message: l.link_wait_message(request.name),
          actionLabel: l.link_wait_open,
          onAction: () =>
              unawaited(ref.read(urlOpenerProvider).open(request.pageUrl)),
        ),
      );
    }
    if (waiting.length > shown) {
      banners.add(
        DlmBanner(
          tone: DlmTone.warning,
          message: l.link_wait_more(waiting.length - shown),
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
