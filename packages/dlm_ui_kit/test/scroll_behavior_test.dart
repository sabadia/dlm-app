import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  testWidgets('long lists scroll but draw no scrollbar', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpKit(
      tester,
      SizedBox(
        width: 200,
        height: 200,
        child: ListView(
          controller: controller,
          children: [
            for (var i = 0; i < 50; i++)
              SizedBox(height: 40, child: Text('$i')),
          ],
        ),
      ),
    );
    expect(find.byType(RawScrollbar), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    expect(controller.offset, greaterThan(0));
  });
}
