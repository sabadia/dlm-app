import Cocoa
import FlutterMacOS
import ServiceManagement

/// Window chrome for the macOS skin: a transparent title bar and a backdrop
/// effect (NSGlassEffectView on macOS 26+, NSVisualEffectView before) behind a
/// region of the Flutter view. Flutter draws the tint and the content; this
/// code only provides what Flutter cannot: the blurred window backdrop.
///
/// Channel `dlm/window_chrome`:
///  - `capabilities` -> {vibrancy: bool, glass: bool}
///  - `apply` {transparentTitleBar: bool, effect: "none"|"vibrancy"|"glass",
///    brightness: "light"|"dark"|null} -> {transparentTitleBar, effect}: what
///    was actually applied
///  - `dlm/system_appearance`: `read` -> {accent: ARGB int?, highContrast,
///    reduceMotion, reduceTransparency}; pushes `changed` with the same map
///  - `region` {x, y, width, height} in Flutter coordinates (top-left origin)
///    or null for the whole window
public final class DlmPlatformPlugin: NSObject, FlutterPlugin {
  private static let effectIdentifier = NSUserInterfaceItemIdentifier("dlm.window.effect")

  private let registrar: FlutterPluginRegistrar
  private let appearanceChannel: FlutterMethodChannel
  private var effectView: NSView?
  private var region: NSRect?

  init(registrar: FlutterPluginRegistrar, appearanceChannel: FlutterMethodChannel) {
    self.registrar = registrar
    self.appearanceChannel = appearanceChannel
    super.init()
    observeAppearance()
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    NotificationCenter.default.removeObserver(self)
    DistributedNotificationCenter.default().removeObserver(self)
  }

  // MARK: System appearance

  /// Accent colour and the accessibility display options, which Flutter does
  /// not report. Sent on `dlm/system_appearance` `read` and pushed as
  /// `changed` whenever the system changes them.
  private func systemAppearance() -> [String: Any] {
    var accent: Int? = nil
    if let c = NSColor.controlAccentColor.usingColorSpace(.sRGB) {
      let a = Int((c.alphaComponent * 255).rounded())
      let r = Int((c.redComponent * 255).rounded())
      let g = Int((c.greenComponent * 255).rounded())
      let b = Int((c.blueComponent * 255).rounded())
      accent = (a << 24) | (r << 16) | (g << 8) | b
    }
    let workspace = NSWorkspace.shared
    return [
      "accent": accent as Any,
      "highContrast": workspace.accessibilityDisplayShouldIncreaseContrast,
      "reduceMotion": workspace.accessibilityDisplayShouldReduceMotion,
      "reduceTransparency": workspace.accessibilityDisplayShouldReduceTransparency,
    ]
  }

  private func observeAppearance() {
    let push: (Notification) -> Void = { [weak self] _ in
      guard let self = self else { return }
      self.appearanceChannel.invokeMethod("changed", arguments: self.systemAppearance())
    }
    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
      object: nil, queue: .main, using: push)
    NotificationCenter.default.addObserver(
      forName: NSColor.systemColorsDidChangeNotification,
      object: nil, queue: .main, using: push)
    DistributedNotificationCenter.default().addObserver(
      forName: NSNotification.Name("AppleColorPreferencesChangedNotification"),
      object: nil, queue: .main, using: push)
  }

  /// Whether the launch event says the system started the app as a login item.
  /// Only the event of the launch itself says so, so it is read once at
  /// registration, which happens during launch.
  private static let launchedAsLoginItem: Bool = {
    guard let event = NSAppleEventDescriptor.currentAppleEvent,
      event.eventID == AEEventID(kAEOpenApplication),
      let prop = event.paramDescriptor(forKeyword: AEKeyword(keyAEPropData))
    else { return false }
    return prop.enumCodeValue == OSType(keyAELaunchedAsLogInItem)
  }()

  /// Channel `dlm/login_item`: `isEnabled` -> bool, `setEnabled` {enabled: bool},
  /// `startedAtLogin` -> bool, over `SMAppService.mainApp`.
  private static func handleLoginItem(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let service = SMAppService.mainApp
    switch call.method {
    case "isEnabled":
      result(service.status == .enabled)
    case "setEnabled":
      let enabled = (call.arguments as? [String: Any])?["enabled"] as? Bool ?? false
      do {
        if enabled {
          try service.register()
        } else {
          try service.unregister()
        }
        result(nil)
      } catch {
        result(
          FlutterError(code: "login-item", message: error.localizedDescription, details: nil))
      }
    case "startedAtLogin":
      result(launchedAsLoginItem)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = launchedAsLoginItem
    FlutterMethodChannel(name: "dlm/login_item", binaryMessenger: registrar.messenger)
      .setMethodCallHandler(handleLoginItem)
    let channel = FlutterMethodChannel(
      name: "dlm/window_chrome",
      binaryMessenger: registrar.messenger
    )
    let appearance = FlutterMethodChannel(
      name: "dlm/system_appearance",
      binaryMessenger: registrar.messenger
    )
    let instance = DlmPlatformPlugin(registrar: registrar, appearanceChannel: appearance)
    registrar.addMethodCallDelegate(instance, channel: channel)
    appearance.setMethodCallHandler { call, result in
      if call.method == "read" {
        result(instance.systemAppearance())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // NSGlassEffectView exists in the macOS 26 SDK (Swift 6.2 toolchains and
  // newer); older SDKs compile without it and always use vibrancy.
  private var glassAvailable: Bool {
    #if compiler(>=6.2)
      if #available(macOS 26.0, *) { return true }
    #endif
    return false
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "capabilities":
      result(["vibrancy": true, "glass": glassAvailable])
    case "apply":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad-arguments", message: "apply needs a map", details: nil))
        return
      }
      apply(args, result: result)
    case "region":
      if let args = call.arguments as? [String: Any],
        let x = args["x"] as? Double, let y = args["y"] as? Double,
        let w = args["width"] as? Double, let h = args["height"] as? Double
      {
        region = NSRect(x: x, y: y, width: w, height: h)
      } else {
        region = nil
      }
      layoutEffect()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func apply(_ args: [String: Any], result: FlutterResult) {
    guard let controller = registrar.viewController as? FlutterViewController,
      let window = controller.view.window
    else {
      result(FlutterError(code: "no-window", message: "The window is not ready yet", details: nil))
      return
    }
    let transparentTitleBar = args["transparentTitleBar"] as? Bool ?? false
    let requested = args["effect"] as? String ?? "none"

    window.titlebarAppearsTransparent = transparentTitleBar
    window.titleVisibility = transparentTitleBar ? .hidden : .visible
    if transparentTitleBar {
      window.styleMask.insert(.fullSizeContentView)
    } else {
      window.styleMask.remove(.fullSizeContentView)
    }

    switch args["brightness"] as? String {
    case "dark": window.appearance = NSAppearance(named: .darkAqua)
    case "light": window.appearance = NSAppearance(named: .aqua)
    default: window.appearance = nil
    }

    effectView?.removeFromSuperview()
    effectView = nil
    var applied = "none"
    if requested != "none" {
      let view: NSView
      if requested == "glass", glassAvailable, let glass = makeGlassView() {
        view = glass
        applied = "glass"
      } else {
        let visual = NSVisualEffectView()
        visual.material = .sidebar
        visual.blendingMode = .behindWindow
        visual.state = .active
        view = visual
        applied = "vibrancy"
      }
      view.identifier = Self.effectIdentifier
      // The Flutter view is the window's content view; the effect goes below
      // everything Flutter draws.
      controller.view.addSubview(view, positioned: .below, relativeTo: nil)
      effectView = view
      layoutEffect()
      window.isOpaque = false
      window.backgroundColor = .clear
      controller.backgroundColor = .clear
    } else {
      window.isOpaque = true
      window.backgroundColor = .windowBackgroundColor
      controller.backgroundColor = .windowBackgroundColor
    }
    result(["transparentTitleBar": transparentTitleBar, "effect": applied])
  }

  private func makeGlassView() -> NSView? {
    #if compiler(>=6.2)
      if #available(macOS 26.0, *) {
        let glass = NSGlassEffectView()
        glass.style = .regular
        return glass
      }
    #endif
    return nil
  }

  private func layoutEffect() {
    guard let view = effectView, let host = registrar.viewController?.view else { return }
    guard let region = region else {
      view.frame = host.bounds
      view.autoresizingMask = [.width, .height]
      return
    }
    // Flutter's origin is top-left, AppKit's bottom-left.
    view.autoresizingMask = [.maxXMargin, .minYMargin]
    view.frame = NSRect(
      x: region.origin.x,
      y: host.bounds.height - region.origin.y - region.height,
      width: region.width,
      height: region.height
    )
  }
}
