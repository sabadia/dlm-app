# dlm-app

The desktop app for [dlm](https://github.com/sabadia/dlm-server), a cross-platform
download manager. One Flutter codebase that looks native on every desktop:

| OS | Look |
|---|---|
| macOS 13+ | Liquid Glass (macOS 26) / vibrancy (13–25), native title bar and menu bar |
| Windows 10 / 11 | Fluent design, Mica / Acrylic, native caption buttons |
| Linux, GNOME | Adwaita: header bars, preferences rows, portal colours and accent |
| Linux, KDE Plasma | Breeze: toolbars, System-Settings-style pages, `kdeglobals` colours |

The app bundles and manages the `dlm` daemon (or connects to a remote one), and
everything the daemon can do is manageable from the UI: downloads, queues,
three-level settings, link refresh, categories, cookies and logins, webhooks,
plugins, the headless browser, statistics, import/export and diagnostics.

> **Status:** planning and bootstrap. Nothing is released yet. The plan, the
> architecture and the task list are in [docs/PLAN.md](docs/PLAN.md); progress is
> tracked on the [project board](https://github.com/users/sabadia/projects).

## Layout (planned)

```
apps/dlm_app/      the Flutter app and its platform runners
packages/          dlm_api, dlm_core, dlm_ui_kit, dlm_skin_*, dlm_platform, dlm_l10n
docs/              plan, architecture decisions, user guide
packaging/         per-OS installers
```

## Contributing

Work is planned in [docs/PLAN.md](docs/PLAN.md): one task per issue, one pull
request per task, squash-merged with all checks green.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
