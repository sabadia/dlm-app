# Engineering conventions

These rules apply to every package. `docs/PLAN.md` is the authoritative spec;
this file covers *how* code is written. Architecture decisions are in `docs/adr/`.

## Toolchain
- Flutter and Dart are pinned in `.fvmrc`; use `fvm flutter ...` (or the pinned SDK on
  your PATH). CI uses the same version. Bumping the pin is its own pull request.
- Dependencies are managed in the pub workspace (root `pubspec.yaml`). Before adding a
  dependency check its latest version, its licence (must be Apache-2.0 compatible:
  MIT / BSD / Apache-2.0 / MPL-2.0 / ISC), its maintenance (last release, open issues)
  and its platform support for macOS, Windows and Linux. Prefer a thin interface in
  `dlm_platform` over spreading a package through feature code, so a stale package
  can be replaced locally.

## Layout and dependencies
- Package dependency direction (enforced by `dart run dlm_tools:check_imports` (rules in `tools/import_rules.yaml`), run in CI):
  `apps/dlm_app → dlm_api (models and failures only), dlm_core, dlm_ui_kit, dlm_platform, dlm_l10n, dlm_skin_*`;
  `dlm_core → dlm_api`; `dlm_skin_* → dlm_ui_kit`; `dlm_platform`, `dlm_api`, `dlm_l10n`
  depend on no other dlm package. The only place a skin is named is the app's skin
  registry. Features never import a skin.
- `lib/src/` is private to its package; export a deliberate API from `lib/<package>.dart`.
- No global mutable state and no singletons: dependencies are provided through
  Riverpod providers (ADR-002) and overridden in tests.
- OS-specific code lives only in `dlm_platform` (Dart `Platform` checks, FFI, and the
  native runners' plugin code). Feature and UI-kit code asks `dlm_platform` or the skin.

## Dart and Flutter
- `dart format` (default line length 80) and `flutter analyze` with zero issues. Do not
  silence a lint without a comment saying why.
- Null safety and strict casts/inference/raw types are on. No `dynamic` outside JSON
  decoding at the edge of `dlm_api`. No `!` on values that can legitimately be null.
- Immutable models; state changes through controllers. `const` constructors wherever possible.
- Widgets: small, composable, no business logic in `build`. Rebuilds are scoped with
  `select`. Anything that scrolls a large list is virtualised (`SliverList`/table).
- Async: `await` or hand the future to something that owns it; no unawaited futures
  (`unawaited_futures` lint). Every subscription, timer and controller has an owner that
  disposes it.
- Errors: typed failures from `dlm_api` (`ApiProblem` with the daemon's machine `code`);
  UI maps codes to localised text (F1.7). Never show a raw exception to the user and
  never swallow one silently.
- Logging through the app logger only; never log tokens, cookie values, passwords,
  `Authorization` headers or full URLs with credentials.
- Time: code that depends on the clock takes a `Clock`; store and compare in UTC.

## UI rules
- Every string is localised (`dlm_l10n`); no literals in widgets.
- Every interactive widget is reachable and operable by keyboard, has a semantic label,
  and keeps a ≥ 24×24 (desktop) hit target. Respect reduce-motion, high contrast and
  the OS text scale (up to 200 %).
- Colours, type, spacing, radii and motion come from tokens (`DlmTheme`), never literals.
- Do not hard-code platform looks in features; if a feature needs something the kit
  lacks, extend the kit (all four skins) in a separate task.
- UI changes update the goldens for all four skins × light/dark.

## Testing
- `flutter_test`; table-driven where it helps; no network, no real clock, no real
  filesystem outside `Directory.systemTemp`. Fakes over mocks for the daemon API.
- Goldens run only in the pinned Linux container with pinned fonts, so they are
  reproducible; update them by running the *Update goldens* workflow on your branch (Actions tab), which regenerates them on the CI image and commits them.
- Integration tests run against a real `dlm` daemon started on port 0 with a temporary home.
- A bug fix includes a test that fails without it.

## Git and review
- Conventional Commits; squash merge; one task per pull request; the plan checkbox is
  ticked in the same pull request. Never merge with a failing or pending check.
- Intent records: capture a draft for a change worth explaining; never affirm one
  yourself (affirming is a human act).
- Secrets and signing material never enter the repository.
