import 'package:dlm_app/src/format/dlm_format.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sizes follow the unit system above the widget', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DlmFormat(units: UnitSystem.si, locale: 'en', child: _Size()),
      ),
    );
    expect(find.text('1.00 kB'), findsOneWidget);
  });
}

class _Size extends StatelessWidget {
  const _Size();

  @override
  Widget build(BuildContext context) => Text(context.bytes(1000) ?? '');
}
