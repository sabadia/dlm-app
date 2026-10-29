import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/access_screen.dart';
import 'package:dlm_app/src/manage/config_draft.dart';
import 'package:dlm_app/src/manage/daemon_screen.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

ConfigView _view({bool pending = false}) => ConfigView(
  file: '/home/u/.config/dlm/config.yaml',
  fileExists: true,
  restartPending: pending,
  entries: [
    const Entry(
      defaultValue: 'info',
      key: 'log.level',
      readOnly: false,
      restartRequired: true,
      secret: false,
      source: 'default',
      type: 'string',
      value: 'info',
    ),
    Entry(
      defaultValue: 8,
      key: 'server.max_conn',
      pending: pending ? 16 : null,
      readOnly: false,
      restartRequired: false,
      secret: false,
      source: 'file',
      type: 'int',
      value: 8,
    ),
    const Entry(
      defaultValue: true,
      key: 'torrent.dht',
      readOnly: false,
      restartRequired: true,
      secret: false,
      source: 'default',
      type: 'bool',
      value: true,
    ),
    const Entry(
      defaultValue: '127.0.0.1:17171',
      key: 'server.address',
      readOnly: true,
      restartRequired: true,
      secret: false,
      source: 'flag',
      type: 'string',
      value: '127.0.0.1:17171',
    ),
  ],
);

/// The daemon in memory.
class FakeDaemon implements DaemonRepository {
  FakeDaemon({
    this.pending = false,
    this.scope = WhoAmIScope.admin,
    this.failConfig,
    List<Token>? tokens,
    this.waiting = const [],
    this.hosts = const [Result(browser: 'chrome', status: 'absent')],
  }) : _tokens = tokens ?? [];

  final bool pending;
  final List<Pairing> waiting;
  final List<Result> hosts;
  final WhoAmIScope scope;
  ApiProblem? failConfig;
  final List<Token> _tokens;
  final List<String> calls = [];

  @override
  Future<ConfigView> config() async => _view(pending: pending);

  @override
  Future<ConfigView> updateConfig(Map<String, Object?> values) async {
    calls.add('update $values');
    final problem = failConfig;
    if (problem != null) {
      failConfig = null;
      throw problem;
    }
    return _view(pending: true);
  }

  @override
  Future<void> restart() async => calls.add('restart');

  @override
  Future<LogList> logs({Level? level, String? q}) async => LogList(
    bootId: 'b',
    hasMore: false,
    lastId: 1,
    records: [
      Record(
        id: 1,
        level: RecordLevel.info,
        message: 'daemon started',
        time: DateTime.utc(2026, 5, 4, 10),
      ),
    ],
  );

  @override
  Future<WhoAmI> whoami() async => WhoAmI(
    local: true,
    name: 'primary',
    primary: true,
    scope: scope,
    tls: false,
  );

  @override
  Future<List<Token>> tokens() async => _tokens;

  @override
  Future<CreatedToken> createToken(
    String name,
    CreateTokenBodyScope scope,
  ) async {
    calls.add('create $name ${scope.json}');
    final t = Token(
      createdAt: DateTime.utc(2026),
      id: 'k${_tokens.length}',
      name: name,
      scope: scope.json ?? 'read',
    );
    _tokens.add(t);
    return CreatedToken(token: 'dlm_SECRET_$name', info: t);
  }

  @override
  Future<void> deleteToken(String id) async {
    calls.add('delete $id');
    _tokens.removeWhere((t) => t.id == id);
  }

  @override
  Future<CreatedToken> rotateToken() async {
    calls.add('rotate');
    return const CreatedToken(token: 'dlm_NEW_PRIMARY');
  }

  @override
  Future<NativeHostStatus> nativeHost() async => NativeHostStatus(
    launcher: '/l',
    launcherExists: true,
    allowedOrigins: ['chrome-extension://abc/'],
    browsers: hosts,
  );

  @override
  Future<List<Result>> updateNativeHost(
    NativeHostRequestAction action, {
    List<String> extensionIds = const [],
    List<String> firefoxIds = const [],
    List<String> browsers = const [],
  }) async {
    calls.add('native ${action.json} $browsers');
    return const [Result(browser: 'chrome', status: 'installed')];
  }

  @override
  Future<List<Pairing>> pairings() async => waiting;

  @override
  Future<Pairing> approvePairing(String id) async {
    calls.add('approve $id');
    return waiting.firstWhere((p) => p.id == id);
  }

  @override
  Future<Pairing> denyPairing(String id) async {
    calls.add('deny $id');
    return waiting.firstWhere((p) => p.id == id);
  }
}

void main() {
  group('config draft', () {
    test('an edit shows at once and is sent as it is', () {
      final d = ConfigDraft(_view())..set('server.max_conn', 32);
      expect(d.isDirty, isTrue);
      expect(d.valueOf('server.max_conn'), 32);
      expect(d.patch, {'server.max_conn': 32});
      expect(d.editsNeedRestart, isFalse);
      d.set('log.level', 'debug');
      expect(d.editsNeedRestart, isTrue);
    });

    test(
      'setting what is shown is no change; pending values count as shown',
      () {
        final d = ConfigDraft(_view(pending: true));
        expect(d.valueOf('server.max_conn'), 16, reason: 'the pending value');
        d.set('server.max_conn', 16);
        expect(d.isDirty, isFalse);
        d
          ..set('server.max_conn', 8)
          ..revert();
        expect(d.isDirty, isFalse);
      },
    );
  });

  Future<AppHarness> open(
    WidgetTester tester,
    String page,
    FakeDaemon daemon,
  ) async {
    final h = await pumpApp(
      tester,
      overrides: [daemonRepositoryProvider.overrideWithValue(daemon)],
    );
    h.container.read(routerProvider).go('/manage/$page');
    await settle(tester);
    return h;
  }

  group('daemon page', () {
    Finder field(String key) => find.descendant(
      of: find.byWidgetPredicate(
        (w) =>
            (w is DlmNumberField && w.semanticLabel == key) ||
            (w is DlmParsedField && w.semanticLabel == key),
      ),
      matching: find.byType(EditableText),
    );

    appTest('entries are grouped and show their source', (tester) async {
      await open(tester, 'daemon', FakeDaemon());
      expect(find.text('log.level'), findsOneWidget);
      expect(find.text('server.max_conn'), findsOneWidget);
      expect(find.text('flag'), findsOneWidget);
      expect(find.text('set by a flag or the environment'), findsOneWidget);
      expect(find.text('Needs restart'), findsWidgets);
    });

    appTest('the log of the daemon is shown', (tester) async {
      await open(tester, 'daemon', FakeDaemon());
      await tester.scrollUntilVisible(
        find.textContaining('daemon started'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(DaemonScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.textContaining('daemon started'), findsOneWidget);
    });

    appTest('a change is saved, and a restart-only one says so', (
      tester,
    ) async {
      final daemon = FakeDaemon();
      await open(tester, 'daemon', daemon);
      await tester.enterText(field('log.level'), 'debug');
      await tester.pump();
      expect(
        find.text('These changes take effect after a restart.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(DlmButton, 'Save'));
      await settle(tester);
      expect(daemon.calls.single, 'update {log.level: debug}');
      expect(find.text('Configuration saved'), findsOneWidget);
    });

    appTest('a pending restart is offered and asks first', (tester) async {
      final daemon = FakeDaemon(pending: true);
      await open(tester, 'daemon', daemon);
      expect(find.text('A restart is needed'), findsOneWidget);
      expect(find.text('after the restart: 16'), findsOneWidget);
      await tester.tap(find.text('Restart now'));
      await settle(tester);
      expect(find.text('Restart the daemon?'), findsOneWidget);
      expect(daemon.calls, isEmpty);
      await tester.tap(find.text('Restart').last);
      await settle(tester);
      expect(daemon.calls.single, 'restart');
    });

    appTest('a refused value shows its error under its key', (tester) async {
      final daemon = FakeDaemon(
        failConfig: const ApiProblem(
          status: 422,
          code: 'config.invalid',
          errors: [
            ProblemDetail(
              message: 'not a log level',
              location: 'body.values.log.level',
            ),
          ],
        ),
      );
      await open(tester, 'daemon', daemon);
      await tester.enterText(field('log.level'), 'loud');
      await tester.pump();
      await tester.tap(find.widgetWithText(DlmButton, 'Save'));
      await settle(tester);
      expect(find.text('not a log level'), findsOneWidget);
    });
  });

  group('access page', () {
    Finder pageScroll() => find
        .descendant(
          of: find.byType(AccessScreen),
          matching: find.byType(Scrollable),
        )
        .first;

    appTest('who the app is signed in as is shown', (tester) async {
      await open(tester, 'access', FakeDaemon());
      expect(
        find.text('primary (can change everything, the main token)'),
        findsOneWidget,
      );
    });

    appTest('a named token is created and its secret shown once', (
      tester,
    ) async {
      final daemon = FakeDaemon();
      await open(tester, 'access', daemon);
      await tester.tap(find.text('Add a token').first);
      await settle(tester);
      await tester.enterText(
        find
            .descendant(
              of: find.byWidgetPredicate(
                (w) => w is DlmTextField && w.semanticLabel == 'Name',
              ),
              matching: find.byType(EditableText),
            )
            .first,
        'dashboard',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(DlmButton, 'Create'));
      await settle(tester);
      expect(daemon.calls.single, 'create dashboard read');
      expect(find.text('dlm_SECRET_dashboard'), findsOneWidget);
      expect(
        find.textContaining('only time the token is shown'),
        findsOneWidget,
      );
      await tester.tap(find.text('I have copied it'));
      await settle(tester);
      expect(find.text('dlm_SECRET_dashboard'), findsNothing);
      expect(find.text('dashboard'), findsWidgets, reason: 'in the list now');
    });

    appTest('a token is revoked after confirming', (tester) async {
      final daemon = FakeDaemon(
        tokens: [
          Token(
            createdAt: DateTime.utc(2026),
            id: 'k1',
            name: 'old-script',
            scope: 'read',
          ),
        ],
      );
      await open(tester, 'access', daemon);
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is DlmIconButton &&
              w.semanticLabel == 'Revoke the token old-script',
        ),
      );
      await settle(tester);
      await tester.tap(find.text('Revoke token'));
      await settle(tester);
      expect(daemon.calls.single, 'delete k1');
    });

    appTest('replacing the main token warns, then shows the new one', (
      tester,
    ) async {
      final daemon = FakeDaemon();
      await open(tester, 'access', daemon);
      await tester.tap(
        find.widgetWithText(DlmButton, 'Replace the main token'),
      );
      await settle(tester);
      expect(
        find.textContaining('stops working until it is given'),
        findsOneWidget,
      );
      expect(daemon.calls, isEmpty);
      await tester.tap(find.text('Replace it'));
      await settle(tester);
      expect(daemon.calls.single, 'rotate');
      expect(find.text('dlm_NEW_PRIMARY'), findsOneWidget);
    });

    appTest('the extension host is installed for the chosen browsers', (
      tester,
    ) async {
      final daemon = FakeDaemon();
      await open(tester, 'access', daemon);
      await tester.scrollUntilVisible(
        find.text('Install for all browsers'),
        300,
        scrollable: pageScroll(),
      );
      await tester.tap(find.text('Install for all browsers'));
      await settle(tester);
      expect(daemon.calls.single, startsWith('native install'));
      expect(find.text('Done for 1 browser'), findsOneWidget);
    });

    appTest('paired extensions are listed apart and can be revoked', (
      tester,
    ) async {
      final daemon = FakeDaemon(
        tokens: [
          Token(
            browser: 'firefox',
            clientVersion: '0.1.0',
            createdAt: DateTime.utc(2026),
            id: 'x1',
            kind: 'extension',
            name: 'Work laptop',
            scope: 'extension',
          ),
        ],
      );
      await open(tester, 'access', daemon);
      await tester.scrollUntilVisible(
        find.text('Work laptop'),
        300,
        scrollable: pageScroll(),
      );
      expect(find.textContaining('Firefox'), findsWidgets);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is DlmIconButton && w.semanticLabel == 'Revoke Work laptop',
        ),
      );
      await settle(tester);
      await tester.tap(find.text('Revoke token'));
      await settle(tester);
      expect(daemon.calls.single, 'delete x1');
    });

    appTest('settings for assistants use the daemon address', (tester) async {
      await open(tester, 'access', FakeDaemon());
      await tester.scrollUntilVisible(
        find.text('http://127.0.0.1:1/mcp'),
        300,
        scrollable: pageScroll(),
      );
      expect(find.text('http://127.0.0.1:1/mcp'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('claude mcp add --transport http dlm'),
        300,
        scrollable: pageScroll(),
      );
      expect(
        find.textContaining('claude mcp add --transport http dlm'),
        findsOneWidget,
      );
      expect(
        mcpUrl('http://h:1/'),
        'http://h:1/mcp',
        reason: 'no double slash',
      );
    });

    appTest('a read-only token cannot manage tokens', (tester) async {
      await open(tester, 'access', FakeDaemon(scope: WhoAmIScope.read));
      expect(find.text('Add a token'), findsNothing);
      expect(find.text('Replace the main token'), findsNothing);
    });
  });
}
