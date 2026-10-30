import 'package:dlm_app/src/routing/app_routes.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every filter has a stable path and parses back', () {
    for (final f in DownloadsFilter.values) {
      expect(downloadsPath(f), '/downloads/${f.name}');
      expect(DownloadsFilter.fromSegment(f.name), f);
    }
    expect(DownloadsFilter.fromSegment('nope'), isNull);
    expect(DownloadsFilter.fromSegment(null), isNull);
  });

  test('filters map to the statuses the daemon is asked for', () {
    expect(DownloadsFilter.all.statuses, isEmpty);
    expect(DownloadsFilter.active.statuses, {
      TaskStatus.running,
      TaskStatus.refreshing,
      TaskStatus.postprocessing,
    });
    // Waiting: for a slot, or for a new link; the latter shows in no other list.
    expect(DownloadsFilter.queued.statuses, {
      TaskStatus.queued,
      TaskStatus.awaitingLink,
    });
    expect(DownloadsFilter.paused.statuses, {TaskStatus.paused});
    expect(DownloadsFilter.completed.statuses, {TaskStatus.completed});
    expect(DownloadsFilter.failed.statuses, {TaskStatus.error});
  });

  test('queue ids are escaped in paths', () {
    expect(queuePath('a b/c'), '/queues/a%20b%2Fc');
  });

  test('the app starts on all downloads', () {
    expect(homePath, '/downloads/all');
  });
}
