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
`.github/workflows/homebrew.yml` runs after the release exists (the release workflow starts it with `workflow_dispatch`, because a
release made with the workflow token does not fire `release: published`; publishing one by hand
does). The release is published straight away, not as a draft. It reads
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

## Windows and Linux package managers (templates)

`packaging/scoop/dlm.json.tmpl`, `packaging/winget/*.tmpl` and
`packaging/flatpak/io.github.sabadia.dlm.yml.tmpl` take `@VERSION@` and `@SHA256@` of the file
they point at. **None of them has been submitted or built.** winget (`microsoft/winget-pkgs`),
a Scoop bucket and Flathub each need an account and a review by their maintainers; the manifests
are the starting point for those submissions. MSIX needs a signing certificate and is deferred.

## Update channels and compatibility (F7.5)

- **Channels:** `stable` follows releases GitHub does not mark as prereleases; `beta` also takes
  prereleases (tags with a `-`, such as `v1.3.0-rc.1`, are published as prereleases by the release
  workflow). The About page picks the channel and checks the GitHub releases list
  (`apps/dlm_app/lib/src/about/updates.dart`). Homebrew skips prereleases.
- **App and daemon:** each release bundles the daemon in `packaging/daemon-version` (checksum
  verified at build time) and the app passes it as `DLM_DAEMON_VERSION`; a running older daemon
  that the app started is replaced, a daemon the user runs on their own is adopted as it is.
  The app works against the API contract pinned in `packages/dlm_api/spec/PINNED.md`; a remote
  daemon from another release works as far as that contract does, and the nightly contract
  workflow reports drift.
- **Not done:** Sparkle 2 (in-app install on macOS) and per-channel appcast feeds. They need an
  EdDSA key pair that you create and keep (the public key goes in the app, the private key in a
  secret) and a notarised build to test against, so they stay open under F7.1/F7.5.
