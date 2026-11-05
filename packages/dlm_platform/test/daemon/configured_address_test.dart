import 'package:dlm_platform/dlm_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the address under server', () {
    expect(
      serverAddressIn(
        'ffmpeg:\n    path: /x\nserver:\n    address: 127.0.0.1:17171\n'
        '    allow_remote: false\n',
      ),
      '127.0.0.1:17171',
    );
  });

  test('handles quotes, comments and Windows line endings', () {
    expect(
      serverAddressIn('server:\r\n  address: "0.0.0.0:17171" # LAN\r\n'),
      '0.0.0.0:17171',
    );
    expect(
      serverAddressIn("server:\n  address: '127.0.0.1:1'\n"),
      '127.0.0.1:1',
    );
  });

  test('ignores an address under another key and a missing file', () {
    expect(serverAddressIn('proxy:\n    address: 1.2.3.4:80\n'), isNull);
    expect(serverAddressIn('server:\n    allow_remote: false\n'), isNull);
    expect(serverAddressIn(''), isNull);
    expect(configuredServerAddress('/no/such/home'), isNull);
  });

  test('an empty address means none', () {
    expect(serverAddressIn("server:\n    address: ''\n"), isNull);
  });
}
