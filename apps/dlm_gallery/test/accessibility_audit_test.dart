import 'package:dlm_gallery/gallery_app.dart';
import 'package:dlm_gallery/sections/sections.dart';
import 'package:dlm_gallery/skins.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every semantics node that a screen reader user can act on must say what it
/// is: actionable nodes (tap, increase, decrease) and text fields need a
/// label or a value. A node merged into its parent is part of the parent's
/// single announced item (what a screen reader sees), so it is skipped.
List<String> _unnamedActionables(SemanticsNode root) {
  final problems = <String>[];
  void visit(SemanticsNode node) {
    if (!node.isMergedIntoParent) {
      final data = node.getSemanticsData();
      final actionable =
          data.hasAction(SemanticsAction.tap) ||
          data.hasAction(SemanticsAction.increase) ||
          data.hasAction(SemanticsAction.decrease) ||
          data.flagsCollection.isTextField;
      final named =
          data.label.trim().isNotEmpty || data.value.trim().isNotEmpty;
      if (actionable && !named && !data.flagsCollection.isHidden) {
        problems.add('${node.rect} actions=${data.actions}');
      }
    }
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return problems;
}

void main() {
  for (var skin = 0; skin < gallerySkins.length; skin++) {
    for (final title in gallerySectionTitles) {
      testWidgets('${gallerySkins[skin].id}: $title has no unnamed controls', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        tester.view
          ..physicalSize = const Size(1280, 900)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          GalleryApp(
            skins: gallerySkins,
            initial: GallerySettings(skinIndex: skin, section: title),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        final root = tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!;
        expect(_unnamedActionables(root), isEmpty);
        await tester.pump(const Duration(seconds: 1));
        handle.dispose();
      });
    }
  }
}
