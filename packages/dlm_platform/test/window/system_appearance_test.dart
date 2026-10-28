import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dlm/system_appearance');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('decodes the native map', () {
    final a = SystemAppearance.fromMap({
      'accent': 0xFF0A84FF,
      'highContrast': true,
      'reduceMotion': false,
      'reduceTransparency': true,
    });
    expect(a.accent, const Color(0xFF0A84FF));
    expect(a.highContrast, isTrue);
    expect(a.reduceMotion, isFalse);
    expect(a.reduceTransparency, isTrue);
  });

  test('missing or malformed values fall back to defaults', () {
    expect(SystemAppearance.fromMap(null), SystemAppearance.none);
    final a = SystemAppearance.fromMap({'accent': 'blue'});
    expect(a.accent, isNull);
    expect(a.highContrast, isFalse);
  });

  test('equal snapshots compare equal', () {
    expect(
      const SystemAppearance(accent: Color(0xFF000000), reduceMotion: true),
      const SystemAppearance(accent: Color(0xFF000000), reduceMotion: true),
    );
    expect(
      SystemAppearance.none,
      isNot(const SystemAppearance(highContrast: true)),
    );
  });

  test('read asks the native side', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'read');
          return {'accent': 0xFFFF9F0A, 'reduceMotion': true};
        });
    final reader = MethodChannelSystemAppearance();
    addTearDown(reader.dispose);
    final a = await reader.read();
    expect(a.accent, const Color(0xFFFF9F0A));
    expect(a.reduceMotion, isTrue);
  });

  test('a missing plugin reads as nothing reported', () async {
    final reader = MethodChannelSystemAppearance();
    addTearDown(reader.dispose);
    expect(await reader.read(), SystemAppearance.none);
  });

  test('changes pushed from native reach the stream', () async {
    final reader = MethodChannelSystemAppearance();
    addTearDown(reader.dispose);
    final seen = <SystemAppearance>[];
    final sub = reader.changes.listen(seen.add);
    addTearDown(sub.cancel);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('changed', {'highContrast': true}),
          ),
          (_) {},
        );
    await Future<void>.delayed(Duration.zero);
    expect(seen.single.highContrast, isTrue);
  });

  test('can be created before the binding exists', () {
    // Constructing must not touch the binary messenger.
    MethodChannelSystemAppearance(
      channel: const MethodChannel('dlm/never_used'),
    ).dispose();
  });

  test('the unsupported reader reports nothing', () async {
    const reader = UnsupportedSystemAppearance();
    expect(await reader.read(), SystemAppearance.none);
    expect(await reader.changes.isEmpty, isTrue);
  });
}
