import 'package:dlm_gallery/sections/actions_section.dart';
import 'package:dlm_gallery/sections/data_section.dart';
import 'package:dlm_gallery/sections/display_section.dart';
import 'package:dlm_gallery/sections/inputs_section.dart';
import 'package:dlm_gallery/sections/overlays_section.dart';
import 'package:dlm_gallery/sections/structure_section.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// The section titles, in display order.
const List<String> gallerySectionTitles = [
  'Actions',
  'Choice',
  'Text input',
  'Display',
  'Feedback and overlays',
  'Structure',
  'Form rows',
  'Data table',
  'File tree',
  'Schedule',
  'Chart',
];

/// Every section of the gallery as a (title, content) pair, in display order.
/// The goldens (F2.10) render the same list.
List<(String, Widget)> gallerySections(
  BuildContext context,
  DlmToastController toasts,
) => [
  ('Actions', const ActionsSection()),
  ('Choice', const ChoiceSection()),
  ('Text input', const InputsSection()),
  ('Display', const DisplaySection()),
  ('Feedback and overlays', OverlaysSection(toasts: toasts)),
  ('Structure', const StructureSection()),
  ('Form rows', const FormSection()),
  ('Data table', const TableSection()),
  ('File tree', const TreeSection()),
  ('Schedule', const ScheduleSection()),
  ('Chart', const ChartSection()),
];
