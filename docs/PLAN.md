# dlm-app — Implementation Plan (v1)

Authoritative plan for the dlm desktop app. Approved 2026-10-28.

## Context

The dlm daemon (Go, `sabadia/dlm-server`, v0.2.1) is feature-complete: 49 REST operations, SSE events, MCP, plugins, webhooks, browser/cookies/credentials, queues, 3-level settings, categories, stats, import/export. The CLI covers all of it. What is missing is the product people actually use: a **cross-platform Flutter desktop app** that manages *everything* the backend can do, and looks native on each OS: macOS (latest "Liquid Glass"), Windows 10/11 (Fluent/Mica), Linux GNOME (Adwaita) and KDE Plasma (Breeze).

Decisions made with the user:

| Decision | Choice |
|---|---|
| Repo | New public repo **`sabadia/dlm-app`** (Apache-2.0) with its own GitHub Project board; backend enablers tracked in `sabadia/dlm-server` as **Phase 13** |
| Native look | One UI kit (`dlm_ui_kit`) + **four full skins**: macOS glass, Windows Fluent, GNOME Adwaita, KDE Breeze. Feature code never touches skin details. Staged: macOS → Windows → GNOME ship first, KDE follows before beta |
| Daemon | App **bundles and manages** the `dlm` binary (sidecar, random loopback port, tray-resident) **and** can connect to remote daemons (profile switcher, TLS pinning) |
| Scope | **Desktop only**: macOS 13+, Windows 10 22H2+/11, Linux (GNOME 45+, KDE Plasma 6, Wayland+X11). Mobile/web not planned; architecture does not preclude them |
| Name | Product "dlm" until the user gives a brand; placeholder icon until assets arrive |

State of the ecosystem (researched Oct 2026, to be re-verified in F0.3/F1.2 before pinning):
- Flutter **3.47** stable (12 Aug 2026), Dart 3.13; Material/Cupertino are now standalone packages (`material_ui`, `cupertino_ui`); Flutter team is **not** building Liquid Glass into Cupertino. Canonical now leads Flutter desktop. **Multi-window is still experimental** (main channel only) → single-window design; inspector/dialogs are in-window panes/sheets.
- `fluent_ui` 4.17 is active (Flutter Favorite) → base for the Windows skin. `macos_ui` 2.2.2 is a year old with no Liquid Glass → *not* used as the base. `macos_window_utils` 1.9.1 (vibrancy, transparent title bar, toolbar) is usable; macOS 26 glass needs a small **own Swift plugin** (NSGlassEffectView). `native_macos` (real AppKit views) is brand new (1 star), breaks keyboard/VoiceOver reach → not for production.
- Linux: `libadwaita` (unofficial widgets, ~121 downloads/30d) is too thin; **no Breeze/KDE widget package exists** → own Adwaita and Breeze skins. `xdg_desktop_portal` (Canonical, 0.1.x) gives colour-scheme/accent via the settings portal; KDE colours/fonts come from `kdeglobals`.
- `flutter_acrylic` 1.1.4 (Mica/Acrylic on Windows) is ~18 months stale → spike in F2.4, fallback is a small own plugin. `auto_updater` (Sparkle/WinSparkle) is 2 years stale → own thin Sparkle 2 wrapper if it fails the spike.
- OS integration (researched 29 Oct 2026, versions from pub.dev): tray `tray_manager` 0.8.0 (Linux uses StatusNotifierItem over D-Bus, no icon-click events; GNOME shows it only with the AppIndicator extension, which Ubuntu enables); window hide/show `window_manager` 0.5.2; notifications with actions `flutter_local_notifications` 22.3.3 (`local_notifier` is stale); login item, clipboard watcher and in-app shortcuts need no package (own code in `dlm_platform`). `hotkey_manager` 0.2.3 is stale and X11-only on Linux; Wayland global hotkeys need the GlobalShortcuts portal, which `xdg_desktop_portal` 0.1.15 lacks → decided in F5.7. All behind `dlm_platform` interfaces with fakes.

## Architecture

```
dlm-app/                      pub workspace (Dart workspaces, no melos)
  apps/dlm_app/               runners (macos/windows/linux), main, shell, DI, routes
  packages/
    dlm_api/                  generated REST client + SSE client + auth/TLS pinning + problem decoding
    dlm_core/                 repositories, Riverpod controllers, event store, optimistic updates, formatting
    dlm_ui_kit/               tokens, skin contract, behaviour layer (focus/keys/semantics), component API
    dlm_skin_macos/ _fluent/ _adwaita/ _breeze/     the four skins
    dlm_platform/             window chrome, tray, notifications, autostart, deep links, daemon supervisor,
                              portals, secure store, updater, power
    dlm_l10n/                 ARB files, generated localizations
  tools/  docs/  packaging/   gen scripts, ADRs + user docs, per-OS installers
```

- **Dependency rule** (enforced by a lint in CI): `app → core, ui_kit, platform`; `core → api`; skins → `ui_kit` only; features never import a skin. Same spirit as the backend's hexagonal layout.
- **State**: Riverpod (verify v3 API in F0.3); go_router; immutable models (freezed or built-in records/sealed classes, decided in ADR-002). The daemon is the source of truth: UI keeps a **normalised entity cache** patched by SSE events; list views are windowed (cursor pages) and re-fetched on `reset` events.
- **Skin contract**: `DlmSkin` provides tokens (colour roles, type scale, metrics, radii, materials/blur, motion, density) and component builders; `DlmButton`, `DlmDataTable`, `DlmSidebar`… delegate to the active skin while a shared behaviour layer owns focus, keyboard, hit-testing and `Semantics`. Each skin also defines a **shell pattern**: macOS translucent sidebar + unified toolbar + right inspector; Windows NavigationView + CommandBar + Mica title bar; GNOME header bars + split view + preferences rows + toasts; KDE sidebar/toolbar with System-Settings-style pages. Information architecture is identical everywhere.
- **Theme sync**: OS/DE detection (macOS NSApp appearance/accent, Windows UISettings, GNOME `org.freedesktop.appearance` portal, KDE `kdeglobals` watcher) with live updates for dark/light, accent, high contrast, reduce-motion, text scale; user override in Preferences.
- **Icons**: semantic icon map per skin (SF-style set on macOS via bundled open set, Segoe Fluent on Windows, Adwaita symbolic on GNOME, system Breeze theme on KDE) + licence audit (F2.9).
- **Performance budgets** (verified in F6.1): cold start < 1.5 s to first frame; 50 000 tasks in the list scrolling at 60 fps (120 on ProMotion); 1 000 progress events/s without dropped frames; idle CPU < 1 %; RSS < 250 MB with 10 000 tasks.
- **Security**: tokens only in OS secure storage (Keychain / Credential Manager / libsecret), never logged; remote TLS pinning (trust-on-first-use dialog showing the fingerprint); post-action `command`/`av-scan` builder and plugin install show explicit warnings; deep links are validated and never auto-start without confirmation (setting).

## Coverage matrix — every backend capability has a UI home

| Backend capability (operationIds) | Where in the app |
|---|---|
| Tasks: create/resolve/batch/import/export, pause/resume/restart/delete/move/reorder/update, source edit, refresh/await-link/history, effective settings, stats | **Downloads** (list, bulk bar, context menu, drag-reorder), **Add download** flow, **Task inspector** (Overview · Files · Speed · Segments · Source & refresh · Settings · Events), **Import/Export** wizard, **Statistics** |
| Queues: CRUD/start/stop/reorder, settings override + effective, schedule, speed profiles, quota, post-queue action | **Queues** sidebar group + queue page; schedule/profile editors; countdown/cancel banner on `queue.completed` |
| Settings (global/defaults/patch/replace) incl. retry, proxy+rules, UA/headers/TLS, file-exists, checksum, refresh, post actions, torrent, browser usage, autoCategorize | **Settings** pages (schema-driven form engine with provenance chips: *default · global · queue · task*; reset-to-inherit) |
| Categories (+match) | **Categories** manager with drag order and live match tester; preview in Add flow |
| Cookies (list/import/export/delete) · Credentials (CRUD) | **Cookies** and **Logins** managers (domain tree, Netscape/JSON import-export, reveal-on-demand) |
| Webhooks (CRUD/test) | **Webhooks** manager + delivery log |
| Plugins (list/install/enable/remove) | **Plugins** manager: install from folder/git, permission review (hooks + `net` hosts), logs |
| Browser (status/resolve-page/download-candidate/profiles), capture | **Browser tool** (open page, candidates list, download), profile cleanup; extension pairing/native-host install |
| Events (SSE) | Live everything; status bar; notifications; tray; connection indicator |
| Health / version | Connection profile, compatibility gate, About |
| MCP endpoint | **Integrations** page: endpoint URL, token reveal, copy-paste config snippets |
| Boot config (torrent/ed2k/ytdlp/ffmpeg/browser/http impersonation/log/server) | **Daemon** settings editor with restart prompt (needs B2) |
| Logs, tools status, shutdown/restart | **Diagnostics**: log viewer, engine/tool status & updates, restart daemon (needs B1, B3) |

## Backend changes required (new `dlm-server` Phase 13, one issue + PR each, with tests and CLI parity)

| ID | Change | Why the UI needs it |
|---|---|---|
| P13.1 | **Discovery & lifecycle**: `--address 127.0.0.1:0`; atomic `runtime.json` (pid, address, version, startedAt, TLS fingerprint) in the config dir; single-instance lock per home; `POST /v1/system/shutdown` and `/restart`; `GET /v1/system/info` (version, `apiVersion`, commit, OS/arch, paths, uptime, `local` flag, engines enabled, tool status ffmpeg/yt-dlp/browser with version+source, DB size) | Bundled-daemon supervision, remote vs local gating, Diagnostics |
| P13.2 | **Boot config API**: `GET/PATCH /v1/config` (effective values, source, `restartRequired`, secrets redacted) + `dlm config get/set` | Edit torrent/ed2k/http-impersonation/log/server options in the UI |
| P13.3 | **Logs**: `GET /v1/logs` (filters) + `GET /v1/logs/stream` (SSE) + `dlm logs` | Log viewer, support bundles |
| P13.4 | **Task detail**: `GET /v1/tasks/{id}/segments`; `PATCH /v1/tasks/{id}/files` (change file selection after creation, incl. torrents); `GET /v1/tasks/{id}/torrent` (peers, trackers, ratio, seeding state); progress events gain `uploadSpeed`, `peers` | Segments map, torrent file picker/peers pane |
| P13.5 | **List power**: filters `engine`, `label`, `category`, size/date ranges; sorts (name, size, created, completed); `total` count; per-queue status counts on `GET /v1/queues`; **bulk** `move`, `update` (priority/labels/queue/settings), `restart`, `refresh` | Sidebar badges, saved views, large-list UX, multi-select actions |
| P13.6 | **Add-flow helpers**: `POST /v1/tasks/expand` (pattern preview), `dryRun` on import, `POST /v1/resolve/batch`, `duplicateOf` hint in resolve results, `GET /v1/fs/browse` + `/fs/free` (remote-safe directory picker, limited to `server.fs_roots`) | Preview-before-add, duplicate warnings, picking folders on a remote daemon |
| P13.7 | **Live & historical stats**: `system.speed` SSE event (down/up bps, active, queued, 1 s) and `GET /v1/stats/timeline?bucket=hour|day&groupBy=engine|queue` | Status bar/tray speed without summing progress events; charts |
| P13.8 | **Limits & turbo**: `GET /v1/limits` (current limits, active profile, quota used) and `POST /v1/limits/override` (temporary global speed limit/unlimited for N minutes) | Status-bar quota meter, "alt-speed/turbo" toggle |
| P13.9 | **Observability of integrations**: webhook delivery log (`GET /v1/webhooks/{id}/deliveries`), plugin logs (`GET /v1/plugins/{name}/logs`) | Webhooks/Plugins manager debugging |
| P13.10 | **Multi-client sync**: `resource.changed {kind,id,op}` SSE event for categories, webhooks, credentials, cookies, plugins, config | Several app windows/devices stay in sync |
| P13.11 | **API ergonomics**: stable machine `code` (+`params`) on every problem response; typed per-event SSE schemas (oneOf/discriminator); **OpenAPI 3.0.3** downgrade served at `/openapi-3.0.json` and published per release (Dart generators); `apiVersion`/`minClientApi` in health; `GET /v1/settings/schema` or `x-dlm-*` schema extensions (group, unit, min/max, levels, restart, secret); ETag/If-Match on settings | Generated client, localisable errors, schema-driven settings forms, no lost updates |
| P13.12 | **Auth/remote**: `GET /v1/auth/whoami`, `POST /v1/auth/token/rotate`, named scoped tokens (admin / read-only); `dlm tls init` (self-signed cert + fingerprint) | Remote profiles, token rotation, safe read-only dashboards |
| P13.13 | **Local integrations**: `GET/POST /v1/native-host` (status/install/uninstall, local-only); `dlm service install|uninstall|status` (launchd / systemd user / Windows startup) | Extension pairing UI; start at login |
| P13.14 | **Housekeeping**: `POST /v1/tasks/cleanup` (completed older than N days, optionally files), `retention` setting | History management |

## Frontend tasks

Each task is one issue and one pull request. Tick the box in the same PR that completes it. Backend enablers (P13.x) live in `sabadia/dlm-server`; a task marked *needs* cannot be finished before them.


### M0 Bootstrap

- [x] F0.1 Create the dlm-app repository — Public repo `sabadia/dlm-app`, Apache-2.0, NOTICE, README, SECURITY, CODEOWNERS, issue and PR templates; protect `main` (pull requests, linear history, squash-only; required checks are added with F0.4).
- [x] F0.2 GitHub Project board, labels, milestones and issues — Project `dlm-app` (Backlog/Ready/In progress/In review/Done), labels (`area/*`, `type/*`, `os/*`), milestones M0-M8, an issue for every task in docs/PLAN.md; backend enablers P13.x created in dlm-server and cross-linked.
- [x] F0.3 Toolchain pin, workspace, lints, conventions and ADRs — Pin Flutter 3.47.x / Dart 3.13 (`.fvmrc`, re-verify versions), pub workspace, strict analysis options, formatter, import-rule lint for the package dependency rules, intentline hook, CONVENTIONS.md, ADR-001 (skin architecture), ADR-002 (state and models).
- [x] F0.4 CI: analyze, test, goldens, builds, dependency hygiene — Analyze + test on ubuntu/macos/windows, golden job in a pinned Linux container with pinned fonts, debug builds per OS, caching, Dependabot, licence check, SBOM; then add the checks as required on `main`.
- [x] F0.5 Commit the plan; contribution and design docs skeleton — `docs/PLAN.md` is the authoritative plan; CONTRIBUTING and docs skeleton.

### M1 Foundations

- [x] F1.1 Package skeleton with enforced dependency rules — Workspace packages dlm_api, dlm_core, dlm_ui_kit, dlm_skin_*, dlm_platform, dlm_l10n and the app; a CI lint fails on forbidden imports (features never import a skin).
- [x] F1.2 API client: generator spike, generated models, typed wrapper *(needs P13.11)* — Spike swagger_parser vs openapi-generator dart-dio vs hand-written client over generated models (criteria: OpenAPI 3.0, nullable/optional handling, sealed event unions). Wrapper adds auth, timeouts, cancellation, problem decoding. Contract test against the pinned daemon spec.
- [x] F1.3 SSE client and EventHub — Last-Event-ID resume, `reset` event -> refetch, heartbeat timeout, backoff, filters, backpressure; deterministic tests with a fake server.
- [x] F1.4 Connection profiles: local (managed) and remote *(needs P13.11, P13.12)* — Secure token storage (Keychain / Credential Manager / libsecret), TLS pinning with a trust-on-first-use dialog, API-version compatibility gate.
- [x] F1.5 Daemon supervisor *(needs P13.1)* — Locate the bundled binary, start `dlm serve --home <app data> --address 127.0.0.1:0`, read runtime.json, wait healthy, crash-restart with backoff and a visible reason, graceful quit or keep-running, daemon update after app update, single instance.
- [x] F1.6 Domain layer: repositories and controllers — Tasks (windowed, patched by events), queues, settings (layered + provenance), categories, cookies, credentials, webhooks, plugins, stats, browser; optimistic updates with rollback; normalised entity cache.
- [x] F1.7 Problem-to-message mapping and toast/banner policy *(needs P13.11)* — Map problem `code`/`location` to localised text and field errors; one policy for toasts, banners and dialogs.
- [x] F1.8 Formatting and units — IEC vs SI sizes, speeds, durations/ETA, relative dates, locale; parsing of size and duration input.
- [x] F1.9 Preferences store — UI prefs, column layouts, window state, per-profile data, with migrations.
- [x] F1.10 Local diagnostics — Rotating app log, redacted 'copy diagnostics' bundle, crash capture; no network, no telemetry.

### M2 UI kit and skins

- [x] F2.1 Design tokens, skin contract and theme-sync service — DlmSkin: colour roles, type scale, metrics, radii, materials, motion, density; shell patterns per skin.
- [x] F2.2 Component inventory and behaviour layer — About 45 components: buttons, toggles, segmented/tabs, inputs (text/search/number/size/duration/password), dropdowns, slider, progress, list row, virtualized data table, tri-state tree, sidebar/nav, toolbar/command/header bars, menus, dialogs/sheets/popovers, toasts/banners, tooltips, badges, empty/loading/error states, grouped form rows, weekday x time window editor, resizable panes, chart wrapper, skeletons. Shared focus/keyboard/semantics.
- [x] F2.3 macOS skin: Liquid Glass — Own Swift plugin (NSGlassEffectView on macOS 26+, NSVisualEffectView on 13-25), transparent title bar, system accent and semantic colours, native menu bar. Includes a go/no-go screenshot review.
- [ ] F2.4 Windows skin: Fluent / Mica — Built on fluent_ui; Mica/Acrylic (spike flutter_acrylic, fallback own plugin), custom title bar with caption buttons and snap layouts, system accent, NavigationView, ContentDialog; Windows 10 fallback.
- [ ] F2.5 GNOME skin: Adwaita — Header bars (CSD), split view, preferences rows, toast overlay, dialogs, portal colour-scheme and accent, rounded window with shadow on Wayland/X11.
- [ ] F2.6 KDE skin: Breeze — Breeze controls, toolbars, System-Settings-style pages, colours and fonts from kdeglobals, system icon theme, server-side title bar.
- [ ] F2.7 Window chrome layer — Title bar styles, minimum size, restore, fullscreen, translucency toggle per OS in dlm_platform.
- [x] F2.8 OS/DE detection, live theme sync, user override — Dark/light, accent, high contrast, reduce motion, text scale; Preferences: Native/Light/Dark, accent, skin override for testing.
- [x] F2.9 Semantic icon system and app icons — Per-skin icon map with licence audit; app icon set.
- [x] F2.10 Kit gallery app and golden tests — Every component x 4 skins x light/dark/high-contrast.
- [x] F2.11 Kit accessibility and keyboard specification — Semantics, focus order, keyboard map, tested.

### M3 Core experience

- [x] F3.1 App shell and navigation — Information architecture, sidebar (All, Active, Queued, Paused, Completed, Failed, Queues, Categories, Tools), toolbar, inspector pane, responsive widths, command palette (Cmd/Ctrl+K).
- [x] F3.2 Downloads list *(needs P13.5)* — Virtualized; columns (name, status, progress, size, speed, ETA, queue, category, added, engine); densities, grouping, sort/filter/search, saved views.
- [x] F3.3 Selection, bulk operations, context menus, drag and drop *(needs P13.5)* — Bulk pause/resume/delete/move/priority/restart/refresh, drag reorder and drop onto a queue, confirm-with-undo for destructive actions.
- [x] F3.4 Task inspector *(needs P13.4)* — Overview, Files (tree + selection), Speed graph, Segments map, Source and refresh (edit URL, await link, history), per-task settings overrides, Events/errors.
- [x] F3.5 Add-download flow *(needs P13.6)* — Paste/many/pattern with preview, .torrent/.txt/JSON/aria2 files, magnet/ed2k, resolve preview with file tree, duplicate warning with 'add anyway', category preview, queue/dir/name, mirrors, checksum, headers/referrer, cookies/login helpers, yt-dlp/browser modes, batch result sheet.
- [x] F3.6 Queues UI — CRUD, start/stop, order, counts, schedule editor, speed profiles, quota, post-queue action with countdown/cancel.
- [x] F3.7 First-run onboarding and health checks — Download folder, tools (ffmpeg/yt-dlp), start at login, tray, browser extension. *(needs F5.1, F5.3, F5.10)*
- [x] F3.8 Status bar and quick controls *(needs P13.7, P13.8)* — Down/up speed, active/queued, turbo toggle, pause/resume all, quota meter, connection state.
- [x] F3.9 Empty, error, offline and reconnecting states — Daemon-crashed recovery flow.

### M4 Management screens

- [x] F4.1 Settings form engine *(needs P13.11)* — Schema-driven plus curated layouts, Global/Queue/Task levels with provenance chips, reset-to-inherit, 422 `location` to field errors, unsaved-changes guard, settings search.
- [x] F4.2 Global settings pages — General, Downloads, Connections, Speed, Network (proxy + rules, UA, headers, TLS), Refresh, Post-processing builder (extract, add-torrent, command, av-scan with warnings), Torrent/ed2k/yt-dlp/ffmpeg, Browser usage.
- [x] F4.3 Categories manager — Rules, drag order, live match tester.
- [x] F4.4 Logins and Cookies managers — Domain tree, Netscape/JSON import-export, reveal on demand.
- [x] F4.5 Webhooks manager *(needs P13.9)* — CRUD, test, delivery log.
- [x] F4.6 Plugins manager *(needs P13.9)* — Install from folder/git, permission review (hooks + net hosts), enable/disable/remove, logs.
- [x] F4.7 Browser tool — Resolve a page, candidates list, download, profile cleanup, tool status.
- [x] F4.8 Import/Export wizard *(needs P13.6)* — JSON/URL list/aria2, dry-run preview, results.
- [x] F4.9 Statistics, history and cleanup *(needs P13.7, P13.14)* — Charts by day/engine/queue, totals, completed history search, cleanup.
- [x] F4.10 Daemon and server settings *(needs P13.2, P13.3, P13.12, P13.13)* — Boot-config editor with restart flow, listen/TLS/allowed origins, token rotate, native-host/extension status, MCP page with copyable configs, log viewer, tools status.
- [x] F4.11 App preferences — Appearance, language, density, units, notifications, tray, startup, shortcut editor, clipboard watcher, confirmations. *(needs F5.1, F5.2, F5.3, F5.5 and the in-app part of F5.7)* Units: a `DlmFormat` inherited widget in `DlmApp.builder` carries unit system and locale, and the ~35 `formatBytes`/`formatSpeed` calls become `context.bytes(n)`/`context.speed(n)`, so a change rebuilds dependants without global state. Language: set `WidgetsApp.locale` from the pref (null = system); the picker lists `supportedLocales` plus System (English only until F6.3).
- [x] F4.12 About, updates and licences — Version and compatibility, licences, update channel pref and "Check for updates" reading the channel's appcast (GitHub Releases of `sabadia/dlm-app` until F7.4 publishes appcasts; prereleases count as beta). Installing is handed to Sparkle/WinSparkle (F7.1/F7.2); on Linux the action links to the release page, as Flatpak and distro packages update through their store.

### M5 System integration

- [x] F5.1 Tray / menu-bar item — Speed, pause all, quick add, show/quit. `tray_manager` + `window_manager` (close to tray, show/hide); speed as the title on macOS; menu only on Linux. Without a tray (GNOME without the extension) closing the window quits, and onboarding says so.
- [x] F5.2 Actionable notifications — Completed, failed, queue finished, link expired. `flutter_local_notifications` (notification portal inside Flatpak); actions Open / Show in folder / Retry; AUMID + GUID on Windows.
- [x] F5.3 Start at login and start minimised *(needs P13.13)* — `dlm service`, login item, Run key, autostart entry. Own `LoginItem` in `dlm_platform`: macOS `SMAppService.mainApp` (new method in `DlmPlatformPlugin.swift`), Windows HKCU Run via `win32_registry` (MSIX `StartupTask` in F7.2), Linux XDG autostart file or the Background portal inside Flatpak; started with `--minimised`. `dlm service` is the separate daemon-only option ("keep downloading without the app").
- [x] F5.4 URL handlers, file associations and instance hand-off — `magnet:`, `ed2k:`, `dlm:`, `.torrent`; open-with; forward to the running instance. A second launch sends the targets to the first over a loopback port (`instance.port` holds only the port) and exits; macOS also receives Apple-event opens. `dlm:` is `dlm:` plus an http, https, ftp, magnet or ed2k URL, or `dlm://add?url=` with that URL encoded. A `.torrent` path is read into the add dialog (16 MiB at most). OS registration of the schemes beyond the macOS bundle is F7.
- [x] F5.5 Drag-and-drop and clipboard watcher — Drop `.torrent` files and text files with links on the window (`desktop_drop` ^0.8.0 behind `DropZone`; 0.9 needs `cross_file` 0.4, which the workspace's other packages do not allow yet) to open the add dialog. Clipboard watcher: no package; `Clipboard.getData` on window focus and every 2 s while focused; opt-in, off by default; offers only links (http/https/ftp/magnet/ed2k), never logs clipboard text, skips a value already offered.
- [x] F5.6 Dock/taskbar progress, sleep prevention, power actions — Badges, prevent sleep while active, post-queue sleep/shutdown confirmations. The badge is the active count and the bar is the combined fraction (`window_manager`; above 1 pulses). Sleep is held off with `ProcessInfo` on macOS, `SetThreadExecutionState` on Windows and `systemd-inhibit` on Linux. The countdown banners are the confirmation; the daemon runs the action.
- [x] F5.7 Global hotkeys and shortcut map — The in-app shortcut map is done. Global hotkeys (decided 2026-10-29): `hotkey_manager` on macOS, Windows and X11 only, behind a `GlobalHotkeys` interface in `dlm_platform`; absent on Wayland, where the settings say why. One shortcut shows/hides DLM, one adds from the clipboard, both editable in the shortcut editor. Spike the package on the current Flutter first; if it does not build on every OS, stop and ask.
- [x] F5.8 Window-state restore and multi-monitor — The saved frame is applied at launch, including a window that still overlaps a second display. A frame that would open off every attached display is fitted onto the first and is not maximised. Moves and resizes are written back to `ui.window`.
- [x] F5.9 Native menus — macOS menu bar, Windows/Linux application menu. macOS uses `PlatformMenuBar` (About and Quit in the application menu, plus the system window items). Windows and Linux get the same commands as a menu bar in the window.
- [x] F5.10 Browser-extension pairing helpers *(needs P13.13)* — Onboarding and preferences rows over `GET/POST /v1/native-host` (reuse `nativeHostProvider`); local profiles only (403 `native_host.local_only`).

### M5b UI polish and brand

Added 2026-10-29 after the first look at the app (user feedback). One branch, one PR.

- [x] F5.11 Brand: name and icon — Product name **DLM** (menu bar, About, tray, notifications, window titles); macOS `PRODUCT_NAME = DLM` with its `project.pbxproj` references, bundle id and Linux application id `io.github.sabadia.dlm`; Dart package, Windows/Linux binary `dlm_app`, data directory `dlm` and the daemon binary `dlm` stay. Icon: rounded square, indigo-to-blue gradient, white download arrow inside an open progress ring, drawn as a `CustomPainter`, exported at 1024 px and turned into the macOS icon set, `.ico`, Linux PNGs and a monochrome tray template by a generator under `tools/`.
- [x] F5.12 Hidden scrollbars — A `ScrollBehavior` with `scrollbars: false` in `DlmThemeScope` and the app; the table's own scrollbar removed. Wheel, trackpad, drag and keyboard scrolling stay.
- [x] F5.13 Card list — The downloads list is cards, no horizontal scrolling: `DlmDataTable` gets `rowBuilder` and `rowExtent`; `TaskCard` shows name and status, a progress bar, and size/speed/ETA/queue/category/engine chips. Sorting moves into the Display menu. Selection, drag, reorder, grouping and keyboard stay.
- [x] F5.14 Modern inputs and selection — New tokens for field fill, softer border, focus glow, selection tint, card shadow and radii; filled fields with a soft focus ring; selected rows and sidebar items as a rounded accent-tinted card with a slim accent edge. Done inside each of the four skins so each keeps its OS character.
- [x] F5.15 Toolbar icons — New glyphs `group`, `columns`, `viewOptions`, `cards`; the gear stays only for settings.
- [x] F5.16 Settings hub — One gear button in the sidebar footer opens a small menu (Tools / Manage / Settings); each opens a large popup window with its own left list of that section's pages. The sidebar loses those three sections; the `/manage` and `/settings` routes stay as deep links that open the hub; unsaved-changes guard kept.
- [x] F5.17 Theme defaults and accent — Brightness and accent follow the OS (already true); one brand accent only when the OS reports none; a stored custom accent shown correctly in Preferences.
- [x] F5.18 Manual test checklist — `docs/manual-tests.md`: per OS steps for tray, notifications, login item, start hidden, sleep hold, taskbar progress, file drop, menus, window restore. The macOS part is run by the user; Windows and Linux by a tester before beta.

### M6 Quality

- [x] F6.1 Performance suite and budgets — Cold start < 1.5 s; 50 000 tasks scrolling at 60 fps; 1 000 progress events/s; idle CPU < 1 %; RSS < 250 MB with 10 000 tasks. Suite and numbers in `docs/performance.md`: the cache and a 50 000-row list are tested with budgets; cold start, idle CPU and memory were measured on macOS; Windows and Linux numbers come with the beta.
- [ ] F6.2 Accessibility pass per OS — VoiceOver, Narrator/NVDA, Orca; keyboard-only; high contrast; 200 % text. Done: the automated pass on the real screens (names, contrast, 200 % text, high contrast, keyboard) in `docs/accessibility.md`, which found and fixed four layout and contrast problems. Not done: the screen-reader runs on each OS (steps in `docs/manual-tests.md`).
- [ ] F6.3 Internationalisation — All strings in ARB, pseudo-locale, RTL, plurals; English plus first extra languages. Done: a test fails on any visible text written into the code; the pseudo-locale `en_XA` (generated by `packages/dlm_l10n/tool/gen_pseudo.dart`, hidden from the language picker) shows untranslated text and breaks layouts that cannot take longer text (it found and fixed a wrapping placeholder); `dlm_tools:check_l10n` checks placeholders and plurals of every translation; the kit uses start/end instead of left/right and has right-to-left tests. Not done: the first extra languages (needs the choice of languages and translators); daemon-provided setting names stay in English; a right-to-left run of the whole app.
- [x] F6.4 End-to-end tests against a real daemon — Linux headless under xvfb; macOS and Windows runners. `apps/dlm_app/test_e2e` runs the app's client, event stream, cache and actions against a real daemon on all three runners (no display needed, so no xvfb); whole-window UI tests against a daemon are not part of it.
- [x] F6.5 Visual regression across skins and themes `apps/dlm_app/test/golden/screens_golden_test.dart` renders the downloads page, the settings window and the add dialog in every skin, light and dark (24 images, pinned CI image, regenerated by the goldens workflow); the kit's component goldens stay in the gallery.
- [x] F6.6 Threat model and security review — Token at rest, TLS pinning, post-action warnings, plugin consent, deep links, clipboard privacy. `docs/threat-model.md`: assets, trust, threats with their answers and tests, and what stays open; the review found and fixed two issues (a newline smuggled into the add dialog through a link, an unbounded read on the single-instance port).
- [x] F6.7 Resilience tests — Daemon crash, network loss, version mismatch, 100k tasks, corrupt prefs. Scenarios and their tests are listed in `docs/resilience.md`; the daemon crash is also tested against a real daemon.
- [x] F6.8 Nightly contract job against the newest dlm release `.github/workflows/nightly-contract.yml` (cron and manual): newest release, the e2e tests, and `dlm_tools:check_contract` against the pinned OpenAPI.

### M7 Packaging and release

> **Scope decision, 2026-10-30:** for now the app is released only as a **GitHub release for every OS** and
> through **Homebrew** (F7.6). **No app store**, and the work that exists only for stores or for trust
> prompts is **deferred, not dropped**: Developer-ID signing and notarisation, Sparkle 2, MSIX and Windows
> signing, the Flathub submission, winget and Scoop. Until then the macOS and Windows builds are unsigned
> (macOS: right-click, Open, or `xattr -dr com.apple.quarantine /Applications/DLM.app`; Windows: SmartScreen
> "Run anyway") and say so in the README and the release notes. Items below keep their text; the deferred
> parts are the ones named here. The templates in `packaging/` for the deferred channels stay as starting points.

- [ ] F7.1 macOS packaging — Universal app embedding dlm, hardened runtime, Developer-ID signing, notarisation, DMG, Sparkle 2 updates (non-sandboxed; Mac App Store out of scope). The DMG is the asset the Homebrew cask points at (F7.6); the app can tell it was installed by Homebrew and then leaves updates to `brew upgrade`.
- [ ] F7.2 Windows packaging — Signed MSIX and EXE/MSI installer, protocol handlers, autostart, winget/Scoop manifests, SmartScreen guidance.
- [ ] F7.3 Linux packaging — Flatpak (Flathub submission, AppStream metainfo, portals), .deb/.rpm, optional AppImage, desktop entry, MIME, autostart.
- [ ] F7.4 Release pipeline — Tag, build all OS, sign, publish GitHub release and update feeds, bundle a pinned dlm version with checksum verification, SBOM and provenance attestation. Its last step writes the Homebrew cask (F7.6).
- [ ] F7.5 Update channels, rollback and compatibility matrix — Stable/beta channels; app-daemon version compatibility; one appcast per channel, the app reads its channel's feed.
- [ ] F7.6 Homebrew cask (`brew install` and `brew upgrade`) *(added 2026-10-29; needs F7.1, F7.4)* — The app is installed from the existing tap: `brew install --cask sabadia/tap/dlm-app` (cask token **`dlm-app`**; `dlm` is the CLI's cask, so the app needs its own). The cask lives in `sabadia/homebrew-tap` next to `dlm.rb` and is written by the app's release workflow after the GitHub release exists: a step fills a template (`packaging/homebrew/dlm-app.rb.tmpl`: version, the DMG's sha256, url `…/releases/download/v#{version}/DLM_#{version}.dmg`, `app "DLM.app"`, `depends_on macos: ">= :ventura"`) and pushes it with a deploy key that can write to that one repository (the pattern dlm-server's GoReleaser uses; the secret is that key, never a broad token). A universal DMG means one url and one sha256, no `on_arm`/`on_intel`. **Upgradable through brew:** the cask has no `auto_updates true` (that makes `brew upgrade` skip it) and no `version :latest`; it has `livecheck { url :url; strategy :github_latest }` so `brew livecheck` and `brew bump` work; `uninstall quit: "io.github.sabadia.dlm"` closes the running app before it is replaced; and the app's bundled daemon is stopped when the app quits unless the user chose to keep it running, so no old binary stays loaded. `zap trash:` lists the app's data (`~/Library/Application Support/dlm`, preferences, caches) for `brew uninstall --zap`. No `binary` stanza: the bundled `dlm` is for the app, and a user who wants the CLI installs `sabadia/tap/dlm`, so the two casks never fight over `/opt/homebrew/bin/dlm`. **In-app updates:** when the app finds it was installed by Homebrew (its bundle is the target of `…/Caskroom/dlm-app/<version>/DLM.app`), Sparkle is off and the About page says "Update with `brew upgrade dlm-app`"; otherwise Sparkle updates as planned in F7.1/F7.5. **Tested in CI** on a macOS runner with its own Homebrew: install the previous release's cask, then run the new cask's `brew upgrade --cask dlm-app` and check that the new version is installed, the app launches, and nothing from the old version is left; also `brew audit --cask --online` and `brew style`. **User docs** (tap README and the app README): the install and upgrade commands, that Homebrew 7 asks to trust a third-party tap (`brew tap sabadia/tap`, then `brew trust --tap sabadia/tap` if asked), and that **there is no `dlm@latest`**: the upgrade is `brew upgrade dlm-app` (or `brew upgrade dlm` for the CLI, or plain `brew upgrade` for everything); Homebrew has no alias for casks, so a `@latest` name cannot be added and a `brew upgrade dlm@latest` error is expected. The same note goes into the CLI cask's README entry in the tap (`sabadia/homebrew-tap`, a one-line pull request; the CLI cask itself is written by dlm-server's release and stays as is).

### M8 Docs and launch

- [x] F8.1 User guide — Getting started, per-feature guides, troubleshooting, shortcuts. `docs/user/`, written from the code and the app's own strings; a first-time-user test with a real person is on the 1.0 checklist.
- [ ] F8.2 Screenshots and GIFs generated from goldens — Screenshots done: `dart run dlm_tools:export_screenshots` copies the golden images to `docs/images`, CI fails when they are stale, and the guide uses them. **GIFs are not made** (a golden is a still image); they need a recorded session, so this stays open.
- [x] F8.3 Contributor guide — How to add a component and how to add a skin. `CONTRIBUTING.md` (set-up) and `docs/contributing/` (component, skin, language).
- [x] F8.4 Beta programme and feedback templates `docs/beta.md`; issue forms for beta feedback and native-look reports next to the bug form.
- [x] F8.5 1.0 criteria and release checklist `docs/release-checklist.md`: what 1.0 requires and how a release is cut and verified.

**Delivery order**: M0 → P13.1/P13.11 (unblock client + supervisor) → M1 → F2.1–F2.3 + F3.1–F3.2 as a macOS vertical slice → Windows, GNOME skins → rest of M3/M4 (F5.1, F5.2, F5.3, F5.5, F5.10 and the in-app part of F5.7 are pulled ahead to finish F3.7/F4.11/F4.12) → P13.x as each screen needs them → M5 → M5b → KDE skin → M6 → M7 → beta → 1.0. Internal alpha after M3 on macOS/Windows/GNOME; public beta when KDE and M4–M6 are done.

## Working rules (same discipline as the backend)

One task at a time; branch `feat/<issue>-<slug>`, PR, squash-merge, card moved on the board; tick the box in `docs/PLAN.md` in the same PR. Definition of done: `dart format`, `flutter analyze` clean, tests pass, **goldens updated for all four skins × light/dark** when UI changes, accessibility checks pass, perf budget unaffected, docs/CHANGELOG updated, intentline record captured (never affirmed by an agent), CI matrix green. Only merge with *all* checks green (lesson from the backend release). A plan change is requested, never silently made.

## What I need from you (none blocks M0–M2)

1. **App identity** — decided 2026-10-29: product name DLM, an icon drawn in-repo (F5.11), accent follows the OS; Flatpak/bundle ID `io.github.sabadia.dlm`.
2. **macOS signing** (deferred, see the M7 scope decision; needed by F7.1 only when signed builds are wanted): Apple Developer Program membership → Developer ID Application certificate (.p12 + password), Team ID, and an App Store Connect API key (or app-specific password) for notarisation, plus a Sparkle EdDSA keypair (I generate it; you store the private key as a secret).
3. **Windows signing** (deferred; F7.2): either Azure Trusted Signing (cheapest, recommended) or an OV/EV code-signing certificate; optional Microsoft Partner Center account if you want the Store later.
4. **Linux** (deferred): a Flathub account (GitHub login) for the submission PR.
   **Homebrew** (F7.6): a deploy key for `sabadia/homebrew-tap` (write access to that repository only) stored as the `HOMEBREW_TAP_DEPLOY_KEY` secret of `sabadia/dlm-app`, the same way dlm-server does it; I give the exact `ssh-keygen` and `gh` commands.
5. **GitHub**: the existing `gh` login is enough to create the repo/board/labels/issues; secrets for signing are set later by you (I give exact commands).
6. **Visual feedback on Windows/KDE/GNOME**: I can only run the macOS build locally. For the other skins I verify through CI screenshots (goldens, Linux under xvfb with GNOME/KDE themes, Windows runner) — but I will need you (or a tester) to look at real machines before beta and report what feels non-native.
7. **Backend priority**: OK for me to start Phase 13 in `dlm-server` (P13.1 and P13.11 first) as soon as you approve this plan.

## Risks and mitigations

- *Liquid Glass fidelity*: Flutter widgets cannot refract content behind them → glass is applied at **window/sidebar/toolbar level natively**; content panes stay Flutter-drawn; pre-26 uses vibrancy. Spike in F2.3 with a go/no-go screenshot review.
- *Stale packages* (`flutter_acrylic`, `auto_updater`, `macos_window_utils` on macOS 26): isolate behind `dlm_platform` interfaces so replacing them with own small plugins is local.
- *KDE/GNOME authenticity without toolkit widgets*: tokens read from the live system (colours, fonts, icon theme, accent), Breeze/Adwaita metrics from their published style guides; KDE is last in order so lessons from GNOME carry over.
- *Multi-window is experimental*: single-window UX; revisit detached inspectors when the API is stable.
- *No tray on GNOME / unpackaged Windows toasts*: GNOME needs the AppIndicator extension for the tray, so the app must work without one; unpackaged Windows toasts can't be listed or cancelled, MSIX can (F7.2).
- *Flatpak sandbox vs bundled daemon*: daemon runs inside the sandbox with `xdg-download` + portal access; remote-daemon mode is the escape hatch; verified in F7.3.
- *Large lists / event floods*: windowed queries, coalesced progress, per-row `select`ors, no whole-list rebuilds; budgets enforced in CI (F6.1).
- *API drift*: generated client + nightly contract test (F6.8) + `apiVersion` gate (F1.4).

## Verification

After approval the first actions are: create the repo, board, labels, milestones and ~90 issues (frontend F-tasks and backend P13.x), commit this plan as `dlm-app/docs/PLAN.md`, add Phase 13 to `dlm-server/docs/PLAN.md`, then start F0.3. Each task's own acceptance check: CI green on the 3-OS matrix; goldens for 4 skins; for integration features an E2E run against the real bundled `dlm`; for packaging a CI dry-run producing signed-less artifacts, and a manual install checklist per OS before each release.
