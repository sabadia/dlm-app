# Icons (F2.9)

Features name an icon semantically (`DlmIconName.download`, `.pause`, `.settings`, ...) and the
active skin draws it; they never reference a glyph file or a platform icon font.

## Set

About 55 glyphs on a 16 x 16 grid: navigation (chevrons, sidebar, inspector, menu), actions
(add, close, check, edit, copy, link, search, filter, sort, refresh, restart, import, export,
external link, view options, group, columns, cards), transfer (download, upload, play, pause, stop, queue, schedule, speed, chart),
objects (file, folder, tag, plugin, globe, key, lock, bell, trash, settings), and status
(info, warning, error, success, eye).

## App icon and brand mark

The DLM mark (a download arrow inside an open progress ring on an indigo-to-blue rounded square)
is drawn by `DlmBrandMarkPainter` in the kit, so the About page and the icon files come from one
source. `apps/dlm_app/tool/gen_icons.sh` renders it at 1024 px and writes every size: the
`assets/icon/dlm_*.png` set, the macOS `AppIcon.appiconset`, the Windows `app_icon.ico` and the
monochrome `tray_template.png` the macOS menu bar uses. Run it on macOS after changing the painter.

## Per-skin weight

`DlmBaseComponents.iconStrokeWidth` is the line weight of a skin's glyphs (1.5 default; Fluent and
Breeze 1.25, Adwaita 1.75). A skin may also override `DlmComponents.icon` to draw a different
glyph set entirely.

## Licence audit

Every glyph is drawn in this repository with `CustomPainter` paths (`icon_painter.dart`). No
third-party artwork, icon font or generated asset is bundled, so there is no icon licence to
attribute. The test suite checks that each glyph draws inside its box, that no two glyphs are the
same picture except the documented aliases (the sort arrows reuse the chevrons), and that stroke
weight changes the render.

System icon themes (KDE's Breeze icons, GNOME's symbolic set) are *not* used: they are not
guaranteed to be installed or sandbox-readable (Flatpak), and the app must look the same on every
machine of a platform. Revisit if the visual review asks for them.

## App icon

The product name and logo are not decided, so the app ships a generated placeholder: a download
arrow in a rounded blue square. The PNG masters (16 to 1024 px) are in `apps/dlm_app/assets/icon`;
the macOS `AppIcon.appiconset` and the Windows `app_icon.ico` (PNG entries at 16, 32, 48 and 256)
were built from them. When the brand assets arrive they replace these files; nothing else refers
to the artwork.
