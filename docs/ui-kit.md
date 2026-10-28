# UI kit: tokens, skins and theme

Implements ADR-001. Code: `packages/dlm_ui_kit/lib/src/theme/`.

## Pieces

| Piece | Role |
|---|---|
| `DlmSkin` | A complete look. `tokens(appearance)` returns `DlmTokens`; `shell` returns the `DlmShellPattern`. Implemented by the four `dlm_skin_*` packages. |
| `DlmTokens` | `DlmColors` (semantic roles), `DlmTypography`, `DlmMetrics` (spacing, radii, heights, widths), `DlmMaterials` (opaque / translucent / glass per surface), `DlmMotion`. |
| `DlmShellPattern` | Title bar, sidebar, toolbar, settings and feedback styles of the window. Same information architecture on every OS; only presentation differs. |
| `DlmAppearance` | What the OS says: brightness, contrast, accent, reduce motion, reduce transparency, text scale. |
| `AppearanceOverride` | The user's Preferences: Native / Light / Dark, accent, text-scale multiplier, density, reduce-motion. |
| `AppearanceSource` | Live feed of `DlmAppearance`. `FlutterAppearanceSource` reads brightness, contrast, reduce motion and text scale from Flutter on every OS. Accent, desktop-environment colours and reduce transparency come from `dlm_platform` readers that the app adapts to this interface (F2.8); the kit knows nothing about the OS. |
| `DlmThemeScope` / `DlmTheme.of(context)` | Resolves skin + source + override into `DlmThemeData` and rebuilds dependants only when the result changes. Also sets the `MediaQuery` text scaler and `disableAnimations`. |

## Rules the kit enforces for every skin

- Density, reduce-motion and reduce-transparency are applied by the kit, not by the
  skin: heights scale with density but never drop below `minHitTarget` (24 px);
  reduce motion zeroes durations; reduce transparency makes every material opaque.
- The five surface colours are opaque. A translucent sidebar supplies its opaque
  fallback colour and describes the effect in `DlmMaterials`.
- `AccentPalette.derive` is the one way to honour an accent: `onAccent` is black or
  white, `accentText` is moved until it is readable on the surface, and in high
  contrast the accent fill itself is moved until its label reaches 7:1.
- `validateSkin(skin)` checks every skin in light/dark × standard/high contrast ×
  several accents × all densities: text contrast (4.5:1, 7:1 in high contrast),
  focus ring and status colours (3:1, 4.5:1), opaque surfaces, hit targets, ordered
  scales, translucent materials with a blur. Each skin's test must call it and expect
  an empty list.

## Components (F2.2)

All of them read the theme, own their behaviour in the kit and draw through
`DlmComponents` builders (`DlmBaseComponents` draws from the tokens; a skin overrides
only what it draws differently).

| Group | Widgets |
|---|---|
| Behaviour layer | `DlmInteractive` (hover/press/focus, Enter/Space, minimum hit target, semantics), `DlmDoubleClick` (double click without delaying the first click), `DlmFocusRing`, `DlmStates` |
| Actions | `DlmButton` (primary/secondary/destructive/plain), `DlmIconButton`, `DlmSplitButton`, `DlmMenuButton` |
| Choice | `DlmSwitch`, `DlmCheckbox` (tri-state), `DlmRadio`, `DlmSegmented`, `DlmTabBar`, `DlmDropdown`, `DlmComboBox`, `DlmSlider` |
| Text input | `DlmTextField` (single/multi line), `DlmSearchField`, `DlmPasswordField`, `DlmParsedField<T>` (sizes, durations: the app passes parse/format), `DlmNumberField` |
| Display | `DlmProgressBar`/`Ring`, `DlmBadge`, `DlmChip`, `DlmListRow`, `DlmIcon`, empty/error/loading states, `DlmSkeleton`, `DlmChartFrame` + `DlmChartPalette` |
| Feedback | `DlmBanner`, `DlmToastController` + `DlmToastHost`, `DlmTooltip` |
| Overlays | `DlmPopover`, `DlmMenuPanel`, context menus (`DlmContextMenuRegion`, `showDlmContextMenu`), `showDlmDialog` (dialog or sheet), `showDlmConfirm` |
| Structure | `DlmSidebar`, `DlmToolbar`, `DlmFormGroup`/`DlmFormRow`, `DlmSplitView` |
| Big widgets | `DlmDataTable<T>` (virtualized, sortable, resizable, selectable), `DlmTree` (virtualized, tri-state), `DlmScheduleGrid` (weekday x time) |

Conventions the widgets follow, and callers rely on:

- The kit holds no strings. Anything a screen reader or user reads that is not the
  caller's data (a clear button's name, "sorted ascending", dismiss labels) is a required,
  localised parameter, or part of `DlmTableLabels`.
- Controlled state: the caller owns values, selection, sort, widths and expansion, so
  they can be persisted; the widgets never keep a second copy.
- Everything is keyboard operable and announces itself to assistive technology; the
  tests assert the semantics, not only the callbacks.
- The app mounts `DlmThemeScope` inside `WidgetsApp.builder` (below the navigator) so
  dialogs and popovers inherit the theme.

Known gap, to be closed where the app has localisation (F4.11): the cut/copy/paste
context menu of text inputs. Keyboard shortcuts and selection work.

## Window chrome and backdrop effects (F2.3, F2.7)

`dlm_platform` owns the native window behind the `WindowChrome` interface (`apply`,
`capabilities`, `setBackdropRegion`). On macOS a small Swift plugin
(`packages/dlm_platform/macos`, Swift package with a podspec fallback) makes the title
bar transparent and puts an `NSGlassEffectView` (macOS 26+) or `NSVisualEffectView`
behind a *region* of the Flutter view. Flutter draws the tint and all content; the
native view only provides the blur Flutter cannot.

- The app calls `apply` after the first frame and reads what is in force. If the effect is
  unavailable it reports reduce-transparency, and the kit makes every material opaque.
- `BackdropRegion` wraps the sidebar and keeps the native region in step with it.
- `DlmThemeData.windowBackground` is transparent only while a backdrop can show through;
  content areas paint their own opaque colour, so the desktop never shows through them.
- `DlmThemeData.titleBarInset` is the height the traffic lights cover.

## Adding a skin

Implement `DlmSkin` in its package, return tokens from `tokens(appearance)` (use
`AccentPalette`), pick the shell pattern, register its id in
`apps/dlm_app/lib/src/skin_registry.dart`, and add `expect(validateSkin(skin), isEmpty)`
to its tests. Override the `DlmComponents` builders that must look different (the defaults are
token-driven and already pass the accessibility checks).
