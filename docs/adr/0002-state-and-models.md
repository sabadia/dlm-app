# ADR-002: State management, routing and models

Status: accepted (2026-10-28); package versions are confirmed against pub.dev in the task
that adds each dependency (F1.2, F1.6) · Plan tasks: F1.2, F1.3, F1.6

## Context

The daemon is the source of truth and pushes changes over Server-Sent Events. The UI shows
long, fast-changing lists (tens of thousands of tasks, many progress updates per second),
several screens that share the same entities, and many forms with optimistic updates.

## Decision

- **State:** Riverpod, providers written by hand (no provider code generation), in
  `dlm_core`. Providers expose repositories and controllers; widgets use `ref.watch(...select(...))`
  so a progress tick rebuilds one row, not a list. Tests override providers with fakes.
- **Entities:** `dlm_core` keeps a **normalised cache** (`Map<id, Entity>` per kind) patched by
  `EventHub` events and by command results; list views hold ordered id windows (cursor pages)
  and re-fetch on `reset` events. Progress events are coalesced to one frame.
- **Writes:** commands go through repositories; controllers apply the change optimistically,
  and roll back with a visible, localised error if the daemon refuses (problem `code`).
- **Models:** `dlm_api` holds the generated transport models (from the daemon's
  OpenAPI 3.0 document, committed so CI does not need the generator). `dlm_core` maps them to
  immutable domain entities; unions (events, task status, errors) are Dart 3 `sealed` classes
  so `switch` is exhaustive. Boilerplate (`copyWith`, equality) uses `freezed` unless the
  F1.6 review shows hand-written value classes are simpler; the choice is made once there.
- **Routing:** `go_router` with a shell route for the app frame; routes are addressable
  (`/downloads/active`, `/queues/:id`, `/settings/network`) so deep links and the command
  palette use the same table.
- **Persistence:** UI preferences in a small typed store (F1.9); secrets only in the OS secure
  store; everything else is fetched from the daemon, not duplicated on disk.

## Consequences

- Fine-grained rebuilds and straightforward tests, at the price of discipline: widgets never
  hold daemon state in `State`, and every list item widget watches one entity by id.
- No second source of truth: after a crash or reconnect the UI is rebuilt from the daemon.
- Switching state libraries later would touch only `dlm_core` and widget `ref` usage.
