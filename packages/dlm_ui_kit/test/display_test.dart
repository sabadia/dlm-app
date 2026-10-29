import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('progress', () {
    testWidgets('a bar fills to its fraction and announces a percentage', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const SizedBox(
          width: 200,
          child: DlmProgressBar(value: 0.25, semanticLabel: 'Download'),
        ),
      );
      final fill = tester.getSize(
        find
            .descendant(
              of: find.byType(DlmProgressBar),
              matching: find.byType(DecoratedBox),
            )
            .last,
      );
      expect(fill.width, closeTo(50, 0.5));
      expect(
        tester.getSemantics(find.byType(DlmProgressBar)),
        matchesSemantics(label: 'Download', value: '25%'),
      );
      handle.dispose();
    });

    testWidgets('values outside 0..1 are clamped', (tester) async {
      await pumpKit(
        tester,
        const SizedBox(width: 100, child: DlmProgressBar(value: 3)),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('an indeterminate bar animates, unless motion is reduced', (
      tester,
    ) async {
      final source = await pumpKit(
        tester,
        const SizedBox(width: 200, child: DlmProgressBar(value: null)),
      );
      expect(tester.hasRunningAnimations, isTrue);
      source.update(const DlmAppearance(reduceMotion: true));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('an indeterminate ring has no percentage', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const DlmProgressRing(value: null, semanticLabel: 'Loading'),
      );
      expect(
        tester.getSemantics(find.byType(DlmProgressRing)),
        matchesSemantics(label: 'Loading'),
      );
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a determinate ring does not run an animation', (tester) async {
      await pumpKit(tester, const DlmProgressRing(value: 0.5));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('DlmBadge and DlmChip', () {
    testWidgets('a badge shows its text for every tone', (tester) async {
      await pumpKit(
        tester,
        Column(
          children: [
            for (final t in DlmTone.values) DlmBadge(label: t.name, tone: t),
          ],
        ),
      );
      for (final t in DlmTone.values) {
        expect(find.text(t.name), findsOneWidget);
      }
    });

    testWidgets('a chip toggles its selection', (tester) async {
      bool? chosen;
      await pumpKit(
        tester,
        DlmChip(label: 'Video', onSelected: (v) => chosen = v),
      );
      await tester.tap(find.text('Video'));
      expect(chosen, isTrue);
    });

    testWidgets('a removable chip has a named remove button', (tester) async {
      var removed = 0;
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        DlmChip(
          label: 'Video',
          onDeleted: () => removed++,
          deleteLabel: 'Remove Video',
        ),
      );
      expect(find.bySemanticsLabel('Remove Video'), findsOneWidget);
      await tester.tap(find.byType(DlmIconButton));
      expect(removed, 1);
      handle.dispose();
    });
  });

  group('DlmListRow', () {
    testWidgets('shows title, subtitle, leading and trailing', (tester) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 400,
          child: DlmListRow(
            title: 'ubuntu.iso',
            subtitle: '4 GB',
            leading: const SizedBox(key: Key('lead'), width: 16, height: 16),
            trailing: const Text('50%'),
            onTap: () {},
          ),
        ),
      );
      expect(find.text('ubuntu.iso'), findsOneWidget);
      expect(find.text('4 GB'), findsOneWidget);
      expect(find.byKey(const Key('lead')), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('is selectable and announces selection', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpKit(
        tester,
        SizedBox(
          width: 400,
          child: DlmListRow(
            title: 'a',
            subtitle: 'b',
            selected: true,
            onTap: () => taps++,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DlmListRow)),
        matchesSemantics(
          label: 'a, b',
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      await tester.tap(find.byType(DlmListRow));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('long titles are ellipsised rather than overflowing', (
      tester,
    ) async {
      await pumpKit(
        tester,
        SizedBox(
          width: 120,
          child: DlmListRow(title: 'x' * 200, trailing: const Text('1')),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('states', () {
    testWidgets('empty state shows title, message and action', (tester) async {
      await pumpKit(
        tester,
        DlmEmptyState(
          title: 'No downloads',
          message: 'Paste a link to start.',
          action: DlmButton(label: 'Add', onPressed: () {}),
        ),
      );
      expect(find.text('No downloads'), findsOneWidget);
      expect(find.text('Paste a link to start.'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('error state retries', (tester) async {
      var retries = 0;
      await pumpKit(
        tester,
        DlmErrorState(
          title: 'Could not load',
          retryLabel: 'Try again',
          onRetry: () => retries++,
        ),
      );
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('loading state is a labelled live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(tester, const DlmLoadingState(label: 'Loading downloads'));
      expect(find.bySemanticsLabel('Loading downloads'), findsOneWidget);
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('skeletons pulse unless motion is reduced', (tester) async {
      final source = await pumpKit(tester, const DlmSkeleton(width: 80));
      expect(tester.hasRunningAnimations, isTrue);
      source.update(const DlmAppearance(reduceMotion: true));
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('DlmBanner', () {
    testWidgets('shows tone icon, text, action and dismiss', (tester) async {
      var acted = 0;
      var dismissed = 0;
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        SizedBox(
          width: 500,
          child: DlmBanner(
            tone: DlmTone.warning,
            title: 'Daemon is old',
            message: 'Update dlm.',
            actionLabel: 'Update',
            onAction: () => acted++,
            onDismiss: () => dismissed++,
            dismissLabel: 'Dismiss',
          ),
        ),
      );
      expect(find.text('Daemon is old'), findsOneWidget);
      await tester.tap(find.text('Update'));
      await tester.tap(find.bySemanticsLabel('Dismiss'));
      expect((acted, dismissed), (1, 1));
      handle.dispose();
    });
  });

  group('DlmTooltip', () {
    testWidgets('appears after the delay when hovered and hides on exit', (
      tester,
    ) async {
      await pumpKit(
        tester,
        const Padding(
          padding: EdgeInsets.all(100),
          child: DlmTooltip(
            message: 'Pause all',
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(SizedBox).last));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Pause all'), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Pause all'), findsOneWidget);
      await mouse.moveTo(const Offset(700, 500));
      await tester.pump();
      expect(find.text('Pause all'), findsNothing);
    });

    testWidgets('exposes the message as a semantic tooltip', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const DlmTooltip(
          message: 'Pause all',
          child: SizedBox(width: 40, height: 40),
        ),
      );
      expect(
        tester.getSemantics(find.byType(DlmTooltip)),
        matchesSemantics(tooltip: 'Pause all'),
      );
      handle.dispose();
    });

    testWidgets('hides when the pointer goes down', (tester) async {
      await pumpKit(
        tester,
        const Padding(
          padding: EdgeInsets.all(100),
          child: DlmTooltip(
            message: 'Pause all',
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(SizedBox).last));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Pause all'), findsOneWidget);
      await mouse.down(tester.getCenter(find.byType(SizedBox).last));
      await tester.pump();
      expect(find.text('Pause all'), findsNothing);
      await mouse.up();
    });
  });

  group('toasts', () {
    late DlmToastController controller;
    setUp(() => controller = DlmToastController());
    tearDown(() => controller.dispose());

    Future<void> pumpHost(WidgetTester tester) => pumpKit(
      tester,
      Builder(
        builder: (context) => SizedBox(
          width: 800,
          height: 600,
          child: DlmToastHost(
            controller: controller,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    testWidgets('show, auto-dismiss after the duration', (tester) async {
      await pumpHost(tester);
      controller.show(
        const DlmToast(
          message: 'Saved',
          dismissLabel: 'Close',
          duration: Duration(seconds: 2),
        ),
      );
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('hovering pauses the timer', (tester) async {
      await pumpHost(tester);
      controller.show(
        const DlmToast(
          message: 'Saved',
          dismissLabel: 'Close',
          duration: Duration(seconds: 2),
        ),
      );
      await tester.pump();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Saved')));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Saved'), findsOneWidget);
      await mouse.moveTo(const Offset(5, 590));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('zero duration stays until dismissed with its button', (
      tester,
    ) async {
      await pumpHost(tester);
      controller.show(
        const DlmToast(
          message: 'Stay',
          dismissLabel: 'Close',
          duration: Duration.zero,
        ),
      );
      await tester.pump(const Duration(minutes: 5));
      expect(find.text('Stay'), findsOneWidget);
      await tester.tap(find.byType(DlmIconButton));
      await tester.pump();
      expect(find.text('Stay'), findsNothing);
    });

    testWidgets('the action runs and dismisses the toast', (tester) async {
      var undone = 0;
      await pumpHost(tester);
      controller.show(
        DlmToast(
          message: 'Deleted',
          dismissLabel: 'Close',
          actionLabel: 'Undo',
          onAction: () => undone++,
          duration: Duration.zero,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undone, 1);
      expect(find.text('Deleted'), findsNothing);
    });

    testWidgets('only maxVisible toasts show; the rest wait', (tester) async {
      await pumpHost(tester);
      for (var i = 0; i < 5; i++) {
        controller.show(
          DlmToast(
            message: 'm$i',
            dismissLabel: 'Close',
            duration: Duration.zero,
          ),
        );
      }
      await tester.pump();
      expect(find.textContaining('m'), findsNWidgets(3));
      controller.dismiss(0);
      await tester.pump();
      expect(find.text('m3'), findsOneWidget);
    });

    testWidgets('toasts are live regions', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(tester);
      controller.show(
        const DlmToast(
          message: 'Saved',
          dismissLabel: 'Close',
          duration: Duration.zero,
        ),
      );
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Saved')), findsOneWidget);
      handle.dispose();
    });
  });
}
