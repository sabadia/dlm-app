import 'package:flutter/widgets.dart';

import 'categories_screen.dart';
import 'cookies_screen.dart';
import 'logins_screen.dart';
import 'webhooks_screen.dart';

/// The management pages of the sidebar, by their path segment.
const List<String> managePages = [
  'categories',
  'logins',
  'cookies',
  'webhooks',
];

/// One management page.
class ManageScreen extends StatelessWidget {
  /// Creates the screen of [page].
  const ManageScreen({required this.page, super.key});

  /// The page's path segment (`categories`).
  final String page;

  @override
  Widget build(BuildContext context) => switch (page) {
    'categories' => const CategoriesScreen(),
    'logins' => const LoginsScreen(),
    'cookies' => const CookiesScreen(),
    'webhooks' => const WebhooksScreen(),
    _ => const SizedBox.shrink(),
  };
}
