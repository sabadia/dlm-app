import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

/// The headless browser in memory.
class FakeBrowser implements BrowserRepository {
  FakeBrowser({
    this.result,
    this.groups = const [],
    this.failResolve = false,
    this.failDelete = false,
  });

  final PageResult? result;
  List<String> groups;
  final bool failResolve;
  final bool failDelete;
  final List<String> calls = [];

  @override
  Future<PageResult> resolve(String url, {int? waitSeconds}) async {
    calls.add('resolve $url');
    if (failResolve) {
      throw const ApiProblem(status: 502, code: 'browser.failed');
    }
    return result!;
  }

  @override
  Future<Task> download(String resultId, int index) async {
    calls.add('download $resultId $index');
    return task('t$index', name: 'video-$index.mp4');
  }

  @override
  Future<List<String>> profiles() async => groups;

  @override
  Future<void> deleteProfile(String group) async {
    calls.add('delete $group');
    if (failDelete) {
      throw const ApiProblem(status: 409, code: 'browser.running');
    }
    groups = [
      for (final g in groups)
        if (g != group) g,
    ];
  }
}

PageResult _page(List<Candidate> candidates) => PageResult(
  expiresAt: DateTime.utc(2030),
  finalUrl: 'https://example.com/watch',
  group: 'example.com',
  id: 'r1',
  title: 'A video page',
  url: 'https://example.com/watch?x=1',
  candidates: candidates,
);

Candidate _candidate(int i, {String kind = 'video', int size = 1024}) =>
    Candidate(
      foundAt: DateTime.utc(2026),
      index: i,
      kind: kind,
      size: size,
      source: 'network',
      url: 'https://cdn.example.com/f$i.mp4',
      filename: 'clip$i.mp4',
      mime: 'video/mp4',
    );

void main() {
  Future<AppHarness> open(
    WidgetTester tester,
    FakeBrowser browser, {
    BrowserStatus? status,
    List<ToolStatus> tools = const [],
  }) async {
    final h = await pumpApp(
      tester,
      overrides: [
        browserRepositoryProvider.overrideWithValue(browser),
        browserStatusProvider.overrideWith(
          (ref) async => status ?? const BrowserStatus(max: 2, running: []),
        ),
        systemInfoProvider.overrideWith((ref) async => systemInfo(tools)),
      ],
    );
    h.container.read(routerProvider).go('/manage/browser');
    await settle(tester);
    return h;
  }

  Finder urlField() => find.byWidgetPredicate(
    (w) => w is DlmTextField && w.semanticLabel == 'Page address',
  );

  Future<void> openPage(WidgetTester tester, String url) async {
    await tester.enterText(
      find.descendant(of: urlField(), matching: find.byType(EditableText)),
      url,
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(DlmButton, 'Open'));
    await settle(tester);
  }

  appTest('a wrong address cannot be opened', (tester) async {
    await open(tester, FakeBrowser());
    expect(
      tester
          .widget<DlmButton>(find.widgetWithText(DlmButton, 'Open'))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.descendant(of: urlField(), matching: find.byType(EditableText)),
      'example.com',
    );
    await tester.pump();
    expect(
      find.text('Use an address that starts with http:// or https://.'),
      findsOneWidget,
    );
  });

  appTest('a page lists its downloads and one can be taken', (tester) async {
    final browser = FakeBrowser(
      result: _page([_candidate(0, size: 2048), _candidate(1, kind: 'hls')]),
    );
    final h = await open(tester, browser);
    await openPage(tester, 'https://example.com/watch');
    expect(browser.calls, ['resolve https://example.com/watch']);
    expect(find.text('A video page'), findsOneWidget);
    expect(find.text('clip0.mp4'), findsOneWidget);
    expect(find.textContaining('video · video/mp4 · 2.00 KiB'), findsOneWidget);
    await tester.tap(find.widgetWithText(DlmButton, 'Download').last);
    await settle(tester);
    expect(browser.calls.last, 'download r1 1');
    expect(find.text('Added video-1.mp4'), findsOneWidget);
    expect(h.container.read(taskStoreProvider).tasks['t1'], isNotNull);
  });

  appTest('a page without downloads says so', (tester) async {
    await open(tester, FakeBrowser(result: _page(const [])));
    await openPage(tester, 'https://example.com/empty');
    expect(find.text('The page led to no downloads.'), findsOneWidget);
  });

  appTest('a page that cannot be opened shows an error', (tester) async {
    await open(tester, FakeBrowser(failResolve: true));
    await openPage(tester, 'https://example.com/x');
    expect(find.text('The page could not be opened.'), findsOneWidget);
  });

  appTest('profiles are listed and deleted after confirming', (tester) async {
    final browser = FakeBrowser(groups: ['example.com', 'other.net']);
    await open(tester, browser);
    expect(find.text('example.com'), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is DlmIconButton &&
            w.semanticLabel == 'Delete the profile example.com',
      ),
    );
    await settle(tester);
    expect(find.text('Delete the profile of example.com?'), findsOneWidget);
    await tester.tap(find.text('Delete profile'));
    await settle(tester);
    expect(browser.calls.single, 'delete example.com');
    expect(find.text('example.com'), findsNothing);
    expect(find.text('other.net'), findsOneWidget);
  });

  appTest('a profile in use cannot be deleted', (tester) async {
    final browser = FakeBrowser(groups: ['busy.com'], failDelete: true);
    await open(tester, browser);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is DlmIconButton &&
            w.semanticLabel == 'Delete the profile busy.com',
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Delete profile'));
    await settle(tester);
    expect(find.text('busy.com'), findsOneWidget, reason: 'still there');
  });

  appTest('the browser state and the tools are shown', (tester) async {
    await open(
      tester,
      FakeBrowser(),
      status: const BrowserStatus(
        max: 3,
        browser: Installation(name: 'chromium', path: '/b', version: '127'),
        running: [Running(group: 'example.com', sessions: 2)],
      ),
      tools: const [
        ToolStatus(
          autoDownload: false,
          available: true,
          name: ToolStatusName.ffmpeg,
          version: '7.0',
        ),
        ToolStatus(
          autoDownload: true,
          available: false,
          name: ToolStatusName.ytDlp,
        ),
      ],
    );
    expect(find.text('chromium 127'), findsOneWidget);
    expect(find.text('example.com (2)'), findsOneWidget);
    expect(find.text('Found · 7.0'), findsOneWidget);
    expect(
      find.text('Not found · installed automatically when needed'),
      findsOneWidget,
    );
  });
}
