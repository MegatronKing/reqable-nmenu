import Cocoa
import FlutterMacOS

public class NativeContextMenuPlugin: NSObject, FlutterPlugin, NSMenuDelegate {
    var registrar: FlutterPluginRegistrar?
    var responded = false
    var channel: FlutterMethodChannel?;

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "native_context_menu",
            binaryMessenger: registrar.messenger
        )

        let instance = NativeContextMenuPlugin()
        instance.registrar = registrar
        instance.channel = channel

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var window: NSWindow {
        get {
            return (self.registrar?.view?.window)!;
        }
    }

    private var contentView: NSView {
        get {
            return (self.window.contentView)!;
        }
    }

    func getMenuItemId(_ menuItem: NSMenuItem) -> Int {
        let menuItemData = (menuItem.representedObject as! NSDictionary)
        let id = menuItemData["id"] as! Int;
        return id;
    }

    @objc func onItemSelected(_ sender: NSMenuItem) {
        responded = true
        let id = getMenuItemId(sender)
        channel?.invokeMethod("onItemSelected", arguments: id, result: nil)
    }

    func onItemDismissed() {
        responded = true
        channel?.invokeMethod("onMenuDismissed", arguments: nil, result: nil)
    }

    public func menuDidClose(_ menu: NSMenu) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            if menu.supermenu == nil && !self.responded {
                self.onItemDismissed()
            }
        })
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showMenu":
            responded = false
            let args = call.arguments as! NSDictionary
            let items = args["items"] as! [NSDictionary]

            let menu = createMenu(items)
            let mouseLocation = window.mouseLocationOutsideOfEventStream
            let x = mouseLocation.x
            var y = mouseLocation.y
            if !contentView.isFlipped {
                let frameHeight = Double(contentView.frame.height)
                y = frameHeight - y
            }
            menu.popUp(
                positioning: nil,
                at: NSPoint(x: x, y: y),
                in: contentView
            )
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func createMenu(_ items: [NSDictionary]) -> NSMenu {
        let menuItems = items.map { (item) -> NSMenuItem in
            if (item["isSeparator"] as! Bool) {
                return .separator()
            }
            let menuItem = NSMenuItem(
                title: item["title"] as! String,
                action: #selector(onItemSelected(_:)),
                keyEquivalent: item["keyId"] as? String ?? ""
            )
            menuItem.representedObject = item
            menuItem.isEnabled = item["isEnabled"] as! Bool
            menuItem.keyEquivalentModifierMask = []
            if (item["keyShift"] as! Bool) {
                menuItem.keyEquivalentModifierMask.insert(.shift)
            }
            if (item["keyMeta"] as! Bool) {
                menuItem.keyEquivalentModifierMask.insert(.command)
            }
            if (item["keyControl"] as! Bool) {
                menuItem.keyEquivalentModifierMask.insert(.control)
            }
            if (item["keyAlt"] as! Bool) {
                menuItem.keyEquivalentModifierMask.insert(.option)
            }
            menuItem.target = self
            return menuItem
        }

        let menu = NSMenu()

        menu.autoenablesItems = false
        menu.delegate = self

        menuItems.forEach { (item) -> Void in
            menu.addItem(item)
            if (item.isSeparatorItem) {
                return
            }
            let children = (item.representedObject as! NSDictionary)["items"] as! [NSDictionary]
            if !children.isEmpty {
                let submenu = createMenu(children)
                menu.setSubmenu(submenu, for: item)
            }
        }

        return menu
    }
}
