import 'package:flutter/widgets.dart';

void main() {
  runApp(const DlmApp());
}

/// The root widget of the app. The shell, routing and skins arrive with the
/// M3 tasks; until then it only proves that the runners start.
class DlmApp extends StatelessWidget {
  /// Creates the root widget.
  const DlmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Color(0xFF202124),
        child: Center(
          child: Text('dlm', style: TextStyle(color: Color(0xFFFFFFFF))),
        ),
      ),
    );
  }
}
