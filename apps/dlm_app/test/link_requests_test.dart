import 'dart:convert';
import 'dart:io';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/platform/integration_binder.dart';
import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_app/src/platform/url_opener.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import 'integration_binder_test.dart'
    show RecordingNotifier, RecordingTray, RecordingWindow;
import 'support/app_harness.dart';

class RecordingUrls implements UrlOpener {
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return true;
  }
}

SseData _event(String type, String taskId, Map<String, Object?> data) =>
    SseData(
      SseMessage(
        id: '$type-$taskId',
        event: type,
        data: jsonEncode({
          'id': 1,
          'type': type,
          'taskId': taskId,
          'time': '2026-10-30T10:00:00Z',
          'data': data,
        }),
      ),
    );

SseData _requested(String id, String page) =>
    _event('task.refresh.requested', id, {
      'fingerprint': {'size': -1},
      'name': 'movie.mkv',
      'pageUrl': page,
    });

void main() {
  group('the web address is checked before a program is started', () {
    test('only http and https are opened, as one argument', () async {
      final runs = <(String, List<String>)>[];
      Future<ProcessResult> run(String exe, List<String> args) async {
        runs.add((exe, args));
        return ProcessResult(0, 0, '', '');
      }

      final opener = ProcessUrlOpener(run: run, os: 'windows');
      expect(await opener.open('https://example.test/a?x=1&y=2'), isTrue);
      expect(runs.single.$1, 'explorer');
      expect(runs.single.$2, ['https://example.test/a?x=1&y=2']);
      for (final bad in [
        'file:///etc/passwd',
        'javascript:alert(1)',
        'calc.exe',
        'ms-msdt:/id',
        'https:///no-host',
        '',
      ]) {
        expect(await opener.open(bad), isFalse, reason: bad);
      }
      expect(runs, hasLength(1));
      final mac = ProcessUrlOpener(run: run, os: 'macos');
      await mac.open('http://example.test/');
      expect(runs.last.$1, 'open');
    });
  });

  group('a download waiting for a new link', () {
    Future<(AppHarness, RecordingNotifier, RecordingUrls)> open(
      WidgetTester tester,
    ) async {
      final notes = RecordingNotifier();
      final urls = RecordingUrls();
      final h = await pumpApp(
        tester,
        liveSync: true,
        overrides: [
          trayProvider.overrideWithValue(RecordingTray(supported: false)),
          windowControlProvider.overrideWithValue(RecordingWindow()),
          notifierProvider.overrideWithValue(notes),
          urlOpenerProvider.overrideWithValue(urls),
        ],
      );
      return (h, notes, urls);
    }

    appTest('shows a banner that opens the page, and a notification', (
      tester,
    ) async {
      final (h, notes, urls) = await open(tester);
      expect(find.text('Waiting for a new link'), findsNothing);
      h.events.add(_requested('t1', 'https://example.test/watch?v=1'));
      await settle(tester);
      expect(find.text('Waiting for a new link'), findsOneWidget);
      expect(find.textContaining('movie.mkv'), findsWidgets);

      await tester.tap(find.text('Open the page'));
      await settle(tester);
      expect(urls.opened, ['https://example.test/watch?v=1']);

      expect(notes.shown.single.title, 'Waiting for a new link');
      expect(notes.shown.single.category, NotifyIds.link);
      notes.tap(
        NotificationTap(
          payload: notes.shown.single.payload,
          buttonId: NotifyIds.openPage,
        ),
      );
      await settle(tester);
      expect(urls.opened, hasLength(2));
    });

    appTest('goes away when the task is no longer waiting', (tester) async {
      final (h, _, _) = await open(tester);
      h.events.add(_requested('t1', 'https://example.test/p'));
      await settle(tester);
      expect(find.text('Waiting for a new link'), findsOneWidget);
      h.events.add(
        _event('task.status', 't1', {'from': 'awaiting_link', 'to': 'running'}),
      );
      await settle(tester);
      expect(find.text('Waiting for a new link'), findsNothing);
    });

    appTest('says how many more wait', (tester) async {
      final (h, _, _) = await open(tester);
      h.events.add(_requested('t1', 'https://example.test/a'));
      h.events.add(_requested('t2', 'https://example.test/b'));
      await settle(tester);
      expect(find.textContaining('1 more download waits'), findsOneWidget);
    });
  });
}
