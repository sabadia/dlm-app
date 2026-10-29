# Contributing

The plan in [docs/PLAN.md](docs/PLAN.md) is the authoritative specification; every
piece of work is a task in it with an issue on the
[project board](https://github.com/users/sabadia/projects). Rules of engagement:

1. **One task, one issue, one pull request.** Branch `feat/<issue>-<slug>` (or
   `fix/`, `docs/`, `chore/`), squash-merged with the pull request title as the
   commit message (Conventional Commits: `feat(ui-kit): ...`).
2. **Tick the task's checkbox in `docs/PLAN.md` in the same pull request.** Never
   change the plan to fit an implementation: if the plan is wrong or incomplete,
   open an issue saying why and wait for a revised plan.
3. **Definition of done:** `dart format` and `flutter analyze` clean; tests pass;
   goldens updated for all four skins × light/dark when the UI changed; keyboard
   and screen-reader behaviour checked; docs and changelog updated; **all** CI
   checks green before merging.
4. **Backend needs.** If a screen needs something the daemon cannot do yet, the
   task depends on a `P13.x` issue in
   [sabadia/dlm-server](https://github.com/sabadia/dlm-server); do not work
   around it in the app.
5. **Never commit secrets** (signing certificates, tokens, `.env` files). Signing
   material lives in GitHub Actions secrets only.

## Layout

See "Architecture" in the plan. Feature code depends on `dlm_ui_kit`, never on a
skin; skins depend only on `dlm_ui_kit`; the API client is generated.

## Setting up

```
git clone https://github.com/sabadia/dlm-app && cd dlm-app
fvm install          # the Flutter and Dart versions are pinned in .fvmrc
dart pub get         # one pub workspace for every package
dart run dlm_tools:test_all --exclude-tags golden
```

Run the app on your desktop with `cd apps/dlm_app && flutter run -d macos` (or `windows`, `linux`). It
starts the `dlm` daemon it finds: set `DLM_DAEMON` to a binary, or put `dlm` on your `PATH`.
`bash tools/fetch_daemon.sh <version> <dir>` downloads a checksum-verified release.
Linux needs the packages listed in `.github/workflows/ci.yml` (GTK 3, `libkeybinder-3.0` and friends).

The tools in `tools/dlm_tools` are the checks CI runs; run the same before you push:
`check_imports` (who may depend on whom), `check_l10n`, `check_licenses`, `test_all`.

## Guides

- [Engineering conventions](docs/CONVENTIONS.md): how code is written. Mandatory.
- [Add a component to the UI kit](docs/contributing/add-a-component.md)
- [Add a skin](docs/contributing/add-a-skin.md), and how to add a language
- [The UI kit](docs/ui-kit.md) and [the app shell](docs/app-shell.md): how the pieces fit
- [Packaging and releases](docs/packaging.md)
- [Manual test checklist](docs/manual-tests.md): what only a person on that OS can check

## Intent records

This repository uses [intentline](https://github.com/sabadia/intentline): a change of any size carries a
short record of why it was made. CI checks it. Drafts are made with `intentline capture`; affirming a
record is for a human reviewer, never for tooling.
