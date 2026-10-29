# Beta programme

The beta exists to check what automated tests cannot: that DLM feels at home on **real machines**. CI
renders every skin, but only on one Linux image with one font. Before 1.0 a person on each desktop must
look at it.

## Who and what

We want people on each of: macOS, Windows 10 or 11, Linux with GNOME, and Linux with KDE Plasma, and
especially people with unusual setups: high-DPI or mixed displays, 200 % text size, high contrast,
a screen reader, dark mode that follows the sun, a remote `dlm` daemon.

Please use it for real downloads for a few days, and try what is in the [manual test
checklist](manual-tests.md) for your system.

## Getting a beta

Beta builds are **prereleases** on the [releases page](https://github.com/sabadia/dlm-app/releases),
tagged like `v0.2.0-beta.1`. Download the file for your system (they are not signed yet; see the
[guide](user/getting-started.md#install)). Homebrew carries stable releases only. Choose **Beta** under
**Preferences, Update channel** and About will offer the next beta.

## Giving feedback

Use an issue form; it asks for what we need:

| You want to say | Form |
|---|---|
| Something broke | **Bug report** |
| It does not look or behave like your desktop | **It does not look or feel native** |
| How it felt, what confused you | **Beta feedback** |

Add the **Diagnostics** from the About page to bug reports; they contain no secrets.

## What happens to feedback

Issues are labelled by area (`area/...`), system (`os/...`) and kind. Anything that loses data, leaks a
secret or makes the app unusable is fixed before the next beta. Look and feel reports go to the skin
that owns them. Each beta's release notes list what changed so you can check your report.

## When the beta ends

The beta ends when every item of the [release checklist](release-checklist.md) is met.
