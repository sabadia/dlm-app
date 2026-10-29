/// What kind of thing a task log entry records.
enum TaskLogKind {
  /// The task was created.
  created,

  /// The task moved from one status to another.
  status,

  /// An attempt to renew the task's link.
  refresh,
}

/// One thing that happened to a task, as the daemon's event stream told the
/// app. The daemon does not keep this history: it is what this app has seen
/// since it connected.
class TaskLogEntry {
  /// Creates an entry.
  const TaskLogEntry({
    required this.time,
    required this.kind,
    this.from,
    this.to,
    this.errorCode,
    this.errorMessage,
    this.strategy,
    this.outcome,
  });

  /// When it happened.
  final DateTime time;

  /// What happened.
  final TaskLogKind kind;

  /// For a status change: the status before.
  final String? from;

  /// For a status change: the status after.
  final String? to;

  /// The failure's stable code (a status change into `error`, or a failed
  /// refresh attempt).
  final String? errorCode;

  /// The failure's message.
  final String? errorMessage;

  /// For a refresh: the strategy tried.
  final String? strategy;

  /// For a refresh: how it ended.
  final String? outcome;

  /// Whether the entry records a failure.
  bool get isFailure => errorCode != null || errorMessage != null;
}

/// The most entries kept per task.
const int taskLogLimit = 100;
