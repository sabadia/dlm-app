# Packaging and release (M7)

How DLM is built into something a user installs. The pinned daemon is `packaging/daemon-version`;
every package embeds exactly that release, fetched with its checksum verified
(`tools/fetch_daemon.sh`).

## macOS (F7.1)

`tools/package_macos.sh <version> [outdir]` on a Mac:

1. `flutter build macos --release` with the version and a build number (universal: arm64 and x86_64);
2. fetches the arm64 and amd64 daemons, joins them with `lipo` and puts the result at
   `DLM.app/Contents/Resources/bin/dlm`, where the app looks for it;
3. signs inside out (daemon, frameworks, app) with the hardened runtime and
   `apps/dlm_app/macos/Runner/Release.entitlements`;
4. makes `DLM_<version>.dmg` (the app and an Applications link) and a `.sha256`;
5. with `NOTARY_PROFILE` (a keychain profile of `xcrun notarytool store-credentials`) it notarises
   the DMG and staples the ticket.

`SIGN_IDENTITY` is the `Developer ID Application: …` identity (or its SHA-1 when two certificates
share a name). Without one the bundle gets an ad-hoc signature, which keeps it valid after the
daemon is added but is not for distribution.

**Verified on a Mac:** the build is universal; the daemon is universal and 96 MB; with a real team
identity the app is signed with the hardened runtime (`flags=runtime`, one team id for every part)
and launches from the DMG's copy, and it starts the **bundled** daemon
(`…/DLM.app/Contents/Resources/bin/dlm serve`), not one from the PATH. **Not verified yet:** a
Developer ID certificate and notarisation (no certificate exists yet; see the list of what the
maintainer provides in `docs/PLAN.md`), and Sparkle updates.
