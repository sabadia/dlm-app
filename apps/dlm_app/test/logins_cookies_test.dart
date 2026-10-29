import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/add/add_dialog.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/manage/cookies_screen.dart';
import 'package:dlm_app/src/manage/credential_draft.dart';
import 'package:dlm_app/src/manage/logins_screen.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

final _login = Credential(
  createdAt: DateTime.utc(2026),
  host: 'example.com',
  id: 'k1',
  scheme: 'basic',
  updatedAt: DateTime.utc(2026, 5, 4),
  username: 'ada',
);

final _cookies = [
  CookieInfo(
    createdAt: DateTime.utc(2026),
    domain: 'a.com',
    hostOnly: true,
    httpOnly: true,
    id: 'c1',
    name: 'sid',
    path: '/',
    secure: true,
    updatedAt: DateTime.utc(2026),
    expiresAt: DateTime.utc(2030, 1, 2),
  ),
  CookieInfo(
    createdAt: DateTime.utc(2026),
    domain: 'a.com',
    hostOnly: true,
    httpOnly: false,
    id: 'c2',
    name: 'pref',
    path: '/',
    secure: false,
    updatedAt: DateTime.utc(2026),
  ),
  CookieInfo(
    createdAt: DateTime.utc(2026),
    domain: 'b.net',
    hostOnly: false,
    httpOnly: false,
    id: 'c3',
    name: 'tok',
    path: '/x',
    secure: false,
    updatedAt: DateTime.utc(2026),
  ),
];

/// The icon button with this accessible name.
Finder iconButton(String label) => find.byWidgetPredicate(
  (w) => w is DlmIconButton && w.semanticLabel == label,
);

void main() {
  group('credential draft', () {
    test('a new login needs a site, a user and a password', () {
      final d = CredentialDraft();
      expect(d.valid, isFalse);
      d
        ..host = 'example.com'
        ..username = 'ada';
      expect(d.valid, isFalse, reason: 'no password');
      d.password = 'pw';
      expect(d.valid, isTrue);
    });

    test('an edit never needs the password and sends it only when typed', () {
      final d = CredentialDraft(from: _login);
      expect(d.valid, isTrue);
      expect(d.toUpdate(_login).password, isNull);
      expect(d.toUpdate(_login).host, isNull);
      d
        ..username = 'grace'
        ..password = 'new';
      final body = d.toUpdate(_login);
      expect(body.username, 'grace');
      expect(body.password, 'new');
      expect(body.host, isNull);
    });

    test('the scheme comes from the stored login', () {
      expect(
        CredentialDraft(from: _login).scheme,
        CreateCredentialBodyScheme.basic,
      );
      expect(CredentialDraft().scheme, CreateCredentialBodyScheme.auto);
    });
  });

  Future<AppHarness> open(
    WidgetTester tester,
    String page, {
    List<Override> overrides = const [],
  }) async {
    final h = await pumpApp(tester, overrides: overrides);
    h.container.read(routerProvider).go('/manage/$page');
    await settle(tester);
    return h;
  }

  group('logins', () {
    FakeCredentials fake(AppHarness h) =>
        h.container.read(credentialsProvider.notifier) as FakeCredentials;

    Future<AppHarness> openLogins(
      WidgetTester tester, [
      List<Credential> logins = const [],
    ]) => open(
      tester,
      'logins',
      overrides: [
        credentialsProvider.overrideWith(() => FakeCredentials(logins)),
      ],
    );

    Future<void> fill(WidgetTester tester, String label, String text) async {
      await tester.enterText(
        find
            .descendant(
              of: find.byType(LoginDialog),
              matching: find.byWidgetPredicate(
                (w) =>
                    (w is DlmTextField && w.semanticLabel == label) ||
                    (w is DlmPasswordField && w.semanticLabel == label),
              ),
            )
            .first,
        text,
      );
      await tester.pump();
    }

    appTest('the list shows hosts and users, never passwords', (tester) async {
      await openLogins(tester, [_login]);
      expect(find.text('example.com'), findsOneWidget);
      expect(find.textContaining('ada · basic'), findsOneWidget);
    });

    appTest('a login is added with its password', (tester) async {
      final h = await openLogins(tester);
      expect(find.text('No logins yet'), findsOneWidget);
      await tester.tap(find.text('Add a login').first);
      await settle(tester);
      await fill(tester, 'Site', 'files.example.org');
      await fill(tester, 'User name', 'ada');
      await fill(tester, 'Password', 's3cret');
      await tester.tap(find.widgetWithText(DlmButton, 'Save'));
      await settle(tester);
      expect(fake(h).calls.single, 'create files.example.org ada s3cret auto');
      expect(find.text('Login saved'), findsOneWidget);
    });

    appTest('editing without a new password keeps the stored one', (
      tester,
    ) async {
      final h = await openLogins(tester, [_login]);
      final semantics = tester.ensureSemantics();
      await tester.tap(iconButton('Edit the login for example.com'));
      await settle(tester);
      expect(
        find.text('Leave empty to keep the stored password.'),
        findsOneWidget,
      );
      await fill(tester, 'User name', 'grace');
      await tester.tap(find.widgetWithText(DlmButton, 'Save'));
      await settle(tester);
      expect(fake(h).calls.single, 'edit k1 null grace null null');
      semantics.dispose();
    });

    appTest('deleting asks first', (tester) async {
      final h = await openLogins(tester, [_login]);
      final semantics = tester.ensureSemantics();
      await tester.tap(iconButton('Delete the login for example.com'));
      await settle(tester);
      expect(find.text('Delete the login for example.com?'), findsOneWidget);
      await tester.tap(find.text('Delete login'));
      await settle(tester);
      expect(fake(h).calls.single, 'remove k1');
      semantics.dispose();
    });
  });

  group('cookies', () {
    FakeCookies fake(AppHarness h) =>
        h.container.read(cookiesProvider.notifier) as FakeCookies;

    Future<AppHarness> openCookies(
      WidgetTester tester, {
      List<Override> overrides = const [],
      List<CookieInfo>? cookies,
    }) => open(
      tester,
      'cookies',
      overrides: [
        cookiesProvider.overrideWith(() => FakeCookies(cookies ?? _cookies)),
        ...overrides,
      ],
    );

    appTest('cookies are grouped by domain, values are not shown', (
      tester,
    ) async {
      await openCookies(tester);
      expect(find.text('a.com'), findsOneWidget);
      expect(find.text('b.net'), findsOneWidget);
      expect(find.text('2 cookies'), findsOneWidget);
      expect(find.text('1 cookie'), findsOneWidget);
      expect(find.text('SECRET-DATA'), findsNothing);
    });

    appTest('a domain opens to its cookies with their flags', (tester) async {
      await openCookies(tester);
      await tester.tap(find.text('a.com'));
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(find.textContaining('sid'), findsOneWidget);
      expect(find.text('Secure'), findsOneWidget);
      expect(find.text('HTTP only'), findsOneWidget);
      expect(
        find.text('Session'),
        findsOneWidget,
        reason: 'pref has no expiry',
      );
    });

    appTest('deleting a domain asks first', (tester) async {
      final h = await openCookies(tester);
      final semantics = tester.ensureSemantics();
      await tester.tap(iconButton('Delete the cookies of a.com'));
      await settle(tester);
      expect(find.text('Delete the cookies of a.com?'), findsOneWidget);
      expect(find.text('2 cookies will be deleted.'), findsOneWidget);
      await tester.tap(find.text('Delete cookies'));
      await settle(tester);
      expect(fake(h).calls.single, 'removeDomain a.com');
      semantics.dispose();
    });

    appTest('an export shows the values only after Reveal', (tester) async {
      final h = await openCookies(tester);
      await tester.tap(find.text('Export all…'));
      await settle(tester);
      expect(find.textContaining('contains the cookie values'), findsOneWidget);
      expect(find.text('SECRET-DATA'), findsNothing);
      expect(fake(h).calls, isEmpty, reason: 'nothing fetched yet');
      await tester.tap(find.text('Reveal the cookies'));
      await settle(tester);
      expect(fake(h).calls.single, 'export netscape null');
      final field = tester.widget<DlmTextField>(
        find.byWidgetPredicate(
          (w) => w is DlmTextField && w.semanticLabel == 'The exported cookies',
        ),
      );
      expect(field.controller?.text, 'SECRET-DATA');
    });

    appTest('an export can be saved to a file', (tester) async {
      final saved = <(String, String)>[];
      await openCookies(
        tester,
        overrides: [
          saveTextFileProvider.overrideWithValue((name, content) async {
            saved.add((name, content));
            return true;
          }),
        ],
      );
      final semantics = tester.ensureSemantics();
      await tester.tap(iconButton('Export the cookies of b.net'));
      await settle(tester);
      await tester.tap(find.text('Reveal the cookies'));
      await settle(tester);
      await tester.tap(find.text('Save to a file…'));
      await settle(tester);
      expect(saved, [('cookies-b.net.txt', 'SECRET-DATA')]);
      semantics.dispose();
    });

    appTest('a cookies file is imported and the result is listed', (
      tester,
    ) async {
      final h = await openCookies(
        tester,
        overrides: [
          addFilePickerProvider.overrideWithValue(
            () async => (name: 'cookies.json', content: '[]'),
          ),
        ],
      );
      await tester.tap(find.text('Import cookies…'));
      await settle(tester);
      expect(fake(h).calls.single, 'import json 2');
      expect(find.text('2 imported, 1 skipped.'), findsOneWidget);
      expect(find.text('line 3: bad domain'), findsOneWidget);
    });
  });
}
