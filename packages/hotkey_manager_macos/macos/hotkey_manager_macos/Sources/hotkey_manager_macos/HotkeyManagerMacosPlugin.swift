import Carbon
import Cocoa
import FlutterMacOS

/// Global hotkeys through Carbon's `RegisterEventHotKey`, speaking the channels
/// of hotkey_manager 0.2.x: `register` {identifier, keyCode, modifiers},
/// `unregister` {identifier}, `unregisterAll`, and `onKeyDown` / `onKeyUp`
/// events carrying the arguments of the registration.
public class HotkeyManagerMacosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  private struct Entry {
    let ref: EventHotKeyRef
    let arguments: NSDictionary
  }

  private var entries: [String: Entry] = [:]
  private var identifiers: [UInt32: String] = [:]
  private var nextId: UInt32 = 1
  private var handler: EventHandlerRef?

  /// `DLMH`, to tell our hotkeys from other code's in the same process.
  private static let signature: OSType = 0x444C_4D48

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "dev.leanflutter.plugins/hotkey_manager", binaryMessenger: registrar.messenger)
    let instance = HotkeyManagerMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    let events = FlutterEventChannel(
      name: "dev.leanflutter.plugins/hotkey_manager_event", binaryMessenger: registrar.messenger)
    events.setStreamHandler(instance)
  }

  public func onListen(
    withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register": register(call, result: result)
    case "unregister": unregister(call, result: result)
    case "unregisterAll":
      for (_, entry) in entries { UnregisterEventHotKey(entry.ref) }
      entries.removeAll()
      identifiers.removeAll()
      result(true)
    default: result(FlutterMethodNotImplemented)
    }
  }

  private func installHandler() -> Bool {
    if handler != nil { return true }
    var specs = [
      EventTypeSpec(
        eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)),
      EventTypeSpec(
        eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased)),
    ]
    let status = InstallEventHandler(
      GetApplicationEventTarget(),
      { _, event, userData in
        guard let event = event, let userData = userData else {
          return OSStatus(eventNotHandledErr)
        }
        var id = EventHotKeyID()
        let got = GetEventParameter(
          event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
          nil, MemoryLayout<EventHotKeyID>.size, nil, &id)
        if got != noErr { return got }
        let plugin = Unmanaged<HotkeyManagerMacosPlugin>.fromOpaque(userData)
          .takeUnretainedValue()
        plugin.fire(id: id.id, down: GetEventKind(event) == UInt32(kEventHotKeyPressed))
        return noErr
      },
      specs.count, &specs, Unmanaged.passUnretained(self).toOpaque(), &handler)
    return status == noErr
  }

  private func fire(id: UInt32, down: Bool) {
    guard let identifier = identifiers[id], let entry = entries[identifier],
      let sink = eventSink
    else { return }
    sink(["type": down ? "onKeyDown" : "onKeyUp", "data": entry.arguments] as NSDictionary)
  }

  private func carbonModifiers(_ names: [String]) -> UInt32 {
    var mods: UInt32 = 0
    if names.contains("alt") { mods |= UInt32(optionKey) }
    if names.contains("control") { mods |= UInt32(controlKey) }
    if names.contains("meta") { mods |= UInt32(cmdKey) }
    if names.contains("shift") { mods |= UInt32(shiftKey) }
    return mods
  }

  private func register(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? NSDictionary,
      let identifier = args["identifier"] as? String,
      let keyCode = args["keyCode"] as? NSNumber
    else {
      result(FlutterError(code: "bad-arguments", message: "register needs a hotkey", details: nil))
      return
    }
    let modifiers = args["modifiers"] as? [String] ?? []
    guard installHandler() else {
      result(FlutterError(code: "no-handler", message: "Cannot listen for hotkeys", details: nil))
      return
    }
    if let old = entries[identifier] {
      UnregisterEventHotKey(old.ref)
      entries[identifier] = nil
    }
    let id = nextId
    nextId += 1
    var ref: EventHotKeyRef?
    let status = RegisterEventHotKey(
      keyCode.uint32Value, carbonModifiers(modifiers),
      EventHotKeyID(signature: HotkeyManagerMacosPlugin.signature, id: id),
      GetApplicationEventTarget(), 0, &ref)
    guard status == noErr, let ref = ref else {
      result(
        FlutterError(
          code: "register-failed", message: "The system refused the hotkey (\(status))",
          details: nil))
      return
    }
    entries[identifier] = Entry(ref: ref, arguments: args)
    identifiers[id] = identifier
    result(true)
  }

  private func unregister(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let args = call.arguments as? NSDictionary, let identifier = args["identifier"] as? String,
      let entry = entries[identifier]
    {
      UnregisterEventHotKey(entry.ref)
      entries[identifier] = nil
      identifiers = identifiers.filter { $0.value != identifier }
    }
    result(true)
  }
}
