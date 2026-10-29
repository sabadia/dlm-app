import 'package:dlm_core/dlm_core.dart';
import 'package:flutter/widgets.dart';

import 'settings_form.dart';

/// One page of the global settings: the fields of a group of the daemon's
/// settings schema.
class SettingsScreen extends StatelessWidget {
  /// Creates the page of [group].
  const SettingsScreen({required this.group, super.key});

  /// The schema group shown.
  final String group;

  @override
  Widget build(BuildContext context) => SettingsForm(
    key: ValueKey(group),
    target: const SettingsTarget.global(),
    groups: {group},
  );
}
