import 'package:dlm_app/src/platform/dropped_files.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('torrent files are kept by path, once', () async {
    final open = await openFromDrop([
      '/d/a.torrent',
      '/d/A.TORRENT',
      '/d/a.torrent',
    ]);
    expect(open.torrents, ['/d/a.torrent', '/d/A.TORRENT']);
    expect(open.links, isEmpty);
  });

  test(
    'a list file gives its links; other lines and files are skipped',
    () async {
      final open = await openFromDrop(
        ['/d/list.txt', '/d/pic.png', r'C:\d\more.LST'],
        read: (path) async => path.endsWith('list.txt')
            ? 'https://a.test/1.iso\r\nnot a link\nmagnet:?xt=urn:btih:abc\n'
            : 'https://a.test/1.iso\nftp://b.test/2.bin',
      );
      expect(open.links, [
        'https://a.test/1.iso',
        'magnet:?xt=urn:btih:abc',
        'ftp://b.test/2.bin',
      ]);
      expect(open.torrents, isEmpty);
    },
  );

  test('an unreadable list file is skipped, nothing to add is empty', () async {
    final open = await openFromDrop([
      '/d/x.txt',
      '/d/y.zip',
    ], read: (_) async => null);
    expect(open.isEmpty, isTrue);
  });
}
