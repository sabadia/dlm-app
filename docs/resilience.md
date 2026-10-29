# Resilience (F6.7)

What happens when things go wrong, and which test proves it.

| Scenario | Behaviour | Tests |
|---|---|---|
| **Daemon crash** | The supervisor notices, restarts with a pause that grows, gives up after repeated crashes and says why (exit code and last lines, no secrets). Data survives; a client of the old address fails fast. | unit: `packages/dlm_platform/test/daemon/daemon_supervisor_test.dart` (crash and restart, give up, never ready, launch error, adopt, replace); real: `apps/dlm_app/test_e2e/crash_test.dart` kills a real daemon and checks the restart, the surviving task and the failing old client |
| **Network loss** (event stream) | The hub reconnects with backoff and jitter, resumes after the last event id, reconnects on silence past the heartbeat, resets the backoff after a good frame; unknown or malformed events are skipped, not fatal. | `packages/dlm_api/test/event_hub_test.dart` |
| **Daemon unreachable** (REST) | Calls fail with a connection failure, not a hang; the shell shows the reconnecting and offline states and the crash recovery flow. | `packages/dlm_core/test/connection/connector_test.dart`, `apps/dlm_app/test/connection/connection_controller_test.dart`, `apps/dlm_app/test/status_banners_test.dart` |
| **Version mismatch** | An app too old for the daemon, or a daemon too old for the app, is said so in the connection layer and on the About page; a running daemon of another version is replaced. | `packages/dlm_core/test/connection/compatibility_test.dart`, `apps/dlm_app/test/about_test.dart`, supervisor test "replaces a running daemon of another version"; real: `test_e2e/e2e_test.dart` checks the real daemon's `minClientApi` against the app's |
| **100 000 tasks** | The cache loads 100 000 tasks and clears; lists page in 100 rows and build only what is visible. | `packages/dlm_core/test/perf/store_perf_test.dart`, `packages/dlm_ui_kit/test/perf_test.dart` |
| **Corrupt preferences** | Empty, whitespace, binary, truncated, wrongly typed, invalid UTF-8: the app starts with defaults, keeps the valid values, moves the damaged file to `.corrupt` and saves again. A file from a newer app is backed up before anything is saved. | `packages/dlm_core/test/prefs/preferences_test.dart`, `packages/dlm_core/test/resilience/damaged_files_test.dart` |
| **Corrupt profiles file** | Moved aside as damaged; the store works again. | `packages/dlm_core/test/connection/profile_store_test.dart` |
