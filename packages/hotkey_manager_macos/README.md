# hotkey_manager_macos (DLM build)

The macOS implementation of [hotkey_manager](https://pub.dev/packages/hotkey_manager) 0.2.x,
rewritten as a Swift Package Manager plugin that calls Carbon's `RegisterEventHotKey` directly.
The published `hotkey_manager_macos` 0.2.0 is CocoaPods-only (it needs the `HotKey` pod), and
Flutter warns that plugins without SwiftPM support will stop building.

It keeps the same method and event channels (`dev.leanflutter.plugins/hotkey_manager` and
`..._event`), so the Dart side is unchanged. This workspace member replaces the hosted package by
name. Licence: MIT, from the original (see `LICENSE`).
