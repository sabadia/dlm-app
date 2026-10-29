import 'package:dlm_core/dlm_core.dart';

/// The list a downloads page shows.
enum DownloadsFilter {
  /// Everything.
  all,

  /// Running, refreshing or post-processing.
  active,

  /// Waiting for a slot.
  queued,

  /// Paused by the user.
  paused,

  /// Finished successfully.
  completed,

  /// Stopped with an error.
  failed;

  /// The statuses the daemon is asked for; empty means all.
  Set<TaskStatus> get statuses => switch (this) {
    all => const {},
    active => const {
      TaskStatus.running,
      TaskStatus.refreshing,
      TaskStatus.postprocessing,
    },
    queued => const {TaskStatus.queued},
    paused => const {TaskStatus.paused},
    completed => const {TaskStatus.completed},
    failed => const {TaskStatus.error},
  };

  /// The filter named by a path segment, or null.
  static DownloadsFilter? fromSegment(String? segment) {
    for (final f in values) {
      if (f.name == segment) return f;
    }
    return null;
  }
}

/// The downloads page of [filter].
String downloadsPath(DownloadsFilter filter) => '/downloads/${filter.name}';

/// The page of one queue.
String queuePath(String id) => '/queues/${Uri.encodeComponent(id)}';

/// The page of one category.
String categoryPath(String id) => '/categories/${Uri.encodeComponent(id)}';

/// The settings groups with a page of their own, in sidebar order.
const List<String> settingsGroups = [
  'general',
  'speed',
  'network',
  'retry',
  'refresh',
  'torrent',
  'browser',
];

/// The settings page of [group].
String settingsPath(String group) => '/settings/$group';

/// Where the app starts.
final String homePath = downloadsPath(DownloadsFilter.all);

/// Sidebar id of a downloads filter.
String downloadsSidebarId(DownloadsFilter f) => 'downloads:${f.name}';

/// Sidebar id of a queue.
String queueSidebarId(String id) => 'queue:$id';

/// Sidebar id of a category.
String categorySidebarId(String id) => 'category:$id';

/// Sidebar id of a settings page.
String settingsSidebarId(String group) => 'settings:$group';
