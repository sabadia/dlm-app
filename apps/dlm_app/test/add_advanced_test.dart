import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/add/add_advanced.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an empty draft changes nothing', () {
    final d = AdvancedDraft();
    expect(d.isEmpty, isTrue);
    expect(d.valid, isTrue);
    expect(d.settings, isNull);
    final s = d.source('http://h/f');
    expect(s.currentUrl, 'http://h/f');
    expect(s.headers, isNull);
    expect(s.mirrors, isNull);
    expect(s.resolverKind, isNull);
  });

  test('headers are Name: value lines', () {
    final d = AdvancedDraft()..headers = 'X-Token: abc\n\nAccept:  text/html ';
    expect(d.parsedHeaders, {'X-Token': 'abc', 'Accept': 'text/html'});
    expect(d.valid, isTrue);
    d.headers = 'not a header';
    expect(d.parsedHeaders, isNull);
    expect(d.valid, isFalse);
    d.headers = 'Empty:';
    expect(d.parsedHeaders, isNull);
  });

  test('the digest must be hex of the length of its algorithm', () {
    final d = AdvancedDraft()
      ..algorithm = 'md5'
      ..digest = 'd41d8cd98f00b204e9800998ecf8427e';
    expect(d.digestValid, isTrue);
    expect(d.settings?.checksum?.algorithm, 'md5');
    d.digest = 'd41d8cd98f00b204e9800998ecf8427';
    expect(d.digestValid, isFalse);
    d.digest = 'z41d8cd98f00b204e9800998ecf8427e';
    expect(d.digestValid, isFalse);
    d
      ..algorithm = 'sha256'
      ..digest = '';
    expect(d.digestValid, isTrue, reason: 'no digest means no check');
  });

  test('mirrors, referrer and mode go into the source', () {
    final d = AdvancedDraft()
      ..mirrors = 'http://m1/f\n\n http://m2/f '
      ..referrer = ' http://page '
      ..mode = AddMode.ytdlp;
    final s = d.source('http://h/f');
    expect(s.mirrors, ['http://m1/f', 'http://m2/f']);
    expect(s.referrer, 'http://page');
    expect(s.resolverKind, SourceInputResolverKind.ytdlp);
    expect(d.isEmpty, isFalse);
  });
}
