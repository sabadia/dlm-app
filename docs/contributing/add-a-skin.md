# Adding a skin

A skin is a complete look for one desktop (the four that exist: `macos`, `fluent` for Windows, `adwaita`
for GNOME, `breeze` for KDE). It changes presentation only; the app's pages and information architecture
are the same everywhere (ADR-001).

## Steps

1. **Package** `packages/dlm_skin_<name>`, modelled on `dlm_skin_macos`: a `pubspec.yaml` that depends
   only on `dlm_ui_kit` and `flutter`, `lib/dlm_skin_<name>.dart` exporting the skin, and its `src/`.
   Add the package to the `workspace:` list in the root `pubspec.yaml` and to
   `tools/import_rules.yaml` (`dlm_skin_<name>: [dlm_ui_kit]`).
2. **The skin class** extends `DlmSkin`: an `id`, a `shell` (`DlmShellPattern`: title bar, sidebar,
   toolbar, settings and feedback styles) and `tokens(DlmAppearance)`, which returns colours, type, metrics,
   materials and motion for the given brightness, contrast and accent. Use `AccentPalette.derive` for
   the accent and `DlmColors.derive` for the colour roles; do not compute contrast yourself. Add
   a `<name>SkinId` constant (see `macosSkinId` in `dlm_skin_macos.dart`).
3. **Components.** The defaults draw from your tokens and already pass the accessibility checks. Override
   a `DlmComponents` builder only where your desktop draws a control differently.
4. **Tests** in the skin package, as the other skins do: `expect(validateSkin(skin), isEmpty)` (contrast,
   focus ring, status colours, opaque surfaces, hit targets, in every appearance and density), the id
   matches the constant, and any pattern choices you made.
5. **Register** it in the only two files that may name a skin: `apps/dlm_app/lib/src/skin_registry.dart`
   (the `skins` map, and `defaultSkinId` if it should be chosen automatically for a platform or
   desktop) and `apps/dlm_gallery/lib/skins.dart`. Add the package to both apps' `pubspec.yaml`.
6. **Look at it.** Run the gallery (`apps/dlm_gallery`) in your skin, in light, dark and high contrast,
   at 200 % text. Run the *Update goldens* workflow on your branch: the app's screens and the gallery are
   rendered in your skin and the images are committed to the branch for review. They are also copied
   into the guide's screenshots (`dart run dlm_tools:export_screenshots`).
7. **Native effects** (translucency, accent and desktop colours, window chrome) live in `dlm_platform`,
   not in the skin. If your desktop needs one, that is a separate task.
8. **Real machines.** Goldens show layout, colour and shape (they all use one bundled font), not how it
   feels. A skin needs a look from someone on that desktop before it ships; add its checks to
   `docs/manual-tests.md`.

## Adding a language instead

Add `app_<code>.arb` to `packages/dlm_l10n/lib/l10n/` (copy `app_en.arb`, translate the values, keep the
keys and placeholders), run `flutter gen-l10n` in that package, and `dart run dlm_tools:check_l10n` to see
what is untranslated. The language picker lists it automatically; a missing message falls back to
English.
