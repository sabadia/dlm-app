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

## Adding a skin

Implement `DlmSkin` in its package, return tokens from `tokens(appearance)` (use
`AccentPalette`), pick the shell pattern, register its id in
`apps/dlm_app/lib/src/skin_registry.dart`, and add `expect(validateSkin(skin), isEmpty)`
to its tests. Component builders join the contract in F2.2.
