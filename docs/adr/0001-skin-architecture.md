# ADR-001: One UI kit, four skins

Status: accepted (2026-10-28) · Plan tasks: F2.1–F2.11

## Context

The app must feel native on macOS (Liquid Glass), Windows (Fluent/Mica), GNOME
(Adwaita) and KDE Plasma (Breeze), while every feature is available on every OS. The
Flutter ecosystem (checked October 2026) offers: `fluent_ui` (active), `macos_ui`
(a year old, no Liquid Glass), unofficial libadwaita widgets (too thin), nothing for
Breeze, and brand-new packages that embed real AppKit views (no keyboard or VoiceOver
access to them, immature). Flutter's own Material/Cupertino libraries are being split
into packages and will not gain Liquid Glass.

## Decision

1. **`dlm_ui_kit`** defines the vocabulary the app is written in: design tokens
   (colour roles, type scale, metrics, radii, materials, motion, density), a component
   API (`DlmButton`, `DlmDataTable`, `DlmSidebar`, …) and a **behaviour layer** that owns
   focus, keyboard handling, hit testing and `Semantics`, so these are identical and
   tested once.
2. A **`DlmSkin`** supplies the tokens and the visual builders of every component, plus a
   **shell pattern** (how sidebar, toolbar, content and inspector are arranged and what
   the window chrome looks like). Four skins: `dlm_skin_macos`, `dlm_skin_fluent`,
   `dlm_skin_adwaita`, `dlm_skin_breeze`. A skin depends only on `dlm_ui_kit`.
3. The **skin is chosen once at startup** from the OS/desktop environment (override in
   Preferences for testing) and can change live with the system's colour scheme,
   accent, contrast and reduce-motion settings.
4. **Native chrome is native; content is Flutter.** Window-level effects (macOS glass
   sidebar/toolbar, Windows Mica, GNOME header bar, KDE title bar) go through
   `dlm_platform` interfaces implemented by small plugins. Widgets inside the window are
   drawn by Flutter from the skin's tokens. Third-party packages (`fluent_ui`,
   `macos_window_utils`, `flutter_acrylic`, …) are used only behind those interfaces or
   inside one skin, so a stale package can be replaced without touching features.
5. **Information architecture is identical** on all OSes; only presentation differs.
   Features never import a skin or check the OS; the dependency rule is enforced in CI.
6. Single window. Flutter's multi-window support is experimental; inspectors, dialogs and
   sheets are in-window panes (revisit when the API is stable).

## Consequences

- More up-front work than "Material everywhere" (a kit of ~45 components × 4 skins) in
  exchange for a UI that follows each platform and a feature layer that is written once.
- Visual quality is guarded by goldens for every component × skin × light/dark ×
  high-contrast (F2.10, F6.5), reviewed on real machines before each beta.
- Adding a component means adding it to the kit and all four skins in one change; adding
  a platform look means adding a skin, nothing else.
- macOS Liquid Glass fidelity depends on a native plugin (F2.3 has a go/no-go review).
