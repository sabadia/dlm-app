# Getting started

## Install

Download the file for your system from the
[releases page](https://github.com/sabadia/dlm-app/releases), or on macOS use Homebrew:

```
brew install --cask sabadia/tap/dlm-app
```

| System | Files |
|---|---|
| macOS 13 or later | `DLM_<version>.dmg`: open it and drag DLM to Applications |
| Windows 10 / 11 | `…_setup.exe` (installs for you only, no administrator needed) or the portable `.zip` |
| Linux | `.deb`, `.rpm` or `.tar.gz` |

Each file has a `.sha256` next to it, and `SHA256SUMS` lists them all.

**The builds are not signed yet.** The first time you open DLM:

- **macOS** says the app cannot be checked. Right-click DLM in Applications and choose **Open**, or run
  `xattr -dr com.apple.quarantine /Applications/DLM.app` once.
- **Windows** SmartScreen shows "Windows protected your PC". Choose **More info**, then **Run anyway**.

## First start

DLM starts its own download service, then asks (once) for:

1. **The download folder.** Everything is saved there unless a category or an add-time choice says
   otherwise. You can change it later in Settings.
2. **Helper programs.** DLM lists the tools it found: `ffmpeg` (joins video and audio), `yt-dlp` (video
   and audio pages) and a browser (pages that need one). Downloads of plain files work without them.
3. **Start at login** and the **browser extension** pairing, if you want them.

The same dialog is in the command palette as "Setup and health check".

## Add a download

Press **Ctrl+N** (**⌘N** on a Mac), or use the add button, or drop a link or a `.torrent` file on the
window. Paste one link per line: web addresses, magnet links, or a pattern such as
`http://host/img[1-20].jpg`. DLM looks at each link and shows what it found. You can pick the queue, the
folder and a name, and **Add without starting** if you want to start later. Under **More options** there
are the referrer, headers, mirrors, a checksum to verify, and how to treat the link (a file, a video page,
or a page that needs a browser).

![The add dialog](../images/macos/add_dialog_light.png)

A link already in the list is flagged; add it anyway only if you mean to.

You can also copy a link and let DLM offer it (turn on the clipboard option in Preferences), or set a
global shortcut that adds whatever link is on the clipboard.

## Where things are

- The **sidebar** lists the filters (All, Active, Queued, Paused, Completed, Failed), your queues and your
  categories. The **gear button** at its foot opens Tools, Manage and Settings.
- The **toolbar** has the title, actions for the selected downloads, search, the command palette and the
  details pane.
- Closing the window keeps DLM running in the menu bar or tray when your system has one. Quit from its
  menu. Without a tray icon, closing the window quits (and stops the service DLM started).
