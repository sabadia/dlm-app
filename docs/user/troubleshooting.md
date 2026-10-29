# Troubleshooting

## The app opens but shows a connection screen

The page says what happened:

- **Starting or connecting**: wait a moment. DLM starts its service and connects with the address and token
  the service wrote.
- **Needs trust**: a remote daemon's certificate is new. Check the fingerprint matches what the daemon's
  owner shows you, then trust it.
- **Incompatible**: the daemon's version does not fit this app. Update one of them; the app works with the
  API version in `packages/dlm_api/spec/PINNED.md`.
- **Token rejected**: the stored token is no longer valid. Replace it with a current one for that daemon.
- **Failed**: open **About, Diagnostics**, copy them, and look at the daemon log under Manage, Daemon.

## macOS says the app is damaged or cannot be checked

The builds are not signed yet. Right-click the app, choose **Open**, or run
`xattr -dr com.apple.quarantine /Applications/DLM.app`.

## Windows: "Windows protected your PC"

Choose **More info**, then **Run anyway**.

## `brew upgrade dlm@latest` fails

There is no such name. Use `brew upgrade dlm-app` for the app, `brew upgrade dlm` for the command-line
tool, or `brew upgrade` for everything. Homebrew 7 may ask you to trust the tap once:
`brew trust --tap sabadia/tap`.

## A global shortcut does nothing

It is off until you set it (Preferences, Shortcuts). It needs a modifier key. On Wayland it is not
available. On Linux with X11, install `libkeybinder-3.0`. Another program may already own the chord.

## There is no menu-bar or tray icon

Some Linux desktops have no tray. Then closing the window quits DLM (and the service it started). On GNOME
you need the AppIndicator extension for a tray.

## Downloads stop when I close the window

With a tray icon, closing hides the window and downloads continue. Without one, closing quits. To keep
downloads running without the app, turn on **Keep downloading without the app** in Preferences (it installs the daemon's own
`dlm service` entry).

## A video or audio page does not download

It needs `yt-dlp` and usually `ffmpeg`. See **Setup and health check** in the command palette for what DLM
found. Pages that hide the file may need the **Browser tool**.

## Reporting a problem

Open **About, Diagnostics**, copy them (they contain no secrets), and
[open an issue](https://github.com/sabadia/dlm-app/issues/new/choose) with what you did and what you
expected.
