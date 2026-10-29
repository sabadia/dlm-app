# The app shell (M3)

How the running app is put together. Code: `apps/dlm_app/lib/src/`.

## Start-up

`main` opens the preferences and profile files, locates the bundled `dlm` binary
(`DLM_DAEMON`, the app bundle, or `PATH`) and runs the app inside one guarded zone (Flutter
needs the binding and `runApp` in the same zone; crashes are written to the log directory).
Everything the app needs from the outside is a Riverpod provider overridden in `main`
(preferences, profile store, local daemon, window chrome, system appearance), so tests run the
whole app on fakes.

## Connection

`ConnectionController` (a Riverpod notifier) is the only place that talks to the supervisor and
the connector. For the local profile it starts or adopts the daemon, then connects with the
address and token it wrote; for a remote profile it uses the stored token and pinned
certificate. The result is a sealed `ConnectionStatus`: connecting, ready (with the session),
needs trust, incompatible, token rejected, failed. `ConnectionGate` shows the app only when
ready and a state screen otherwise. `sessionProvider` is overridden at the root to follow the
connection, and the task store is recreated per connection, so nothing from another daemon
survives a reconnect.

## Pages

`go_router` with one `ShellRoute`: `/downloads/<filter>` (all, active, queued, paused,
completed, failed) and `/queues/<id>`. The shell is the sidebar (a translucent glass pane on
macOS), the toolbar (title, selection actions, search, command palette, details toggle), the
page, and the details pane. Panels resize by dragging or with the keyboard and remember their
width; the details pane closes by itself below 1000 px. Cmd/Ctrl+K opens the command palette,
Cmd/Ctrl+F focuses the search.

## Downloads list

A virtualized `DlmDataTable` over `taskListProvider`: pages in 100 rows at a time, follows the
daemon's events, and every cell watches only its own task so a progress tick repaints one row.
Filters and queues map to daemon queries; search is the daemon's text filter. Selection is
shared (`selectionProvider`); Pause/Resume/Delete act on it from the toolbar, the right-click
menu, or the keyboard (Delete). Pause and resume offer Undo; delete asks first (the files stay
on disk unless the box is ticked) and has no Undo because a removed download cannot come back.

## What is waiting for the daemon

These need backend phase 13 and are not worked around in the app: sorting by name or size,
filters by engine/category/size/date and per-queue counts in the sidebar (P13.5); the segments
map (P13.4); pattern preview and duplicate hints in the add flow (P13.6); the live speed and
quota in the status bar (P13.7, P13.8).
