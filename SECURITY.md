# Security policy

## Reporting a vulnerability

Please report security problems privately through GitHub's
[private vulnerability reporting](https://github.com/sabadia/dlm-app/security/advisories/new)
rather than a public issue. Include the app and daemon versions, the operating
system, and steps to reproduce. You can expect an answer within a week.

## Scope

This app handles the daemon's API token (kept in the operating system's secure
storage), connects to local and remote daemons (TLS certificate pinning), and
can start programs through post-download actions configured by the user.
Reports about token handling, TLS pinning, URL-scheme handlers and update
integrity are especially welcome.

Only the latest release is supported with fixes.
