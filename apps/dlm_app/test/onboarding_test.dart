import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/manage/access_screen.dart';
import 'package:dlm_app/src/onboarding/folder_picker.dart';
import 'package:dlm_app/src/platform/startup.dart';
import 'package:dlm_app/src/prefs/pref_providers.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';
import 'support/fakes.dart';

class FakePicker implements FolderPicker {
  FakePicker(this.answer);

  final String? answer;
  final List<String?> asked = [];

  @override
  Future<String?> pick({String? initial, String? title}) async {
    asked.add(initial);
    return answer;
  }
}

const ffmpeg = ToolStatus(
  autoDownload: false,
  available: true,
  name: ToolStatusName.ffmpeg,
  version: '7.1',
);
const ytdlp = ToolStatus(
  autoDownload: true,
  available: false,
  name: ToolStatusName.ytDlp,
);

void main() {
  FakeGlobalSettings settings(AppHarness h) =>
      h.container.read(globalSettingsProvider.notifier) as FakeGlobalSettings;

  const host = NativeHostStatus(
    allowedOrigins: [],
    launcher: '/bin/dlm',
    launcherExists: true,
    browsers: [Result(browser: 'chrome', status: 'installed')],
  );
  final login = FakeLoginItem();

  Future<AppHarness> first(WidgetTester tester, FakePicker picker) => pumpApp(
    tester,
    onboarded: false,
    overrides: [
      folderPickerProvider.overrideWithValue(picker),
      globalSettingsProvider.overrideWith(FakeGlobalSettings.new),
      nativeHostProvider.overrideWith((ref) async => host),
      loginItemProvider.overrideWithValue(login),
      systemInfoProvider.overrideWith(
        (ref) async => systemInfo([ffmpeg, ytdlp]),
      ),
    ],
  );

  appTest('the first run shows the setup with folder and tools', (
    tester,
  ) async {
    await first(tester, FakePicker(null));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('/Users/test/Downloads'), findsOneWidget);
    expect(find.text('Found · 7.1'), findsOneWidget);
    expect(
      find.text('Not found · installed automatically when needed'),
      findsOneWidget,
    );
    expect(find.text('Not found'), findsOneWidget, reason: 'the browser');
  });

  appTest('choosing a folder saves it as the global download folder', (
    tester,
  ) async {
    final picker = FakePicker('/Volumes/Big/Downloads');
    final h = await first(tester, picker);
    await tester.tap(find.text('Choose…'));
    await settle(tester);
    expect(picker.asked, ['/Users/test/Downloads']);
    expect(settings(h).patches, [
      {'downloadDir': '/Volumes/Big/Downloads'},
    ]);
    expect(find.text('/Volumes/Big/Downloads'), findsOneWidget);
  });

  appTest('cancelling the folder dialog changes nothing', (tester) async {
    final h = await first(tester, FakePicker(null));
    await tester.tap(find.text('Choose…'));
    await settle(tester);
    expect(settings(h).patches, isEmpty);
  });

  appTest('finishing the setup is remembered', (tester) async {
    final h = await first(tester, FakePicker(null));
    expect(h.container.read(onboardingDoneProvider), isFalse);
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('Welcome'), findsNothing);
    expect(h.container.read(onboardingDoneProvider), isTrue);
  });

  appTest('once done it does not come back on its own', (tester) async {
    await pumpApp(tester);
    expect(find.text('Welcome'), findsNothing);
  });

  appTest('the command palette opens it again', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        folderPickerProvider.overrideWithValue(FakePicker(null)),
        globalSettingsProvider.overrideWith(FakeGlobalSettings.new),
        systemInfoProvider.overrideWith((ref) async => systemInfo([ffmpeg])),
      ],
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
    await tester.enterText(find.byType(EditableText).last, 'setup');
    await tester.pump();
    await tester.tap(find.text('Setup and health check…'));
    await settle(tester);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(DlmDialogContent), findsOneWidget);
  });

  appTest('the setup shows the extension state and can start at login', (
    tester,
  ) async {
    await first(tester, FakePicker(null));
    expect(find.text('Set up for 1 browser'), findsOneWidget);
    final toggle = find.byWidgetPredicate(
      (w) => w is DlmSwitch && w.semanticLabel == 'Start when I log in',
    );
    await tester.ensureVisible(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await settle(tester);
    expect(login.enabled, isTrue);
  });
}
