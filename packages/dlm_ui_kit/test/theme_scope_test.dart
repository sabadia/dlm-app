import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_skin.dart';

const _skin = TestSkin();

void main() {
  late ManualAppearanceSource source;
  DlmThemeData? seen;
  MediaQueryData? seenMedia;

  Widget app(AppearanceOverride override) => Directionality(
    textDirection: TextDirection.ltr,
    child: DlmThemeScope(
      skin: _skin,
      source: source,
      userOverride: override,
      child: Builder(
        builder: (context) {
          seen = DlmTheme.of(context);
          seenMedia = MediaQuery.of(context);
          return const SizedBox();
        },
      ),
    ),
  );

  setUp(() {
    source = ManualAppearanceSource();
    seen = null;
    seenMedia = null;
  });
  tearDown(() => source.dispose());

  testWidgets('provides the skin tokens and shell', (tester) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    expect(seen!.skinId, 'test');
    expect(seen!.shell, _skin.shell);
    expect(seen!.colors.brightness, Brightness.light);
    expect(seen!.brightness, Brightness.light);
  });

  testWidgets('rebuilds dependants when the system appearance changes', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    source.update(const DlmAppearance(brightness: Brightness.dark));
    await tester.pump();
    expect(seen!.brightness, Brightness.dark);
  });

  testWidgets('applies the high-contrast palette', (tester) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    source.update(const DlmAppearance(contrast: DlmContrast.high));
    await tester.pump();
    expect(seen!.colors.highContrast, isTrue);
  });

  testWidgets('the user override changes the theme without the system', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    await tester.pumpWidget(
      app(const AppearanceOverride(mode: DlmThemeMode.dark)),
    );
    expect(seen!.brightness, Brightness.dark);
  });

  testWidgets('density scales the metrics', (tester) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    final regular = seen!.metrics.rowHeight;
    await tester.pumpWidget(
      app(const AppearanceOverride(density: DlmDensity.comfortable)),
    );
    expect(seen!.density, DlmDensity.comfortable);
    expect(seen!.metrics.rowHeight, greaterThan(regular));
  });

  testWidgets('a custom accent reaches the colours', (tester) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    await tester.pumpWidget(
      app(const AppearanceOverride(accent: Color(0xFF30D158))),
    );
    expect(seen!.colors.accent, const Color(0xFF30D158));
  });

  testWidgets('reduce motion zeroes the durations', (tester) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    expect(seen!.motion.normal, isNot(Duration.zero));
    source.update(const DlmAppearance(reduceMotion: true));
    await tester.pump();
    expect(seen!.motion, DlmMotion.reduced);
    expect(seenMedia!.disableAnimations, isTrue);
  });

  testWidgets('reduce transparency makes every material opaque', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    expect(seen!.materials.sidebar.isTranslucent, isTrue);
    source.update(const DlmAppearance(reduceTransparency: true));
    await tester.pump();
    expect(seen!.materials, DlmMaterials.opaque);
  });

  testWidgets('text scale reaches MediaQuery, including the user multiplier', (
    tester,
  ) async {
    source.update(const DlmAppearance(textScale: 1.5));
    await tester.pumpWidget(app(const AppearanceOverride(textScale: 2)));
    expect(seenMedia!.textScaler.scale(10), closeTo(30, 0.001));
  });

  testWidgets('does not rebuild dependants when nothing changed', (
    tester,
  ) async {
    var probeBuilds = 0;
    final probe = Builder(
      builder: (context) {
        probeBuilds++;
        DlmTheme.of(context);
        return const SizedBox();
      },
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DlmThemeScope(skin: _skin, source: source, child: probe),
      ),
    );
    expect(probeBuilds, 1);
    source.update(const DlmAppearance());
    await tester.pump();
    expect(probeBuilds, 1);
    source.update(const DlmAppearance(brightness: Brightness.dark));
    await tester.pump();
    expect(probeBuilds, 2);
  });

  testWidgets('switching the source resubscribes', (tester) async {
    await tester.pumpWidget(app(AppearanceOverride.none));
    final other = ManualAppearanceSource(
      const DlmAppearance(brightness: Brightness.dark),
    );
    addTearDown(other.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DlmThemeScope(
          skin: _skin,
          source: other,
          child: Builder(
            builder: (context) {
              seen = DlmTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen!.brightness, Brightness.dark);
    other.update(const DlmAppearance());
    await tester.pump();
    expect(seen!.brightness, Brightness.light);
    source.update(const DlmAppearance(brightness: Brightness.dark));
    await tester.pump();
    expect(seen!.brightness, Brightness.light, reason: 'old source ignored');
  });

  testWidgets('maybeOf is null without a scope', (tester) async {
    DlmThemeData? found = _sentinel;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          found = DlmTheme.maybeOf(context);
          return const SizedBox();
        },
      ),
    );
    expect(found, isNull);
  });
}

final DlmThemeData _sentinel = DlmThemeData.resolve(
  const TestSkin(),
  const DlmAppearance(),
);
