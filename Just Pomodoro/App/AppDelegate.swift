import SwiftUI
import Observation

// MARK: - App Delegate
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

// MARK: - Status Bar Controller
@MainActor
final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let viewModel: TimerViewModel
    private var menuBarUpdateTimer: Timer?
    
    init() {
        // Use variable length for compact display
        // Arrow will be dynamically positioned based on current content
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.viewModel = TimerViewModel()
        
        setupStatusBar()
        setupPopover()
        startMenuBarUpdates()
    }
    
    // Note: StatusBarController lives for app lifetime
    // Timer cleanup happens automatically on app termination
}

// MARK: - Private Methods
private extension StatusBarController {
    func setupStatusBar() {
        guard let button = statusItem.button else { return }
        
        button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro Timer")
        button.action = #selector(togglePopover)
        button.target = self
    }
    
    func startMenuBarUpdates() {
        // Update menu bar every second to reflect timer changes
        menuBarUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateMenuBarTitle()
                self.updateMenuBarIcon()
            }
        }
    }
    
    func updateMenuBarTitle() {
        guard let button = statusItem.button else { return }
        
        if viewModel.settings.showTimerInMenuBar && viewModel.timerState == .running {
            button.title = " \(viewModel.timeString)"
        } else {
            button.title = ""
        }
    }
    
    func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }
        
        let symbolName: String
        switch viewModel.timerState {
        case .idle:
            symbolName = "timer"
        case .running:
            switch viewModel.currentSessionType {
            case .work:
                symbolName = "figure.mind.and.body"
            case .shortBreak:
                symbolName = "cup.and.saucer.fill"
            case .longBreak:
                symbolName = "bed.double.fill"
            }
        case .paused:
            symbolName = "pause.circle.fill"
        }
        
        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Pomodoro Timer")
    }
    
    func setupPopover() {
        popover.contentSize = NSSize(width: 300, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView(viewModel: viewModel))
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
            viewModel.isPopoverVisible = false
        } else {
            // Calculate center of the button for arrow positioning
            // Create a small rect at the center so arrow points to middle
            let buttonWidth = button.bounds.width
            let centerX = buttonWidth / 2
            let arrowWidth: CGFloat = 1 // Very small width to force centering
            let centerRect = NSRect(
                x: centerX - (arrowWidth / 2),
                y: 0,
                width: arrowWidth,
                height: button.bounds.height
            )
            
            popover.show(relativeTo: centerRect, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
            viewModel.isPopoverVisible = true
        }
    }
}
