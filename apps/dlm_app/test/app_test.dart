import 'package:dlm_app/main.dart';
import 'package:dlm_app/src/skin_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app starts', (tester) async {
    await tester.pumpWidget(const DlmApp());
    expect(find.text('dlm'), findsOneWidget);
  });

  test('every skin is registered once', () {
    expect(skinIds, ['macos', 'fluent', 'adwaita', 'breeze']);
    expect(skinIds.toSet(), hasLength(skinIds.length));
  });
}
