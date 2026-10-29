import 'package:dlm_app/src/about/about_screen.dart';
import 'package:dlm_app/src/about/updates.dart';
import 'package:dlm_app/src/app.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  const stable = ReleaseInfo(
    tag: 'v1.2.0',
    page: 'https://example.test/1.2.0',
    prerelease: false,
  );
  const beta = ReleaseInfo(
    tag: 'v1.3.0-rc.1',
    page: 'https://example.test/1.3.0-rc.1',
    prerelease: true,
  );

  test('stable skips a prerelease and beta may take it', () {
    expect(
      chooseUpdate([beta, stable], beta: false, current: '1.0.0')?.tag,
      'v1.2.0',
    );
    expect(
      chooseUpdate([beta, stable], beta: true, current: '1.2.0')?.tag,
      'v1.3.0-rc.1',
    );
    expect(chooseUpdate([stable], beta: false, current: '1.2.0'), isNull);
    expect(isNewerVersion('v1.2.0', '0.0.0-dev'), isTrue);
    expect(isNewerVersion('1.2.0', 'v1.2.0'), isFalse);
  });

  appTest('checking reports a newer stable release', (tester) async {
    final h = await pumpApp(
      tester,
      overrides: [
        releaseSourceProvider.overrideWithValue(
          () async => const [beta, stable],
        ),
      ],
    );
    h.container.read(routerProvider).go('/manage/about');
    await settle(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmButton && w.label == 'Check for updates',
      ),
    );
    await settle(tester);
    expect(find.text('v1.2.0 is available'), findsOneWidget);
    await tester.drag(find.byType(AboutScreen), const Offset(0, -200));
    await settle(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is DlmDropdown && w.semanticLabel == 'Channel',
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Beta').last);
    await settle(tester);
    expect(h.container.read(updateChannelProvider), UpdateChannel.beta);
  });
}
