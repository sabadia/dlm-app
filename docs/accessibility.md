# Accessibility and keyboard (F2.11)

What the UI kit guarantees, how it is tested, and the keyboard map every screen can rely on.
Code: `packages/dlm_ui_kit/lib/src/behavior/`, tests in `packages/dlm_ui_kit/test` and
`apps/dlm_gallery/test`.

## Guarantees

- **Every control is reachable and operable by keyboard.** Pressable controls share
  `DlmInteractive` (Tab to reach, Enter or Space to activate). Composite widgets are a single tab
  stop with arrow keys inside (table, tree, schedule grid, menus, sliders, split divider).
- **Every control has an accessible name.** The kit holds no strings; whatever a screen reader
  needs that the caller's data does not provide (clear, dismiss, show password, sort state, resize)
  is a required, localised parameter. A text field falls back to its placeholder.
- **Contrast.** Text 4.5:1 (7:1 in the high-contrast palette), focus ring and status colours 3:1
  (4.5:1), checked by `validateSkin` for every skin in light, dark and high contrast with several
  accents. `AccentPalette` adjusts an accent fill until its label reaches the ratio.
- **Hit targets** are at least 24 x 24 logical pixels at every density; the tests assert it.
- **Motion and transparency** follow the system: reduce motion zeroes durations and stops
  indeterminate animations, reduce transparency makes every material opaque.
- **Text scale** up to 200 % is applied through `MediaQuery`; the gallery smoke test renders every
  skin at 200 %.
- **Focus is visible** for keyboard use only (never after a mouse click) and is drawn by the skin.
- **Dialogs** trap focus, close on Escape, restore focus to the opener, and a destructive
  confirmation starts on Cancel.

## Keyboard map

| Where | Keys |
|---|---|
| Anywhere | Tab / Shift+Tab move between controls; Enter or Space activate |
| Menus, context menus | Up/Down move, Enter chooses, Esc closes, a letter jumps to the next matching item; Menu key or Shift+F10 opens a context menu |
| Dropdown | Enter, Space or Down opens; arrows and typing choose |
| Combo box | Typing filters, Down/Up move the highlight, Enter picks, Esc closes (focus stays in the field) |
| Slider | Left/Down and Right/Up step, Page Up/Down by 10 steps, Home/End to the ends |
| Data table | Up/Down, Page Up/Down, Home/End move the cursor; Shift extends the selection; Space toggles; Ctrl/Cmd+A selects all; Enter activates; Ctrl+Left/Right on a header resizes the column |
| Tree | Up/Down move; Right expands or enters; Left collapses or goes to the parent; Space checks; Enter activates |
| Schedule grid | Arrows move; Space toggles; Shift+arrows paint; Home/End jump to the ends of the day |
| Split view | Arrows resize by 16 px; Home/End jump to the limits; double click restores the default |
| Dialogs and sheets | Esc closes (unless the dialog is modal-required) |
| Search field | Esc clears |

## How it is tested

- Each widget's test asserts its semantics (label, role, checked/selected/expanded, actions) and
  its keyboard behaviour, not only that a callback fires.
- `apps/dlm_gallery/test/accessibility_audit_test.dart` walks the semantics tree of every gallery
  section under every skin and fails on any actionable node (tap, increase, decrease, text field)
  without a label or value. Nodes merged into a parent are one announced item and are skipped.
- `validateSkin` covers contrast, hit targets and scale ordering.

Manual checks with real screen readers (VoiceOver, Narrator/NVDA, Orca), 200 % text and high
contrast on each OS are F6.2.
