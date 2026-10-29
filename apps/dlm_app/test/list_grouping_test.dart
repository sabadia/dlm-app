import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_app/src/screens/task_cells.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final categories = [
    const Category(
      dir: '/v',
      id: 'v',
      name: 'Video',
      position: 0,
      extensions: ['mkv', '.MP4'],
    ),
    const Category(dir: '/d', id: 'd', name: 'Docs', position: 1),
  ];

  test('a category is found by the extension, ignoring case and the dot', () {
    expect(categoryOfFile(categories, 'Movie.MKV'), 'Video');
    expect(categoryOfFile(categories, 'a.mp4'), 'Video');
  });

  test('no extension or no match shows no category', () {
    expect(categoryOfFile(categories, 'README'), isNull);
    expect(categoryOfFile(categories, 'a.'), isNull);
    expect(categoryOfFile(categories, 'a.iso'), isNull);
  });
}
