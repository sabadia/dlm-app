import Cocoa
import FlutterMacOS

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
///  - `region` {x, y, width, height} in Flutter coordinates (top-left origin)
///    or null for the whole window
public final class DlmPlatformPlugin: NSObject, FlutterPlugin {
  private static let effectIdentifier = NSUserInterfaceItemIdentifier("dlm.window.effect")

  private let registrar: FlutterPluginRegistrar
  private var effectView: NSView?
  private var region: NSRect?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "dlm/window_chrome",
      binaryMessenger: registrar.messenger
    )
    let instance = DlmPlatformPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private var glassAvailable: Bool {
    if #available(macOS 26.0, *) { return true }
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
      if requested == "glass", #available(macOS 26.0, *) {
        let glass = NSGlassEffectView()
        glass.style = .regular
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
