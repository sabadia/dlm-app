# Manual test checklist

Tests cannot click a tray icon, show a real notification or sign in again, so these are tried by
hand on each system before a beta. Tick a box only when you saw it happen. Write what you saw
next to anything that is off (screenshots of the DLM window only, not the whole screen).

How to start: install a build, open DLM, let it start its own download service. Have one slow
download (a large file) and one small one ready.

## macOS (run by the maintainer after M5b)

- [ ] **Name and icon**: the menu bar says DLM, the Dock icon is the new mark, About shows it.
- [ ] **Look**: no scrollbars anywhere; downloads are cards; inputs have no resting outline and
      glow when focused; a selected card and a selected sidebar item are tinted with an accent edge.
- [ ] **Accent and theme**: change the accent in System Settings and the app follows; switch
      light/dark and the app follows.
- [ ] **Gear menu**: the gear at the foot of the sidebar opens Tools / Manage / Settings; each opens
      a large window with its own list; changing a setting and switching page asks about unsaved
      edits; Escape and the close button close it.
- [ ] **Tray**: the menu bar icon shows (monochrome); its menu has Show, Add downloads, Pause all,
      Resume all, Quit; the speed shows next to it while downloading.
- [ ] **Close to tray**: closing the window keeps the app running; Show brings it back; Quit ends it.
- [ ] **Notifications**: a finished download shows a notification with Open and Show in folder; a
      failed one shows Retry; each button does what it says.
- [ ] **Start at login**: turn it on in Preferences; log out and in; DLM starts. With Start hidden
      on, the window stays closed and the tray icon is there.
- [ ] **Dock progress**: the Dock icon shows progress and a badge with the active count.
- [ ] **Sleep**: while a download runs the Mac does not sleep (`pmset -g assertions` lists DLM).
- [ ] **Drop**: drag a `.torrent` file and a `.txt` with links onto the window; the add dialog opens
      with them.
- [ ] **Clipboard**: copy a link; with the clipboard watcher on, DLM offers it once.
- [ ] **Open with**: open a `.torrent` and a `magnet:` link from outside; a second launch hands
      over to the running window.
- [ ] **Global hotkeys**: set Show or hide DLM to Ctrl+Shift+D in Preferences; it works from another
      app; Clear removes it.
- [ ] **Menus**: the application menu has About and Quit; File and Window items behave.
- [ ] **Window restore**: move and resize, quit, start; the window comes back in the same place.

## Windows 10 and 11 (a tester, before beta)

- [ ] Name DLM in the title bar, taskbar and Task Manager; the icon is the new mark.
- [ ] Look, scrollbars, cards, inputs and the gear window as in the macOS list.
- [ ] Mica or Acrylic backdrop and the system accent; light and dark follow the system.
- [ ] Tray icon in the notification area with the menu; closing the window keeps the app running.
- [ ] Notifications with Open, Show in folder, Retry (unpackaged builds cannot clear a shown toast;
      note it).
- [ ] Start at login adds a `dlm` value under `HKCU\...\Run`; it starts with the window hidden when
      Start hidden is on; turning it off removes the value.
- [ ] Taskbar progress; sleep prevention while downloading (`powercfg /requests`).
- [ ] Drop files; clipboard offer; `magnet:` handler (after the installer registers it).
- [ ] Global hotkey works from another program.
- [ ] Window restore across two monitors, including after unplugging one.

## Linux GNOME and KDE (a tester, before beta)

- [ ] Name DLM in the title bar and app switcher; the icon is the new mark.
- [ ] Look, scrollbars, cards, inputs and the gear window as in the macOS list.
- [ ] System accent and dark mode (GNOME portal, KDE `kdeglobals`).
- [ ] **GNOME without the AppIndicator extension**: no tray, so closing the window quits; with the
      extension, the tray icon and menu work.
- [ ] KDE: tray icon and menu work.
- [ ] Notifications with buttons (depends on the notification server; note which one).
- [ ] Start at login writes `~/.config/autostart/io.github.sabadia.dlm.desktop` and the app starts;
      turning it off removes it.
- [ ] Sleep prevention while downloading (`systemd-inhibit --list`).
- [ ] Drop files; clipboard offer; X11: a global hotkey works; **Wayland**: Preferences explains
      why global shortcuts are missing.
- [ ] Window restore on Wayland and X11.

## Screen readers (a tester on each system)

Turn the reader on (VoiceOver on macOS, Narrator or NVDA on Windows, Orca on Linux) and use only the
keyboard.

- [ ] The sidebar is read as a list with the selected item announced; the counts are read.
- [ ] A download card is read with its name and status; Space and Enter select and act; the
      progress is announced as a value.
- [ ] The toolbar buttons are announced by name (Add downloads, Pause, Resume, Delete, Display,
      View, Search, Command palette, Details).
- [ ] The add dialog: the links field, each option and the Add button are announced; an error is
      announced when it appears.
- [ ] The settings window: the gear menu, the page list and every field are announced with their
      label and description; a saved change or an error is announced.
- [ ] Notifications and toasts are announced when they appear.
- [ ] Nothing important is only a colour: failed downloads say Failed, not just red.
- [ ] Text 200 % (system setting) and high contrast: every screen is still usable.

## Both daemons

- [ ] A remote daemon profile hides the login item for the daemon and the extension row.
- [ ] Kill the daemon process while the app runs; the app shows the recovery state and recovers.
