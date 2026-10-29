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
}
