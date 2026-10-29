import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'handed_open.dart';

/// The result of asking to be the one running app.
sealed class InstanceClaim {
  const InstanceClaim();
}

/// This process is the running app. [launch] is what it was opened with, and
/// [incoming] is what later launches hand over.
class InstancePrimary extends InstanceClaim {
  /// Creates the primary claim.
  InstancePrimary({
    required this.launch,
    required this.incoming,
    required Future<void> Function() close,
  }) : _close = close;

  /// What this process was opened with.
  final HandedOpen launch;

  /// Later launches. An empty open means "come forward".
  final Stream<HandedOpen> incoming;

  final Future<void> Function() _close;
  var _closed = false;

  /// Stops listening. A later launch then becomes the primary.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _close();
  }
}

/// Another instance is already running and accepted [args]. This process
/// should exit.
class InstanceHandedOff extends InstanceClaim {
  /// Creates the result.
  const InstanceHandedOff();
}

/// One running app. A second launch connects to the loopback port written in
/// [directory] and sends what it was opened with, then exits. The port file
/// holds only a port number, never the link.
///
/// The lock is held only while choosing who listens, so a crashed primary
/// (its port no longer accepts a connection) is replaced.
class InstanceEndpoint {
  /// Creates the endpoint. [directory] is the app's data directory.
  InstanceEndpoint(this.directory);

  /// Where `instance.port` and `instance.lock` live.
  final Directory directory;

  static const Duration _ioTimeout = Duration(milliseconds: 400);

  /// The largest hand-off accepted. A larger one is dropped and the second
  /// launch still exits, so it cannot become a second app.
  static const int maxLineBytes = 1024 * 1024;

  File get _portFile => File(_path('instance.port'));

  File get _lockFile => File(_path('instance.lock'));

  String _path(String name) =>
      '${directory.path}${Platform.pathSeparator}$name';

  /// Becomes the primary, or hands [args] to the one already running.
  Future<InstanceClaim> claim(List<String> args) async {
    final open = parseHanded(args);
    await directory.create(recursive: true);
    final lock = await _lockFile.open(mode: FileMode.append);
    try {
      await lock.lock();
      try {
        final port = _readPort();
        if (port != null && await _send(port, open)) {
          return const InstanceHandedOff();
        }
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        await _portFile.writeAsString('${server.port}\n');
        final pending = <HandedOpen>[];
        // Closed by the claim's close, which outlives this function.
        // ignore: close_sinks
        late final StreamController<HandedOpen> incoming;
        // Broadcast, so closing completes even if the window never listened.
        // Events that arrive first are kept until it does.
        incoming = StreamController<HandedOpen>.broadcast(
          onListen: () {
            final queued = [...pending];
            pending.clear();
            for (final open in queued) {
              if (!incoming.isClosed) incoming.add(open);
            }
          },
        );
        void add(HandedOpen open) {
          if (incoming.hasListener) {
            incoming.add(open);
          } else {
            pending.add(open);
          }
        }

        // Cancelled by the claim's close, which outlives this function.
        // ignore: cancel_subscriptions
        final subscription = server.listen(
          (socket) => unawaited(_serve(socket, add)),
        );
        return InstancePrimary(
          launch: open,
          incoming: incoming.stream,
          close: () => _shutdown(
            port: server.port,
            subscription: subscription,
            server: server,
            incoming: incoming,
          ),
        );
      } finally {
        await lock.unlock();
      }
    } finally {
      await lock.close();
    }
  }

  int? _readPort() {
    if (!_portFile.existsSync()) return null;
    return int.tryParse(_portFile.readAsStringSync().trim());
  }

  Future<bool> _send(int port, HandedOpen open) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        port,
        timeout: _ioTimeout,
      ).timeout(_ioTimeout);
      await (socket..write('${encodeHanded(open)}\n')).flush().timeout(
        _ioTimeout,
      );
      final reply = await utf8.decoder
          .bind(socket)
          .transform(const LineSplitter())
          .first
          .timeout(_ioTimeout);
      final decoded = jsonDecode(reply);
      return decoded is Map && decoded['ok'] == true;
    } on Object {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  Future<void> _serve(Socket socket, void Function(HandedOpen) add) async {
    try {
      final line = await utf8.decoder
          .bind(socket)
          .transform(const LineSplitter())
          .first
          .timeout(_ioTimeout);
      final open = line.length > maxLineBytes ? null : decodeHanded(line);
      if (open != null) add(open);
      socket.write('{"ok":true}\n');
      await socket.flush();
    } on Object {
      // A broken second launch must not take this process down.
    } finally {
      // close() waits for the peer. A launch that already exited would leave
      // this process stuck, so the socket is dropped instead.
      socket.destroy();
    }
  }

  Future<void> _shutdown({
    required int port,
    required StreamSubscription<Socket> subscription,
    required ServerSocket server,
    required StreamController<HandedOpen> incoming,
  }) async {
    await subscription.cancel();
    await server.close();
    await incoming.close();
    final lock = await _lockFile.open(mode: FileMode.append);
    try {
      await lock.lock();
      try {
        if (_readPort() == port) await _portFile.delete();
      } on FileSystemException {
        // Already gone.
      } finally {
        await lock.unlock();
      }
    } finally {
      await lock.close();
    }
  }
}
