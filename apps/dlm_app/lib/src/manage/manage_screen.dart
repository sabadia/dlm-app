import 'package:flutter/widgets.dart';

import 'browser_screen.dart';
import 'categories_screen.dart';
import 'cookies_screen.dart';
import 'logins_screen.dart';
import 'plugins_screen.dart';
import 'webhooks_screen.dart';

/// The management pages of the sidebar, by their path segment.
const List<String> managePages = [
  'categories',
  'logins',
  'cookies',
  'webhooks',
  'plugins',
  'browser',
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
    'plugins' => const PluginsScreen(),
    'browser' => const BrowserScreen(),
    _ => const SizedBox.shrink(),
  };
}
