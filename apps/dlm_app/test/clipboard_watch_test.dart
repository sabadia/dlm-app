import 'dart:async';

import 'package:dlm_app/src/platform/clipboard_links.dart';
import 'package:dlm_app/src/platform/clipboard_watch.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  test('only download links are taken, and surrounding words are left out', () {
    expect(firstDownloadLink('hello'), isNull);
    expect(
      firstDownloadLink('see https://example.com/a.bin please'),
      'https://example.com/a.bin',
    );
    expect(firstDownloadLink('ftp://files.example/a'), 'ftp://files.example/a');
    expect(
      firstDownloadLink('magnet:?xt=urn:btih:abc'),
      'magnet:?xt=urn:btih:abc',
    );
    expect(firstDownloadLink('ed2k://|file|a|1|/'), 'ed2k://|file|a|1|/');
    expect(
      firstDownloadLink('(https://example.com/a).'),
      'https://example.com/a',
    );
  });

  appTest('a new link is offered once, and a repeat is not', (tester) async {
    var text = 'note https://example.com/a.bin';
    final h = await pumpApp(
      tester,
      overrides: [clipboardReaderProvider.overrideWithValue(() async => text)],
    );
    expect(find.text('A link is on the clipboard'), findsNothing);

    unawaited(h.container.read(clipboardWatchProvider.notifier).set(true));
    await settle(tester);
    expect(find.text('https://example.com/a.bin'), findsOneWidget);

    text = 'note https://example.com/a.bin';
    await tester.tap(find.bySemanticsLabel('Not now'));
    await settle(tester);
    expect(find.text('A link is on the clipboard'), findsNothing);

    text = 'https://example.com/b.bin';
    await tester.pump(clipboardPollInterval);
    await settle(tester);
    expect(find.text('https://example.com/b.bin'), findsOneWidget);
  });

  appTest('plain text is not offered', (tester) async {
    final h = await pumpApp(
      tester,
      overrides: [
        clipboardReaderProvider.overrideWithValue(() async => 'just words'),
      ],
    );
    unawaited(h.container.read(clipboardWatchProvider.notifier).set(true));
    await settle(tester);
    expect(find.text('A link is on the clipboard'), findsNothing);
  });
}
