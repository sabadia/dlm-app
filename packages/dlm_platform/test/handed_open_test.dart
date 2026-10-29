import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps magnet, ed2k and ordinary download links', () {
    final open = parseHanded(const [
      '--minimised',
      'magnet:?xt=urn:btih:abc',
      'ed2k://|file|a|1|/',
      'https://example.com/a.bin',
      'ftp://files.example/a',
      'not a link',
    ]);
    expect(open.links, [
      'magnet:?xt=urn:btih:abc',
      'ed2k://|file|a|1|/',
      'https://example.com/a.bin',
      'ftp://files.example/a',
    ]);
    expect(open.torrents, isEmpty);
  });

  test('unwraps a dlm link and ignores one that names nothing', () {
    expect(parseHanded(const ['dlm:https://example.com/a.bin']).links, [
      'https://example.com/a.bin',
    ]);
    expect(parseHanded(const ['dlm:magnet:?xt=urn:btih:abc']).links, [
      'magnet:?xt=urn:btih:abc',
    ]);
    expect(
      parseHanded(const ['dlm://add?url=https%3A%2F%2Fexample.com%2Fa.bin'])
          .links,
      ['https://example.com/a.bin'],
    );
    expect(parseHanded(const ['dlm:not-a-url']).isEmpty, isTrue);
    expect(parseHanded(const ['dlm://add']).isEmpty, isTrue);
  });

  test('a torrent file is a path, and a remote torrent stays a link', () {
    final path = Uri.file('${Directory.systemTemp.path}/movie.torrent');
    final open = parseHanded([
      path.toString(),
      'other.torrent',
      'https://example.com/a.torrent',
      'notes.txt',
    ]);
    expect(open.torrents, [path.toFilePath(), 'other.torrent']);
    expect(open.links, ['https://example.com/a.torrent']);
  });

  test('a repeated target counts once', () {
    final open = parseHanded(const [
      'magnet:?xt=urn:btih:abc',
      'magnet:?xt=urn:btih:abc',
    ]);
    expect(open.links, ['magnet:?xt=urn:btih:abc']);
  });

  test('the hand-off line round-trips, and a bad line does not', () {
    const open = HandedOpen(
      links: ['https://example.com/a'],
      torrents: ['a.torrent'],
    );
    expect(decodeHanded(encodeHanded(open)), open);
    expect(decodeHanded('nope'), isNull);
    expect(
      decodeHanded('{"links":["https://example.com/a"]}'),
      const HandedOpen(links: ['https://example.com/a']),
    );
  });

  group('hostile links', () {
    test('a link cannot carry a second line or a space into the dialog', () {
      final open = parseHanded(const [
        // After decoding, a newline followed by another link.
        'dlm://add?url=https%3A%2F%2Fa.test%2Fx%0Ahttps%3A%2F%2Fevil.test%2Fy',
        'dlm:https://a.test/x\nhttps://evil.test/y',
        'magnet:?xt=urn:btih:abc\nhttps://evil.test/y',
        'https://a.test/with space',
        'https://a.test/tab\there',
        'ed2k://|file|a|1|/\r\nhttps://evil.test',
      ]);
      expect(open.isEmpty, isTrue, reason: '${open.links}');
    });

    test('schemes that would read or run something are not downloads', () {
      for (final arg in const [
        'dlm:file:///etc/passwd',
        'dlm://add?url=file%3A%2F%2F%2Fetc%2Fpasswd',
        'dlm:javascript:alert(1)',
        'dlm:data:text/html;base64,AAAA',
        'dlm:ftps://',
        'dlm:http://',
        'dlm://evil?url=https%3A%2F%2Fa.test',
        'dlm:',
        'dlm://',
        'javascript:alert(1)',
        'file:///etc/passwd',
        'smb://server/share/a.bin',
      ]) {
        expect(parseHanded([arg]).isEmpty, isTrue, reason: arg);
      }
    });

    test('a file: argument is only taken when it is a .torrent', () {
      expect(parseHanded(const ['file:///tmp/a.txt']).isEmpty, isTrue);
      // A file: URL becomes a path in the system's own form.
      expect(parseHanded(const ['file:///tmp/a.torrent']).torrents, [
        Uri.parse('file:///tmp/a.torrent').toFilePath(),
      ]);
    });

    test('absurdly long and malformed input does not throw', () {
      final long = 'https://a.test/${'a' * 200000}';
      expect(
        () => parseHanded([long, 'dlm://[::', '%', '\u0000']),
        returnsNormally,
      );
    });
  });
}
