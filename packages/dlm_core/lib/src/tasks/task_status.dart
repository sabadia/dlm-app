import 'package:dlm_api/dlm_api.dart';

/// The status of a task, as the daemon names it. [unknown] stands for a status
/// a newer daemon introduced; the UI shows it neutrally instead of failing.
enum TaskStatus {
  /// Waiting for its turn.
  queued('queued'),

  /// Downloading.
  running('running'),

  /// Stopped by the user.
  paused('paused'),

  /// Its link expired and a new one is awaited.
  awaitingLink('awaiting_link'),

  /// A new link is being obtained.
  refreshing('refreshing'),

  /// Downloaded, post-actions are running.
  postprocessing('postprocessing'),

  /// Done.
  completed('completed'),

  /// Failed.
  error('error'),

  /// Not known to this app.
  unknown('');

  const TaskStatus(this.wire);

  /// The value on the wire.
  final String wire;

  /// Parses a wire value.
  static TaskStatus parse(String? value) => TaskStatus.values.firstWhere(
    (s) => s.wire == value && s != unknown,
    orElse: () => unknown,
  );

  /// Whether the task is being worked on right now.
  bool get isActive =>
      this == running || this == refreshing || this == postprocessing;

  /// Whether nothing more will happen without the user.
  bool get isFinished => this == completed || this == error;

  /// Whether pausing makes sense.
  bool get canPause => this == queued || isActive || this == awaitingLink;

  /// Whether resuming makes sense.
  bool get canResume => this == paused || this == error;
}

/// Domain helpers on the transport model.
extension TaskX on Task {
  /// The parsed status.
  TaskStatus get statusKind => TaskStatus.parse(status);

  /// Whether the size is known.
  bool get hasKnownSize => size >= 0;

  /// Fraction downloaded (0..1), or null while the size is unknown.
  double? get fraction =>
      hasKnownSize && size > 0 ? (downloaded / size).clamp(0, 1) : null;

  /// A copy with the given fields replaced (the generated model has none).
  Task copyWith({
    String? status,
    int? downloaded,
    int? size,
    int? position,
    TaskError? error,
    bool clearError = false,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? startedAt,
  }) {
    return Task(
      createdAt: createdAt,
      downloaded: downloaded ?? this.downloaded,
      id: id,
      position: position ?? this.position,
      priority: priority,
      queueId: queueId,
      settings: settings,
      size: size ?? this.size,
      source: source,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      dir: dir,
      engine: engine,
      error: clearError ? null : (error ?? this.error),
      labels: labels,
      name: name,
      resource: resource,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
