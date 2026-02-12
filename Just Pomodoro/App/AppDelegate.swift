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
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.viewModel = TimerViewModel()
        
        setupStatusBar()
        setupPopover()
        startMenuBarUpdates()
    }
    
    nonisolated deinit {
        // Timer will be invalidated automatically when the run loop is torn down
        // No need to manually invalidate in deinit for UI timers
    }
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
            Task { @MainActor [weak self] in
                self?.updateMenuBarTitle()
                self?.updateMenuBarIcon()
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
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView(viewModel: viewModel))
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
            viewModel.isPopoverVisible = false
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
            viewModel.isPopoverVisible = true
        }
    }
}
