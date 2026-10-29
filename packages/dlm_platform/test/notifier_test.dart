import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('macOS and Linux keep the button id apart from the payload', () {
    final tap = interpretNotificationResponse(
      payload: 'task-a',
      actionId: 'open',
      windows: false,
    );
    expect(tap.payload, 'task-a');
    expect(tap.buttonId, 'open');
  });

  test('a click on the notification itself has no button', () {
    final tap = interpretNotificationResponse(
      payload: 'task-a',
      actionId: null,
      windows: false,
    );
    expect(tap.payload, 'task-a');
    expect(tap.buttonId, isNull);
  });

  test('a Windows button brings back both the button and the download', () {
    final argument = windowsActionArgument('retry', 'task-a');
    final tap = interpretNotificationResponse(
      payload: argument,
      actionId: argument,
      windows: true,
    );
    expect(tap.payload, 'task-a');
    expect(tap.buttonId, 'retry');
  });

  test('a Windows click on the toast itself is not a button', () {
    final tap = interpretNotificationResponse(
      payload: 'task-a',
      actionId: 'task-a',
      windows: true,
    );
    expect(tap.payload, 'task-a');
    expect(tap.buttonId, isNull);
  });
}
