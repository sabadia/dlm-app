import 'package:flutter/widgets.dart';

import 'categories_screen.dart';

/// The management pages of the sidebar, by their path segment.
const List<String> managePages = ['categories'];

/// One management page.
class ManageScreen extends StatelessWidget {
  /// Creates the screen of [page].
  const ManageScreen({required this.page, super.key});

  /// The page's path segment (`categories`).
  final String page;

  @override
  Widget build(BuildContext context) => switch (page) {
    'categories' => const CategoriesScreen(),
    _ => const SizedBox.shrink(),
  };
}
