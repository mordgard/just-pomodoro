import SwiftUI
import Combine

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
final class StatusBarController: ObservableObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let viewModel: TimerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.viewModel = TimerViewModel()
        
        setupStatusBar()
        setupPopover()
    }
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Private Methods
private extension StatusBarController {
    func setupStatusBar() {
        guard let button = statusItem.button else { return }
        
        button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro Timer")
        button.action = #selector(togglePopover)
        button.target = self
        
        // Subscribe to timeString changes
        viewModel.$timeString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarTitle()
            }
            .store(in: &cancellables)
        
        // Subscribe to timerState changes
        viewModel.$timerState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarIcon()
            }
            .store(in: &cancellables)
        
        // Subscribe to settings changes
        viewModel.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarTitle()
            }
            .store(in: &cancellables)
    }
    
    func updateMenuBarTitle() {
        guard let button = statusItem.button else { return }
        
        // Only show timer if setting is enabled AND timer is running
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
        popover.contentViewController = NSHostingController(rootView: MenuBarView(viewModel: self.viewModel))
    }
    
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
