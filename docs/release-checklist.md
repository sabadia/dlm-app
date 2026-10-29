# 1.0 criteria and release checklist

## What 1.0 means

1.0 is the first release we call stable on all four desktops. It is reached when **every** line below is
true. Lines that cannot be checked by a machine name who checks them.

### Product

- [ ] Every screen in `docs/PLAN.md` M3 and M4 works against the pinned `dlm` release (the end-to-end tests
  and the nightly contract job are green).
- [ ] Nothing in "What is waiting for the daemon" (`docs/app-shell.md`) is still waiting, or the gap is
  stated in the release notes.
- [ ] A first-time user can install, add a download and finish it without help (a person who has not seen
  the app tries it, on each OS).

### Native on every desktop

- [ ] Skins: macOS, Windows (Fluent), GNOME (Adwaita) and KDE (Breeze) are each reviewed **on a real
  machine** by a person on that desktop, light and dark, and their reports in `area/native-look` are
  closed (PLAN F2.4 to F2.7).
- [ ] The manual checklist (`docs/manual-tests.md`) is done on each OS for the release candidate.
- [ ] Screen reader pass on VoiceOver, Narrator or NVDA, and Orca (PLAN F6.2).
- [ ] Languages: the first extra languages chosen and translated (PLAN F6.3).

### Quality

- [ ] CI is green on the release commit: analyze, tests on three OSes, golden images, build, end-to-end on
  three OSes, licences and SBOM, intent records.
- [ ] Performance budgets hold (`docs/performance.md`) on the release candidate.
- [ ] No open issue labelled `bug` with data loss, a leaked secret, a crash on start, or no workaround.
- [ ] The threat model (`docs/threat-model.md`) has been re-read against what changed since it was
  written, and its "stays open" list is accepted.

### Packaging

- [ ] The first stable release went through GitHub Releases and Homebrew end to end, and an upgrade from
  the previous release installed over it (`brew upgrade dlm-app`; the installer on Windows; the package on
  Linux).
- [ ] macOS builds are signed and notarised and Windows installers are signed, **or** the release notes and
  README keep saying they are not (PLAN F7.1, F7.2). Signing is not required for 1.0 unless you decide it is.
- [ ] Checksums, the SBOM and the provenance attestation are attached, and a download verifies against them.

### Documents

- [ ] User guide matches the release (`docs/user`); its screenshots are current (CI checks this).
- [ ] The changelog or release notes say what changed and what is known to be missing.

## Cutting a release

Releases are cut from `main` with everything merged and CI green.

1. Decide the version (semantic: `MAJOR.MINOR.PATCH`; a beta is `X.Y.Z-beta.N`, a candidate `X.Y.Z-rc.N`).
2. Check `packaging/daemon-version`: the `dlm` release the app bundles and is tested against, and
   `packages/dlm_api/spec/PINNED.md`.
3. Tag and push: `git tag -a vX.Y.Z -m "DLM X.Y.Z" && git push origin vX.Y.Z`.
4. The **Release** workflow builds the macOS DMG, the Windows installer and zip, and the Linux tar.gz, deb
   and rpm, adds `SHA256SUMS`, the SBOM and a provenance attestation, and publishes the GitHub release
   (a version with a `-` is marked a prerelease).
5. For a stable version the same workflow starts **Homebrew**, which writes `Casks/dlm-app.rb` to
   `sabadia/homebrew-tap`. Prereleases never go to Homebrew.
6. Verify, on a machine that did not build it:
   - the release has every file and `sha256sum -c SHA256SUMS` passes;
   - `brew update && brew upgrade dlm-app` (or `brew install --cask sabadia/tap/dlm-app`) installs the new
     version, and it opens and starts its bundled daemon;
   - About shows the new version and "up to date".
7. If something is wrong, fix forward with a new patch version. Do not move a published tag. A bad
   release can be edited into a prerelease on GitHub, and the cask corrected by publishing the next one.

## After the release

- Close the milestone's cards on the board, and tick the plan items that were met (not the ones that were
  not).
- Read the first day of issues. A start-up crash or a data-loss bug gets a patch release the same day.
