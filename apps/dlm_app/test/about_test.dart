import 'dart:io' as io;

import 'package:dlm_app/src/about/about_screen.dart';
import 'package:dlm_app/src/about/diagnostics_providers.dart';
import 'package:dlm_app/src/about/licences_dialog.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/connection/connection_controller.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

/// A profile store that knows no profiles, so no file is read.
class _NoProfiles extends ProfileStore {
  _NoProfiles() : super(file: io.File('unused'), vault: MemoryTokenVault());

  @override
  Future<List<ConnectionProfile>> load() async => const [];
}

void main() {
  group('licences', () {
    test('they are grouped by package and sorted', () async {
      final out = await loadLicences(
        Stream.fromIterable([
          const LicenseEntryWithLineBreaks(['zeta', 'alpha'], 'MIT text'),
          const LicenseEntryWithLineBreaks(['alpha'], 'BSD text'),
        ]),
      );
      expect(out.map((p) => p.name), ['alpha', 'zeta']);
      expect(out.first.texts, ['MIT text', 'BSD text']);
      expect(out.last.texts, ['MIT text']);
    });

    test('no licences is an empty list', () async {
      expect(await loadLicences(const Stream.empty()), isEmpty);
    });
  });

  Future<AppHarness> open(
    WidgetTester tester, {
    int minClientApi = 1,
    List<Override> overrides = const [],
  }) async {
    final info = systemInfo(const [], minClientApi: minClientApi);
    final h = await pumpApp(
      tester,
      overrides: [
        systemInfoProvider.overrideWith((ref) async => info),
        ...overrides,
      ],
    );
    h.container.read(routerProvider).go('/manage/about');
    await settle(tester);
    return h;
  }

  appTest('the versions of the app and the daemon are shown', (tester) async {
    await open(tester);
    expect(find.text(appVersion), findsOneWidget);
    expect(find.text('0.2.1'), findsOneWidget, reason: 'the daemon');
    expect(find.text('They work together.'), findsOneWidget);
  });

  appTest('a daemon that needs a newer app says so', (tester) async {
    final h = await pumpApp(
      tester,
      overrides: [
        systemInfoProvider.overrideWith(
          (ref) async => systemInfo(const [], minClientApi: 99),
        ),
      ],
    );
    h.container.read(routerProvider).go('/manage/about');
    await settle(tester);
    expect(
      find.text('The service needs a newer version of this app.'),
      findsOneWidget,
    );
  });

  appTest('the diagnostics are copied without secrets', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final redactor = Redactor()..addSecret('dlm_SECRET_TOKEN_VALUE');
    final logger = AppLogger(
      directory: io.Directory.systemTemp,
      redactor: redactor,
    );
    await open(
      tester,
      overrides: [
        redactorProvider.overrideWithValue(redactor),
        appLoggerProvider.overrideWithValue(logger),
        profileStoreProvider.overrideWithValue(_NoProfiles()),
      ],
    );
    await tester.tap(find.text('Copy diagnostics'));
    await settle(tester);
    expect(copied, isNotNull);
    expect(copied, contains('dlm app diagnostics'));
    expect(copied, contains('app: $appVersion'));
    expect(copied, isNot(contains('dlm_SECRET_TOKEN_VALUE')));
    expect(find.text('Diagnostics copied'), findsOneWidget);
  });

  appTest('the licences open in a dialog', (tester) async {
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Show the licences'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(AboutScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    // Bring it clear of the bottom edge before tapping.
    await tester.drag(
      find
          .descendant(
            of: find.byType(AboutScreen),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -300),
    );
    await tester.pump();
    await tester.tap(find.text('Show the licences'));
    await settle(tester);
    expect(find.byType(LicencesDialog), findsOneWidget);
    await tester.tap(find.text('Close'));
    await settle(tester);
    expect(find.byType(LicencesDialog), findsNothing);
  });
}
