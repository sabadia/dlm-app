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
