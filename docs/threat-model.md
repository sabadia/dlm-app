# Threat model and security review (F6.6)

Reviewed 2026-10-29 against the code of `main` after M5b. Scope: this app and how it talks to the
dlm daemon. The daemon's own model lives in `sabadia/dlm-server`.

## What is protected

| Asset | Where it lives |
|---|---|
| The daemon's API token | the daemon's `config/token` file (mode 0600, checked) for the managed daemon; the OS secret store (Keychain, Credential Manager, libsecret) for remote profiles, never in `profiles.json` |
| Site logins, cookies, webhook secrets | in the daemon (cookie values encrypted with `cookies.key`, mode 0600); the app shows a secret only on an explicit reveal, once |
| TLS pin of a remote daemon | in `profiles.json` (a public fingerprint, not a secret) |
| The user's files and computer | what a download, a post-action or a plugin can touch |
| Clipboard contents | read only while the window is focused and the watcher is on |

## Who is trusted

- The **user** and the app they run.
- The **managed daemon** on the same machine, started by the app, listening on loopback with a token.
- A **remote daemon** only after the user pinned its certificate.
- **Not trusted:** web pages and other programs (they can hand the app a link), download sources
  (names, headers, redirects, contents), plugin manifests until the user reviews them, any other
  local process, and the network.

## Threats and what answers them

| Threat | Answer | Evidence |
|---|---|---|
| Token stolen from disk | Daemon token file is 0600; remote tokens only in the OS secret store; profile file holds no secret | `SecretTokenVault`, `profile_store_test.dart`; `ls -l` of the daemon's config on macOS |
| Token or credentials in logs, crash files or a support bundle | Everything logged passes the `Redactor` (bearer tokens, authorization and cookie headers, URL credentials, secret-looking keys, the live token, the home directory); the app logs almost nothing and never a link or the clipboard | `packages/dlm_core/test/diagnostics`, `about_test.dart` |
| Man in the middle of a remote daemon | Certificate pinning: only the exact certificate the user confirmed is trusted, CA trust switched off; trust on first use shows the fingerprint | `packages/dlm_api/test/tls_pinning_test.dart` |
| A malicious link opens a second download or a file | `dlm:`, `magnet:`, `ed2k:` and http(s)/ftp only; **any control character or space makes it not a link** (found in this review: a decoded newline could smuggle a second link into the add dialog); `file:` is accepted only as a `.torrent` path read from the launch arguments | `handed_open_test.dart` "hostile links" |
| A local process floods the single-instance port | One line, at most 1 MiB, read with a hard cap and a timeout (found in this review: the whole line was buffered first); what arrives only opens the add dialog, never adds | `instance_endpoint_test.dart` |
| A local process hands the app a link | Accepted: the dialog must be confirmed by the user; any process that can reach loopback can already talk to the user's session | documented |
| A download runs something | Post-actions that run a program or a virus scan are marked with warnings and need a program path; switching on is a deliberate edit | `settings_form_test.dart` "a program action warns" |
| A plugin does more than it says | Installing shows the permissions (hooks and network hosts) first; switching a plugin on is a grant | `plugins_screen.dart`, plugin tests |
| Clipboard snooping | The watcher is off by default, reads only while the window is focused, offers links only, never logs, and offers a value once | `clipboard_watch_test.dart` |
| Secrets shown on screen or copied by accident | Tokens and cookie values appear once on request; copy buttons are explicit | `access_screen.dart`, `cookies_screen.dart` |
| Supply chain | Licences checked against an allow list, SBOM per build, versions pinned by the lock file, the daemon fetched with a checksum check | CI jobs, `tools/fetch_daemon.sh` |
| Outdated or unreachable daemon | Version compatibility is checked and shown; a daemon of another version is replaced | `compatibility_test.dart` |

## Open or accepted

- **Remote profiles have no editor in the app yet.** The model and the pinned client exist, and a
  profile is stored without its token, but the screen that creates one does not. When it is built it
  must refuse plain `http://` to a non-loopback address (or warn and require a second confirmation)
  and require a pin for `https://` with a self-signed certificate.
- **The macOS app is not sandboxed** (`com.apple.security.app-sandbox` is false) because it runs a
  bundled daemon that writes where the user chooses. Hardened runtime and notarisation come with
  packaging (F7.1); Flatpak confines the Linux app (F7.3).
- **Update authenticity** (signed appcasts, EdDSA key) is part of F7.1, F7.2 and F7.4; the update
  check in the app only reads GitHub release metadata over HTTPS and installs nothing.
- **The instance port** accepts any local process (and on a shared machine any local user). The
  effect is limited to opening the add dialog with links that passed the filter above.
- **Native-messaging host** registration writes files into browser directories of the current user;
  it needs the daemon on the same machine and explicit extension ids.
- **TLS pin rotation:** a changed certificate is refused until the user re-trusts it; there is no
  automatic rotation.
- **Dependencies** are audited for licences, not for known vulnerabilities; add a scheduled
  `dart pub outdated`/advisory check before 1.0.

## How to re-run the review

Search for what reaches the outside: `Process.run`/`Process.start` (login item, file opener, daemon
service, awake lock), sockets (instance endpoint), file reads of paths that came from outside
(`readOpenedTorrent`, dropped list files: size capped), and every place a string from outside is
put in a dialog or a log. Then read the list above and check that each answer still holds.
