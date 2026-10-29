import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The swarm of a torrent: state, peers, what was shared, trackers.
class TorrentTab extends ConsumerWidget {
  /// Creates the tab for the task [id].
  const TorrentTab({required this.id, super.key});

  /// The task.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    // The swarm changes with the progress; read it again at each status change
    // and while the task runs, once per progress event is too often.
    ref.listen(taskProvider(id), (before, after) {
      if (before?.status != after?.status) {
        ref.invalidate(taskTorrentProvider(id));
      }
    });
    final info = ref.watch(taskTorrentProvider(id)).value;
    if (info == null) {
      return DlmEmptyState(title: l.torrent_none);
    }
    final gap = theme.metrics.spacing.sm;

    Widget row(String label, String value) => Padding(
      padding: EdgeInsets.symmetric(vertical: theme.metrics.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.typography.caption.copyWith(
                color: theme.colors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.typography.body)),
        ],
      ),
    );

    final peers = info.peers ?? const <TorrentPeer>[];
    final trackers = info.trackers ?? const <String>[];
    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      children: [
        row(l.torrent_state, info.state),
        if (info.infoHash != null) row(l.torrent_hash, info.infoHash!),
        row(l.torrent_private, info.private ? l.torrent_yes : l.torrent_no),
        row(
          l.torrent_peers,
          l.torrent_peers_value(info.peerCount, info.knownPeers, info.seeders),
        ),
        row(
          l.torrent_shared,
          l.torrent_shared_value(
            formatBytes(info.uploaded) ?? '0',
            info.ratio.toStringAsFixed(2),
          ),
        ),
        if (info.seedingSeconds > 0)
          row(
            l.torrent_seeding_time,
            formatDuration(Duration(seconds: info.seedingSeconds)),
          ),
        if (trackers.isNotEmpty) row(l.torrent_trackers, trackers.join('\n')),
        if (peers.isNotEmpty) ...[
          SizedBox(height: gap),
          Text(l.torrent_peer_list, style: theme.typography.subtitle),
          for (final p in peers)
            row(
              p.address,
              [
                if (p.client != null && p.client!.isNotEmpty) p.client!,
                l.torrent_peer_rate(formatSpeed(p.downloadRate) ?? '0'),
              ].join(' · '),
            ),
        ],
      ],
    );
  }
}
