import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dlm/window_chrome');
  final calls = <MethodCall>[];
  late Object? Function(MethodCall) handler;

  setUp(() {
    calls.clear();
    handler = (_) => null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          final r = handler(call);
          if (r is PlatformException) throw r;
          return r;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelWindowChrome', () {
    test('reads the capabilities', () async {
      handler = (_) => {'vibrancy': true, 'glass': false};
      final c = await MethodChannelWindowChrome().capabilities();
      expect(c.vibrancy, isTrue);
      expect(c.glass, isFalse);
    });

    test('sends the configuration and returns what was applied', () async {
      handler = (_) => {'transparentTitleBar': true, 'effect': 'vibrancy'};
      final r = await MethodChannelWindowChrome().apply(
        const WindowChromeConfig(
          transparentTitleBar: true,
          effect: WindowEffect.glass,
          brightness: Brightness.dark,
        ),
      );
      expect(calls.single.method, 'apply');
      expect(calls.single.arguments, {
        'transparentTitleBar': true,
        'effect': 'glass',
        'brightness': 'dark',
      });
      expect(r.effect, WindowEffect.vibrancy, reason: 'glass fell back');
      expect(r.transparentTitleBar, isTrue);
    });

    test('a null brightness follows the system', () async {
      handler = (_) => {'transparentTitleBar': false, 'effect': 'none'};
      await MethodChannelWindowChrome().apply(const WindowChromeConfig());
      expect((calls.single.arguments as Map)['brightness'], isNull);
    });

    test('an unknown effect from native is treated as none', () async {
      handler = (_) => {'transparentTitleBar': false, 'effect': 'hologram'};
      final r = await MethodChannelWindowChrome().apply(
        const WindowChromeConfig(effect: WindowEffect.glass),
      );
      expect(r.effect, WindowEffect.none);
    });

    test('a native error becomes a WindowChromeException', () async {
      handler = (_) => PlatformException(code: 'no-window', message: 'not yet');
      await expectLater(
        MethodChannelWindowChrome().apply(const WindowChromeConfig()),
        throwsA(
          isA<WindowChromeException>().having(
            (e) => e.code,
            'code',
            'no-window',
          ),
        ),
      );
    });

    test('a missing plugin means no effects, not a crash', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      final chrome = MethodChannelWindowChrome();
      expect((await chrome.capabilities()).glass, isFalse);
      expect(
        await chrome.apply(
          const WindowChromeConfig(effect: WindowEffect.glass),
        ),
        WindowChromeResult.none,
      );
      await chrome.setBackdropRegion(const Rect.fromLTWH(0, 0, 10, 10));
    });

    test('sends the region, and null for the whole window', () async {
      final chrome = MethodChannelWindowChrome();
      await chrome.setBackdropRegion(const Rect.fromLTWH(0, 28, 240, 600));
      await chrome.setBackdropRegion(null);
      expect(calls[0].method, 'region');
      expect(calls[0].arguments, {
        'x': 0.0,
        'y': 28.0,
        'width': 240.0,
        'height': 600.0,
      });
      expect(calls[1].arguments, isNull);
    });
  });

  test('UnsupportedWindowChrome does nothing', () async {
    const chrome = UnsupportedWindowChrome();
    expect((await chrome.capabilities()).vibrancy, isFalse);
    expect(
      await chrome.apply(const WindowChromeConfig(effect: WindowEffect.glass)),
      WindowChromeResult.none,
    );
    await chrome.setBackdropRegion(null);
  });

  group('BackdropRegion', () {
    testWidgets('reports its rectangle and follows resizes', (tester) async {
      final chrome = _RecordingChrome();
      var width = 200.0;
      late StateSetter set;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: BackdropRegion(
                    chrome: chrome,
                    child: SizedBox(width: width, height: 300),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(chrome.regions.last, const Rect.fromLTWH(0, 28, 200, 300));
      set(() => width = 260);
      await tester.pump();
      await tester.pump();
      expect(chrome.regions.last, const Rect.fromLTWH(0, 28, 260, 300));
    });

    testWidgets('does not repeat an unchanged region', (tester) async {
      final chrome = _RecordingChrome();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BackdropRegion(
            chrome: chrome,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(chrome.regions.where((r) => r != null).length, 1);
    });

    testWidgets('clears the region when removed', (tester) async {
      final chrome = _RecordingChrome();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BackdropRegion(
            chrome: chrome,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      expect(chrome.regions.last, isNull);
    });

    testWidgets('a not-ready window is retried on the next layout', (
      tester,
    ) async {
      final chrome = _RecordingChrome()..failFirst = true;
      var width = 100.0;
      late StateSetter set;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return BackdropRegion(
                chrome: chrome,
                child: SizedBox(width: width, height: 100),
              );
            },
          ),
        ),
      );
      await tester.pump();
      set(() => width = 100.5);
      await tester.pump();
      await tester.pump();
      expect(chrome.successes, greaterThanOrEqualTo(1));
    });
  });
}

class _RecordingChrome implements WindowChrome {
  final List<Rect?> regions = [];
  bool failFirst = false;
  int successes = 0;

  @override
  Future<WindowChromeCapabilities> capabilities() async =>
      WindowChromeCapabilities.none;

  @override
  Future<WindowChromeResult> apply(WindowChromeConfig config) async =>
      WindowChromeResult.none;

  @override
  Future<void> setBackdropRegion(Rect? region) async {
    if (failFirst) {
      failFirst = false;
      throw const WindowChromeException('no-window', 'not ready');
    }
    regions.add(region);
    if (region != null) successes++;
  }
}
