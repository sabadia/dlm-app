import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // DLM keeps running in the background when its window is closed or hidden:
  // the app quits from the menu-bar icon (or when the user turns that off in
  // the preferences, where the Dart side quits itself).
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  // A click on the Dock icon brings a hidden window back.
  override func applicationShouldHandleReopen(
    _ sender: NSApplication, hasVisibleWindows flag: Bool
  ) -> Bool {
    if !flag {
      for window in sender.windows {
        window.makeKeyAndOrderFront(self)
      }
    }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
