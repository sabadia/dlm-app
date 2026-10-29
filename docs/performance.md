# Performance (F6.1)

The budgets of the plan, what enforces them, and what was measured. Numbers marked *test* come from
the automated suite; numbers marked *app* were taken on a release build on a Mac.

| Budget | Enforced by | Measured |
|---|---|---|
| Cold start under 1.5 s | measured by hand (below) | *app* 0.27 s to the first window on a warm start, 0.79 s the first time after a build (Apple silicon, macOS 27, release build) |
| 50 000 tasks scroll at 60 fps | `packages/dlm_ui_kit/test/perf_test.dart` | *test* the first frame of 50 000 cards builds only the visible ones (under 30), and the p95 of a frame while scrolling is within 100 ms in a debug VM with software rendering, which is far slower than a release build |
| 1 000 progress events a second | `packages/dlm_core/test/perf/store_perf_test.dart` | *test* the task cache applies about 3 million events a second, so 1 000 a second costs a few hundredths of a percent of a core; the test budget is 5 000 events in 250 ms |
| Idle CPU under 1 % | measured by hand (below) | *app* 0.5 % with the window open, no download running (the daemon alone 0.1 %) |
| RSS under 250 MB with 10 000 tasks | `store_perf_test.dart` for the cache, by hand for the app | *test* 10 000 tasks with live progress add 16 MiB to the cache; *app* 156 to 188 MB resident with a few tasks, so about 205 MB with 10 000 (a sum, not a measurement) |

Also asserted by the suite: 50 000 tasks are cached in 23 ms and found by id at once; 100 000 tasks
(a very large history) load and clear. The test budgets are about ten times the measured values so
a slow CI machine does not fail them, and a real regression does.

## How to run

```sh
cd packages/dlm_core && dart test test/perf
cd packages/dlm_ui_kit && flutter test test/perf_test.dart
```

Both also run with the normal test commands and in CI.

## Cold start and idle CPU by hand (macOS)

1. `cd apps/dlm_app && flutter build macos --release`.
2. Quit DLM and its `dlm` daemon, then `open -n build/macos/Build/Products/Release/DLM.app` and time
   until the window shows (a small Swift program polling `CGWindowListCopyWindowInfo` does it).
3. After 30 s idle: `top -pid <DLM pid> -l 3 -s 5 -stats pid,cpu,mem`; the last sample is the idle
   CPU. `ps -o rss` gives the resident size.

## What is not measured yet

- **Frames per second on a real screen** with a large list: the suite measures the work per frame,
  not the display. Profile-mode runs with the DevTools timeline belong to the beta.
- **Events end to end** (daemon to cache to repaint) at 1 000 a second with a real daemon.
- **Windows and Linux** cold start, idle CPU and memory; take them on the beta machines and add
  them to the table.
