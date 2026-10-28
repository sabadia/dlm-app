// Prepares the OpenAPI document for the generator: the event stream endpoint
// describes its response as an array of oneOf (a text/event-stream), which no
// generator can express; replace it by the StreamEvent union so the event
// models are generated. The stream itself is read by lib/src/sse.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

void main(List<String> args) {
  final input = args.isNotEmpty ? args[0] : 'spec/openapi-3.0.json';
  final output = args.length > 1 ? args[1] : 'build/spec.json';
  final bytes = File(input).readAsBytesSync();
  final doc = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
  final paths = doc['paths']! as Map<String, Object?>;
  final get =
      (paths['/v1/events']! as Map<String, Object?>)['get']!
          as Map<String, Object?>;
  final ok =
      (get['responses']! as Map<String, Object?>)['200']!
          as Map<String, Object?>;
  // The Last-Event-ID header and the lastEventId query parameter collide in a
  // generated method; the stream is not called through it anyway.
  get.remove('parameters');
  ok['content'] = {
    'application/json': {
      'schema': {r'$ref': '#/components/schemas/StreamEvent'},
    },
  };
  File(output)
    ..createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(doc));
  // Lets a test notice that the spec changed without regenerating.
  File('lib/src/generated/.spec-sha256')
    ..createSync(recursive: true)
    ..writeAsStringSync('${sha256.convert(bytes)}\n');
}
