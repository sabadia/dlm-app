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

## Homebrew (F7.6)

`packaging/homebrew/dlm-app.rb.tmpl` is the cask; `tools/render_cask.sh <version> <sha256>` fills it.
`.github/workflows/homebrew.yml` runs when a release is **published** (not when the tag is pushed:
the release is a draft first, and the cask must not point at files nobody can download). It reads
the DMG's `.sha256` from the release, renders the cask, runs `brew style`, and pushes
`Casks/dlm-app.rb` to `sabadia/homebrew-tap` with the deploy key `HOMEBREW_TAP_DEPLOY_KEY`
(without the secret it renders and warns, and publishes nothing). Prereleases are skipped.
Pull requests that touch the cask run `brew style` on a placeholder checksum.

- `brew install --cask sabadia/tap/dlm-app` and `brew upgrade dlm-app`. There is no `dlm@latest`
  and Homebrew cannot alias casks; `dlm` is the CLI cask. Homebrew 7 may ask for
  `brew trust --tap sabadia/tap` once.
- The cask has no `auto_updates`, so `brew upgrade` handles it; `uninstall quit:` closes the app
  first and quitting the app stops the daemon it started.
- **In-app detection:** a cask copies the app into `/Applications` and leaves only a symlink in
  the Caskroom, so the app's own path does not show Homebrew. The app looks for
  `<prefix>/Caskroom/dlm-app` (`HOMEBREW_PREFIX`, `/opt/homebrew`, `/usr/local`) and then
  says "Installed with Homebrew: run brew upgrade dlm-app" in About instead of offering a download.
- `depends_on macos: :ventura` (Homebrew's style check rejects `">= :ventura"`).

**Not verified yet:** the install-then-upgrade test (needs two published releases and the tap
key) and `brew audit --online` (needs a live download URL). `brew style` passes locally.
