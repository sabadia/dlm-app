import 'dart:io';

import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRun implements RunKey {
  final values = <String, String>{};

  @override
  String? read(String name) => values[name];

  @override
  void write(String name, String command) => values[name] = command;

  @override
  void delete(String name) => values.remove(name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('XdgAutostartLoginItem', () {
    late Directory dir;
    late XdgAutostartLoginItem item;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('dlm_login');
      item = XdgAutostartLoginItem(
        executable: '/opt/my apps/dlm',
        environment: {'XDG_CONFIG_HOME': dir.path},
      );
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('writes and removes the entry, quoting the path', () async {
      expect(await item.isEnabled(), isFalse);
      await item.setEnabled(enabled: true);
      expect(await item.isEnabled(), isTrue);
      final text = File('${dir.path}/autostart/io.github.sabadia.dlm.desktop')
          .readAsStringSync();
      expect(text, contains('Exec="/opt/my apps/dlm" --minimised'));
      expect(text, startsWith('[Desktop Entry]'));
      await item.setEnabled(enabled: false);
      expect(await item.isEnabled(), isFalse);
    });

    test('turning off when there is no entry is not an error', () async {
      await item.setEnabled(enabled: false);
    });

    test('knows a start at login by the flag', () async {
      expect(await item.startedAtLogin(['--minimised']), isTrue);
      expect(await item.startedAtLogin(const []), isFalse);
    });

    test('falls back to ~/.config without XDG_CONFIG_HOME', () {
      final fallback = XdgAutostartLoginItem(
        executable: '/x/dlm',
        environment: {'HOME': '/home/u'},
      );
      expect(
        fallback.file.path,
        '/home/u/.config/autostart/io.github.sabadia.dlm.desktop',
      );
    });
  });

  test('RegistryLoginItem stores a quoted command under its name', () async {
    final run = _FakeRun();
    final item = RegistryLoginItem(run: run, executable: r'C:\Apps\dlm.exe');
    await item.setEnabled(enabled: true);
    expect(run.values['dlm'], r'"C:\Apps\dlm.exe" --minimised');
    expect(await item.isEnabled(), isTrue);
    await item.setEnabled(enabled: false);
    expect(await item.isEnabled(), isFalse);
  });

  group('MethodChannelLoginItem', () {
    const channel = MethodChannel('dlm/login_item');
    final calls = <MethodCall>[];
    var enabled = false;
    var loginLaunch = false;
    var failing = false;

    setUp(() {
      calls.clear();
      enabled = false;
      loginLaunch = false;
      failing = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            switch (call.method) {
              case 'isEnabled':
                return enabled;
              case 'setEnabled':
                if (failing) {
                  throw PlatformException(code: 'login-item', message: 'no');
                }
                enabled = (call.arguments as Map)['enabled'] as bool;
                return null;
              case 'startedAtLogin':
                return loginLaunch;
            }
            return null;
          });
    });

    test('turns the entry on and off through the plugin', () async {
      final item = MethodChannelLoginItem();
      await item.setEnabled(enabled: true);
      expect(await item.isEnabled(), isTrue);
      await item.setEnabled(enabled: false);
      expect(await item.isEnabled(), isFalse);
    });

    test('a refusal becomes a LoginItemException', () async {
      failing = true;
      await expectLater(
        MethodChannelLoginItem().setEnabled(enabled: true),
        throwsA(isA<LoginItemException>()),
      );
    });

    test('knows a login start from the launch event', () async {
      final item = MethodChannelLoginItem();
      expect(await item.startedAtLogin(const []), isFalse);
      expect(await item.startedAtLogin(const ['--minimised']), isTrue);
      loginLaunch = true;
      expect(await item.startedAtLogin(const []), isTrue);
    });
  });
}
