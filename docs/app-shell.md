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
completed, failed) and `/queues/<id>`. The sidebar (a translucent glass pane on
macOS) lists the downloads filters, queues and categories; a gear button at its foot opens a menu
(Tools, Manage, Settings) and each opens a large window with its own list of pages
(`SettingsHub`). `/manage/<page>` and `/settings/<group>` are links into that window: it opens and
the page behind returns to the downloads. The shell is also the toolbar (title, selection actions, search, command palette, details toggle), the
page, and the details pane. Panels resize by dragging or with the keyboard and remember their
width; the details pane closes by itself below 1000 px. The command palette, search and add-download chords come from the shortcut
map (Command on macOS, Control elsewhere, overridable per command). A chord
already used by another command is refused, and reset restores the built-in
ones. Two more commands, Show or hide DLM and Add the link on the clipboard, work from any program on
macOS, Windows and X11 (`hotkey_manager`; on Linux it needs `libkeybinder-3.0`); they are off until a
chord is set, need a modifier, and are not offered on Wayland. Preferences also choose the size
units and the language. Sizes are drawn through one `DlmFormat` above the
window, so a change redraws every count. The language follows the system
unless a supported language is chosen. About can check GitHub releases of
this app: stable ignores prereleases, beta includes them. On Linux the result
opens the release page. Installing on macOS and Windows waits for the
packaged updater.

## Downloads list

A virtualized `DlmDataTable` in card mode (`rowBuilder` + `rowExtent`, so no header and no sideways
scrolling) over `taskListProvider`: pages in 100 rows at a time, follows the daemon's events, and
every `TaskCard` watches only its own task so a progress tick repaints one card. A card shows the
name and status, a progress bar, and size, speed, ETA, engine, queue and category as chips. Sorting
and grouping are in the Display menu.
Filters and queues map to daemon queries; search is the daemon's text filter. Selection is
shared (`selectionProvider`); Pause/Resume/Delete act on it from the toolbar, the right-click
menu, or the keyboard (Delete). Pause and resume offer Undo; delete asks first (the files stay
on disk unless the box is ticked) and has no Undo because a removed download cannot come back.

## Details pane

With one download selected the pane has four tabs (the choice stays when another download is
picked): **Overview** (progress, speed, time left, connections, queue, engine, folder, priority,
times and the last error), **Files** (a folder tree of the files; files that were not chosen are
marked), **Speed** (a live graph of the last 120 progress events, kept only while the pane is
open) and **Link** (current, first, page and referrer links, Renew now, Wait for a new link,
Replace link, and the renewal history). Replacing the link needs the download paused and asks the
daemon to start again if the file does not match.

Not there yet: the segments map (P13.4), changing the chosen files after the download exists
(P13.4), per-download setting overrides (they come with the settings form engine, F4.1) and a
per-download event log (the daemon has none).

## Queues

The sidebar lists the queues and has a New queue button. A queue page is a header (state,
Start/Stop, settings, a menu to rename, move up or down and delete) above that queue's downloads.
Deleting moves its downloads to the default queue, which cannot be deleted. Queue settings are
edited in a dialog: speed limit and a weekly schedule (a grid with one cell per hour, shown
as the daemon's time windows). Windows that need minutes, for example written with the command
line, are kept as they are until the user chooses the hourly grid, so opening and saving never
changes them.

`SyncEngine.events` exposes the daemon's events after the cache applied them. A finished queue
with an action at the end shows a banner with the seconds left (counted from the moment the event
arrived, so a remote daemon's clock does not matter). The daemon cancels the action when its queue
is stopped, so the banner's button stops the queue.

The dialog also edits speed profiles (a limit while chosen hours are active), a quota (bytes per
period) and what happens when the queue finishes (nothing, stop, sleep, shut down, or run a
program with arguments, after a grace period). They need a daemon from v0.3.0 on: older ones refuse
them ([dlm-server#128](https://github.com/sabadia/dlm-server/issues/128)).

## First-run setup

On the first start with the app's own download service a dialog shows the download folder
(chosen with the system's folder dialog and saved as the global `downloadDir`) and the helper
programs the daemon found (ffmpeg, yt-dlp, browser). It is also in the command palette as
"Setup and health check". It offers start at login and shows whether the browser
extension is paired. When this system has no menu-bar icon, it says that closing
the window quits. The login item starts the app with `--minimised` (on macOS the
launch event is used, because the system cannot pass arguments). A separate
preference installs the daemon's own `dlm service` entry, which keeps downloads
running without the app.

## Tray and notifications

`IntegrationBinder` draws nothing. It keeps a menu-bar icon while the tray
preference is on and this system can show one. Closing the window then hides the
app; the icon's menu shows the window, adds a download, pauses or resumes
everything, and quits. The speed is the icon's title on macOS and its tooltip
on the other desktops. Without an icon, closing the window quits.

A finished download, a failed download, an expired link, and a queue that has
finished post a system notification while that preference is on. The buttons
open the file, reveal it, or download it again. On Windows the toast uses the
AppUserModelID `io.github.sabadia.dlm` and one fixed activator GUID. A button
there has to carry both its own id and the download id, because Windows hands
back only one string.

While the window is in front and the clipboard preference is on (it stays off
until the user asks), the app reads the clipboard when the window comes
forward and every two seconds. It offers the first http, https, ftp, magnet
or ed2k link, and skips a link it has already offered. The clipboard text is
not written to the log.

## Menus

On macOS the commands live in the system menu bar: the application menu holds
About and Quit, and the Window menu adds the system's minimise, zoom and full
screen items. On Windows and Linux the same commands are a menu bar at the top
of the window, because those systems have no global menu bar. File holds add,
a new queue, setup, pause all and resume all. Go holds the lists and queues.
Window holds search, the command palette and the details pane.

## The window's place

The window opens where it was, including on a second display. The frame is
written back after a move or a resize. If that display is no longer connected,
the window is fitted onto the first display instead of opening off screen.

## Dock, taskbar and sleep

While the daemon reports downloads in progress, the app keeps the system from
idle-sleeping (the display may still sleep) and shows them on the dock or
taskbar. The badge is the number in progress. The bar is their combined
fraction, or a pulse when a size is not known yet. When nothing is running the
badge and the bar clear and the system may sleep. On Linux this uses
`systemd-inhibit` when it is installed. A finished queue that is set to sleep
or shut down still shows its countdown, and cancelling it stops the queue, so
the daemon does not run the action.

## Opening a link or a torrent

A second launch hands its arguments to the instance already running, over a
loopback port stored in the app's data directory, and then exits. The port file
holds a port number and never the link, and the link is not written to the log.
An empty hand-off only brings the window forward.

The app accepts `magnet:`, `ed2k:`, `http`, `https` and `ftp` links, a
`.torrent` file (a path or a `file:` URL), and a `dlm:` link. `dlm:` is either
`dlm:` plus one of those URLs (`dlm:https://example.com/a.bin`,
`dlm:magnet:?xt=urn:btih:abc`) or `dlm://add?url=` with that URL
percent-encoded. A `.torrent` file is read (16 MiB at most) and offered in the
add dialog; a link is filled into the same dialog.

macOS delivers an open to the running app as an Apple event, and the app bundle
declares the `magnet`, `ed2k` and `dlm` schemes plus the torrent document type.
Linux and Windows start a second process, which hands off the same way. The
installer registers those schemes with the system (F7).

## What is waiting for the daemon

These need backend phase 13 and are not worked around in the app: sorting by name or size,
filters by engine/category/size/date and per-queue counts in the sidebar (P13.5); the segments
map (P13.4); pattern preview and duplicate hints in the add flow (P13.6); the live speed and
quota in the status bar (P13.7, P13.8).
