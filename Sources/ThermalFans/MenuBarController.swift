import AppKit

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let smcReader = SMCReader()

    // Refresh fan/temp data every 5 seconds
    // nonisolated(unsafe): deinit is nonisolated in Swift 6 but this class only lives on MainActor
    nonisolated(unsafe) private var refreshTimer: Timer?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureButton()
        rebuildMenu()
        startRefreshing()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Setup

    private func configureButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "fan", accessibilityDescription: "ThermalFans")
        button.imagePosition = .imageLeft
        button.title = " —"
    }

    // MARK: - Menu

    private func rebuildMenu() {
        let menu = NSMenu()

        let fans = smcReader.readFans()
        let temps = smcReader.readTemperatures()

        // Fan readings
        addSectionHeader("Fans", to: menu)
        if fans.isEmpty {
            menu.addItem(disabled("No fan data"))
        } else {
            for fan in fans {
                menu.addItem(disabled("Fan \(fan.index): \(fan.actualRPM) RPM"))
            }
        }

        menu.addItem(.separator())

        // Temperature readings
        addSectionHeader("Temperatures", to: menu)
        if let temps {
            menu.addItem(disabled(String(format: "CPU:  %.0f °C", temps.cpuProximityTemp)))
        } else {
            menu.addItem(disabled("No temp data"))
        }

        menu.addItem(.separator())

        // Actions
        let prefs = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefs.target = self
        menu.addItem(prefs)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit ThermalFans", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        updateStatusLabel(fans: fans)
    }

    private func addSectionHeader(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        // Render as a small grey header
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: NSColor.secondaryLabelColor,
        ]
        item.attributedTitle = NSAttributedString(string: title.uppercased(), attributes: attrs)
        menu.addItem(item)
    }

    private func disabled(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func updateStatusLabel(fans: [FanReading]) {
        guard let button = statusItem.button else { return }
        if let first = fans.first {
            button.title = " \(first.actualRPM)"
        } else {
            button.title = " —"
        }
    }

    // MARK: - Refresh

    private func startRefreshing() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.rebuildMenu()
            }
        }
    }

    // MARK: - Actions

    @objc private func openPreferences() {
        // TODO: open preferences window
        NSApp.activate(ignoringOtherApps: true)
    }
}
