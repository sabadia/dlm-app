import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../generated/models/reset_data.dart';
import '../generated/models/reset_data_reason.dart';
import '../generated/models/stream_event.dart';
import '../problem.dart';
import 'sse_parser.dart';

/// Which events to receive (the query of `GET /v1/events`).
class EventFilter {
  /// Creates a filter; empty means everything.
  const EventFilter({this.types = const {}, this.taskId, this.queueId});

  /// Event types (`task.progress`, ...).
  final Set<String> types;

  /// Only events of this task.
  final String? taskId;

  /// Only events of this queue.
  final String? queueId;

  /// The query parameters.
  Map<String, String> get query => {
    if (types.isNotEmpty) 'types': (types.toList()..sort()).join(','),
    if (taskId != null) 'taskId': taskId!,
    if (queueId != null) 'queueId': queueId!,
  };
}

/// Opens the event stream: yields frames until the connection ends. Throws
/// on connection errors. [lastEventId] resumes after that event.
typedef SseOpener = Stream<SseFrame> Function(
  EventFilter filter,
  String? lastEventId,
);

/// An [SseOpener] over [dio] (`GET /v1/events`).
///
/// A [StreamController] rather than `async*`: cancelling the stream must
/// close the connection immediately, not after the next byte arrives.
SseOpener dioSseOpener(Dio dio) {
  return (filter, lastEventId) {
    final cancel = CancelToken();
    StreamSubscription<SseFrame>? inner;
    late StreamController<SseFrame> out;
    out = StreamController<SseFrame>(
      onListen: () async {
        try {
          final response = await dio.get<ResponseBody>(
            '/v1/events',
            queryParameters: filter.query,
            options: Options(
              responseType: ResponseType.stream,
              // Streams are long-lived: only the connection is time-limited.
              receiveTimeout: Duration.zero,
              headers: {
                'Accept': 'text/event-stream',
                'Cache-Control': 'no-cache',
                if (lastEventId != null) 'Last-Event-ID': lastEventId,
              },
            ),
            cancelToken: cancel,
          );
          if (out.isClosed || cancel.isCancelled) return;
          // Headers arrived: the stream is up even before the first keep-alive.
          out.add(const SseComment());
          inner = parseSse(response.data!.stream)
              .listen(out.add, onError: out.addError, onDone: out.close);
        } on DioException catch (e) {
          if (out.isClosed) return;
          final failure = e.error;
          out.addError(failure is ApiFailure ? failure : failureOf(e));
          await out.close();
        }
      },
      onCancel: () async {
        cancel.cancel();
        await inner?.cancel();
      },
    );
    return out.stream;
  };
}

/// Whether the hub currently has a stream.
enum HubConnectionState {
  /// Opening the stream.
  connecting,

  /// Receiving.
  connected,

  /// Waiting to retry after a failure.
  reconnecting,

  /// Stopped.
  closed,
}

/// What the hub emits.
sealed class HubEvent {
  const HubEvent();
}

/// A daemon event.
class HubStreamEvent extends HubEvent {
  /// Creates the event.
  const HubStreamEvent(this.event);

  /// The event.
  final StreamEvent event;
}

/// The daemon could not resume the stream (it restarted, or the client lagged
/// too far behind): everything mirrored from events must be refetched.
class HubReset extends HubEvent {
  /// Creates the event.
  const HubReset(this.reason);

  /// Why.
  final ResetDataReason reason;
}

/// The connection changed state.
class HubConnection extends HubEvent {
  /// Creates the event.
  const HubConnection(this.state, {this.attempt = 0, this.error});

  /// The new state.
  final HubConnectionState state;

  /// How many consecutive failures preceded it.
  final int attempt;

  /// The failure that caused [HubConnectionState.reconnecting].
  final ApiFailure? error;
}

/// Reconnection delays: exponential with jitter.
class Backoff {
  /// Creates a policy.
  const Backoff({
    this.initial = const Duration(milliseconds: 500),
    this.max = const Duration(seconds: 30),
    this.factor = 2.0,
    this.jitter = 0.2,
  });

  /// First delay.
  final Duration initial;

  /// Upper bound.
  final Duration max;

  /// Growth per failure.
  final double factor;

  /// Random spread (0.2 = ±20 %).
  final double jitter;

  /// The delay before retry number [attempt] (1-based); [random] gives 0..1.
  Duration delay(int attempt, double random) {
    final base = initial.inMicroseconds * math.pow(factor, attempt - 1);
    final capped = math.min(base, max.inMicroseconds.toDouble());
    final spread = 1 + jitter * (2 * random - 1);
    return Duration(microseconds: (capped * spread).round());
  }
}

/// Keeps one event stream alive and turns it into a Dart stream.
///
/// * resumes with `Last-Event-ID` after every reconnect;
/// * a `reset` event is passed on as [HubReset] (refetch your state);
/// * silence longer than [heartbeatTimeout] (the daemon sends a keep-alive
///   every 15 s) counts as a dead connection;
/// * reconnects with [backoff];
/// * progress events are coalesced per task within [flushInterval], so a
///   slow consumer sees the newest value, never a backlog.
class EventHub {
  /// Creates a hub; call [start] to connect.
  EventHub({
    required SseOpener open,
    this.filter = const EventFilter(),
    this.heartbeatTimeout = const Duration(seconds: 45),
    this.backoff = const Backoff(),
    this.flushInterval = const Duration(milliseconds: 16),
    double Function()? random,
    void Function(Object error, StackTrace stack)? onMalformed,
  }) : _open = open,
       _random = random ?? math.Random().nextDouble,
       _onMalformed = onMalformed;

  final SseOpener _open;
  final double Function() _random;
  final void Function(Object, StackTrace)? _onMalformed;

  /// What the hub subscribes to.
  final EventFilter filter;

  /// Silence after which the connection is considered dead.
  final Duration heartbeatTimeout;

  /// Reconnection policy.
  final Backoff backoff;

  /// Coalescing window of progress events.
  final Duration flushInterval;

  final _controller = StreamController<HubEvent>.broadcast();
  final _pending = <HubEvent>[];
  final _progressSlot = <String, int>{};
  Timer? _flush;
  Timer? _retry;
  Timer? _watchdog;
  StreamSubscription<SseFrame>? _subscription;
  String? _lastEventId;
  int _failures = 0;
  var _running = false;
  var _state = HubConnectionState.closed;

  /// The events; a broadcast stream, listen before [start].
  Stream<HubEvent> get events => _controller.stream;

  /// The id of the last event received (what a reconnect resumes after).
  String? get lastEventId => _lastEventId;

  /// The current connection state.
  HubConnectionState get state => _state;

  /// Connects (and keeps reconnecting) until [stop].
  void start() {
    if (_running) return;
    _running = true;
    _connect();
  }

  /// Disconnects and releases everything; the hub can be started again.
  Future<void> stop() async {
    _running = false;
    _retry?.cancel();
    _watchdog?.cancel();
    _flush?.cancel();
    _pending.clear();
    _progressSlot.clear();
    final sub = _subscription;
    _subscription = null;
    _setState(HubConnectionState.closed);
    await sub?.cancel();
  }

  /// Stops and closes [events] for good.
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  void _setState(HubConnectionState s, {ApiFailure? error}) {
    if (_state == s && error == null) return;
    _state = s;
    _emitNow(HubConnection(s, attempt: _failures, error: error));
  }

  // The subscription is cancelled by stop(), the watchdog or when the stream
  // fails.
  // ignore_for_file: cancel_subscriptions
  void _connect() {
    if (!_running) return;
    _setState(
      _failures == 0
          ? HubConnectionState.connecting
          : HubConnectionState.reconnecting,
    );
    _armWatchdog();
    final frames = _open(filter, _lastEventId);
    _subscription = frames.listen(
      _onFrame,
      onError: (Object e, StackTrace s) => _onBroken(_asFailure(e)),
      onDone: () =>
          _onBroken(const ApiConnectionFailure('the event stream ended')),
      cancelOnError: true,
    );
  }

  void _onFrame(SseFrame frame) {
    _armWatchdog();
    if (_state != HubConnectionState.connected) {
      _failures = 0;
      _setState(HubConnectionState.connected);
    }
    if (frame is! SseData) return;
    final m = frame.message;
    if (m.id != null) _lastEventId = m.id;
    try {
      final json = jsonDecode(m.data) as Map<String, dynamic>;
      if (m.event == 'reset') {
        // After a reset the old ids are meaningless; the next event carries
        // a fresh one.
        _emitNow(HubReset(ResetData.fromJson(json).reason));
        return;
      }
      _enqueue(HubStreamEvent(StreamEvent.fromJson(json)), json);
    } on Object catch (e, s) {
      // An event of a newer daemon, or garbage: skip it, keep the stream.
      _onMalformed?.call(e, s);
    }
  }

  void _enqueue(HubStreamEvent e, Map<String, dynamic> json) {
    final isProgress = json['type'] == 'task.progress';
    final taskId = json['taskId'];
    if (isProgress && taskId is String) {
      final slot = _progressSlot[taskId];
      if (slot != null) {
        _pending[slot] = e; // the newest value replaces the unseen one
        return;
      }
      _progressSlot[taskId] = _pending.length;
    }
    _pending.add(e);
    _flush ??= Timer(flushInterval, _flushPending);
  }

  void _flushPending() {
    _flush = null;
    final batch = List<HubEvent>.of(_pending);
    _pending.clear();
    _progressSlot.clear();
    for (final e in batch) {
      if (!_controller.isClosed) _controller.add(e);
    }
  }

  void _emitNow(HubEvent e) {
    // Keep order: anything queued before is delivered first.
    if (_pending.isNotEmpty) {
      _flush?.cancel();
      _flushPending();
    }
    if (!_controller.isClosed) _controller.add(e);
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(heartbeatTimeout, () {
      final sub = _subscription;
      _subscription = null;
      unawaited(sub?.cancel());
      _onBroken(
        const ApiConnectionFailure(
          'the event stream went silent',
          timedOut: true,
        ),
      );
    });
  }

  void _onBroken(ApiFailure failure) {
    _watchdog?.cancel();
    _subscription = null;
    if (!_running) return;
    _failures++;
    _setState(HubConnectionState.reconnecting, error: failure);
    final wait = backoff.delay(_failures, _random());
    _retry = Timer(wait, _connect);
  }

  static ApiFailure _asFailure(Object e) =>
      e is ApiFailure ? e : ApiConnectionFailure('$e');
}
