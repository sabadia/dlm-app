import 'dart:async';
import 'dart:convert';

/// One message of a `text/event-stream`.
class SseMessage {
  /// Creates a message.
  const SseMessage({this.id, this.event = 'message', this.data = ''});

  /// The `id:` field; null when absent.
  final String? id;

  /// The `event:` field (`message` when absent).
  final String event;

  /// The `data:` lines joined with newlines.
  final String data;

  @override
  String toString() => 'SseMessage($event, id: $id, data: $data)';
}

/// What the parser reports: a message, or a comment line (the daemon sends
/// comments as keep-alives, so they prove the connection is alive).
sealed class SseFrame {
  const SseFrame();
}

/// A complete message.
class SseData extends SseFrame {
  /// Creates the frame.
  const SseData(this.message);

  /// The message.
  final SseMessage message;
}

/// A comment (`: ...`) line.
class SseComment extends SseFrame {
  /// Creates the frame.
  const SseComment();
}

/// Parses the byte chunks of an event stream (WHATWG HTML §9.2.6): UTF-8,
/// lines ended by LF, CR or CRLF, a blank line dispatches a message.
///
/// Built on a [StreamController] instead of `async*` on purpose: cancelling
/// the subscription must reach the network at once, while an `async*`
/// generator would first wait for the next byte.
Stream<SseFrame> parseSse(Stream<List<int>> bytes) {
  final decoder = _Decoder();
  late StreamController<SseFrame> out;
  StreamSubscription<String>? source;
  out = StreamController<SseFrame>(
    onListen: () {
      source = bytes
          .cast<List<int>>()
          .transform(utf8.decoder)
          .listen(
            (text) => decoder.add(text, out.add),
            onError: out.addError,
            onDone: out.close, // a message cut by the end is dropped
          );
    },
    onPause: () => source?.pause(),
    onResume: () => source?.resume(),
    onCancel: () => source?.cancel(),
  );
  return out.stream;
}

/// The line splitter and field state machine of the protocol.
class _Decoder {
  final _line = StringBuffer();
  var _previousWasCr = false;
  var _id = '';
  var _hasId = false;
  var _event = '';
  final _data = <String>[];
  var _sawData = false;

  void add(String text, void Function(SseFrame) emit) {
    for (var i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c == 0x0A) {
        if (_previousWasCr) {
          _previousWasCr = false; // second half of CRLF
          continue;
        }
        _endLine(emit);
      } else if (c == 0x0D) {
        _endLine(emit);
        _previousWasCr = true;
        continue;
      } else {
        _line.writeCharCode(c);
      }
      _previousWasCr = false;
    }
  }

  void _endLine(void Function(SseFrame) emit) {
    final line = _line.toString();
    _line.clear();
    if (line.isEmpty) {
      if (_sawData) {
        emit(
          SseData(
            SseMessage(
              id: _hasId ? _id : null,
              event: _event.isEmpty ? 'message' : _event,
              data: _data.join('\n'),
            ),
          ),
        );
      }
      _event = '';
      _data.clear();
      _sawData = false;
      _hasId = false;
      return;
    }
    if (line.startsWith(':')) {
      emit(const SseComment());
      return;
    }
    final colon = line.indexOf(':');
    final field = colon < 0 ? line : line.substring(0, colon);
    var value = colon < 0 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    switch (field) {
      case 'event':
        _event = value;
      case 'data':
        _data.add(value);
        _sawData = true;
      case 'id':
        // An id with a NUL is ignored by the specification.
        if (!value.contains('\u0000')) {
          _id = value;
          _hasId = true;
        }
      default:
        break; // retry and unknown fields are ignored: the hub owns backoff
    }
  }
}
