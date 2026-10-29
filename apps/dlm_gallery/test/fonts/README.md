# Golden test fonts

Roboto (Apache-2.0, see `Roboto_LICENSE.txt`), copied from the Flutter SDK's
material fonts so the golden images do not depend on what the CI image has
installed. The tests register these files under the font families the skins ask
for (Segoe UI Variable, Adwaita Sans, Noto Sans, the macOS system font, ...), so
every skin keeps its own type sizes and weights while the glyphs are the same
on every machine. The images show layout, colour and shape, not each platform's
typeface.
