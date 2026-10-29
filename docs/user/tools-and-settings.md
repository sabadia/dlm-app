# Tools and settings

The **gear button** at the foot of the sidebar opens a menu with three sections. Each opens a window with
its own list of pages on the left.

## Tools

- **Browser tool**: pages that need a real browser to reveal a download.
- **Import and export**: move your downloads and settings in and out (and import a list of links from a
  file).
- **Statistics**: totals and a timeline of what was downloaded.

## Manage

- **Categories**: where finished files go.
- **Logins** and **Cookies**: sign-ins the daemon uses for sites that need them. Secrets are kept in your
  system's secure storage, never written to the log, and a cookie's value is shown only when you ask.
- **Webhooks**: send a message to an address when something happens.
- **Plugins**: add-ons for the daemon, with an explicit consent step.
- **Daemon**: the connection (this computer or a remote `dlm`), its version, health and logs. Connecting to
  a remote daemon asks you to trust its certificate the first time.
- **Access**: who may use the daemon and with which token.
- **Preferences**: the app's own choices: theme (follows your system by default), accent colour (follows
  your system), size units, language, tray, notifications, clipboard watching, start at login, update
  channel and keyboard shortcuts.
- **About**: version, licences, diagnostics you can copy (without secrets), and **Check for updates**.

## Settings

These are the daemon's settings, with three levels: global, per queue and per download.

`General`, `Speed`, `Network`, `Retry`, `Refresh` (renewing expired links), `Post-processing`, `Torrent`,
`Browser`. Changes you have not saved are guarded: leaving the window asks first.

## Updates

About checks the releases of this app on GitHub. **Stable** ignores pre-releases; **Beta** includes them.
Installed with Homebrew, update with `brew upgrade dlm-app`; otherwise download the new file from the
release page.
