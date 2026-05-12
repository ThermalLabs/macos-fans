import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Show in both menu bar and Dock
        NSApp.setActivationPolicy(.regular)
        menuBarController = MenuBarController()
    }

    // Keep running when all windows are closed — this is a menu bar app
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
