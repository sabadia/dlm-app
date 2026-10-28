import 'dart:io';

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter/widgets.dart';

import 'src/crash_handlers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dirs = AppDirs.resolve();
  final logs = Directory(dirs.logs);
  final redactor = Redactor(
    homeDirectory:
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'],
  );
  final logger = AppLogger(directory: logs, redactor: redactor);
  final crashes = CrashReporter(directory: logs, logger: logger);
  installCrashHandlers(crashes);
  logger.info('dlm app starting');
  runGuarded(crashes, () => runApp(const DlmApp()));
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
