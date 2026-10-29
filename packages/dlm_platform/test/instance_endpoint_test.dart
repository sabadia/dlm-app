import 'dart:async';
import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dlm_instance');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('a second launch hands its targets to the first and exits', () async {
    final primary = await InstanceEndpoint(dir)
        .claim(const ['magnet:?xt=urn:btih:aaa']);
    expect(primary, isA<InstancePrimary>());
    final running = primary as InstancePrimary;
    addTearDown(running.close);
    expect(running.launch.links, ['magnet:?xt=urn:btih:aaa']);

    final incoming = StreamIterator(running.incoming);
    addTearDown(incoming.cancel);

    final second = await InstanceEndpoint(dir)
        .claim(const ['ed2k://|file|a|1|/', 'movie.torrent']);
    expect(second, isA<InstanceHandedOff>());
    expect(await incoming.moveNext(), isTrue);
    expect(incoming.current.links, ['ed2k://|file|a|1|/']);
    expect(incoming.current.torrents, ['movie.torrent']);

    final focus = await InstanceEndpoint(dir).claim(const ['--minimised']);
    expect(focus, isA<InstanceHandedOff>());
    expect(await incoming.moveNext(), isTrue);
    expect(incoming.current.isEmpty, isTrue);
  });

  test('a port nobody listens on is replaced', () async {
    // A port nothing has bound. A just-closed port can swallow the next
    // connection instead of refusing it, and the claim would wait on it.
    File(
      '${dir.path}${Platform.pathSeparator}instance.port',
    ).writeAsStringSync('1\n');

    final claim = await InstanceEndpoint(dir)
        .claim(const ['https://example.com/a.bin']);
    if (claim is! InstancePrimary) fail('expected the primary');
    addTearDown(claim.close);
    expect(claim.launch.links, ['https://example.com/a.bin']);

    final again = await InstanceEndpoint(dir).claim(const []);
    expect(again, isA<InstanceHandedOff>());
  });
}
