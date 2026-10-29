# Adding a component to the UI kit

A component belongs in `packages/dlm_ui_kit` when more than one screen needs it, or when it must look
different in each skin. A one-off arrangement of existing components stays in the app.

The split (ADR-001, `docs/ui-kit.md`): **the widget owns behaviour** (focus, keyboard, hit target,
semantics, state, layout of the content); **the skin draws the surface**. A skin never decides how
something behaves, and a screen never decides how something looks.

## Steps

1. **Widget** in `packages/dlm_ui_kit/lib/src/widgets/`. Build it on `DlmInteractive` for anything
   clickable (hover, press, focus ring, Enter/Space, minimum hit target and semantics come with it).
   Rules it must follow, all checked in review:
   - no strings: any text a user or screen reader meets that is not the caller's data is a required,
     localised parameter;
   - controlled state: the caller owns value, selection and sort; keep no second copy;
   - colours, type, spacing, radii and motion come from `DlmTheme.of(context)`, never literals;
   - keyboard operable, announced to assistive technology, at least 24 x 24 logical pixels.
2. **Surface.** If the component draws a surface that skins may want to change, add a builder method to
   `DlmComponents` in `src/components/components.dart` and draw the default in `DlmBaseComponents`
   (`base_components.dart`) from the tokens. Then only the skins that must differ override it
   (`fluent_components.dart`, the Adwaita and Breeze files). A glyph is a new `DlmIconName` with a case in
   `components/icon_painter.dart` and an entry in `docs/icons.md`.
3. **Export** it from `packages/dlm_ui_kit/lib/dlm_ui_kit.dart`.
4. **Tests** next to the kit: behaviour (keyboard, focus, callbacks) **and semantics** (assert the
   labels and roles, not only that a callback fires).
5. **Gallery.** Add it to the matching section in `apps/dlm_gallery/lib/sections/` (or a new section
   listed in `sections.dart`), with live controls. The gallery goldens render every section in every skin,
   light, dark and high contrast, so a new component is reviewed in all of them.
6. **Goldens.** Run the *Update goldens* workflow on your branch (Actions tab). Goldens are only valid
   on the pinned CI image; never commit images made on your own machine.
7. **Docs.** Add a row to the component table in `docs/ui-kit.md`.

## Before you open the pull request

```
dart format .
dart analyze --fatal-infos
dart run dlm_tools:check_imports
dart run dlm_tools:test_all --exclude-tags golden
```
