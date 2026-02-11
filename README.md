# Just Pomodoro

A lightweight, native macOS menu bar Pomodoro timer built with SwiftUI.

## Features

- **Menu Bar Integration**: Lives in your menu bar - no dock icon, no clutter
- **Native SwiftUI**: Modern, native macOS interface
- **Customizable Sessions**:
  - Work duration: 1-60 minutes
  - Short break: 1-15 minutes
  - Long break: 1-30 minutes
  - Configurable sessions before long break
- **Smart Timer**: Automatic session transitions with optional auto-start
- **Notifications**: Native macOS notifications and sound alerts
- **Liquid Glass Support**: Beautiful glass morphism effects on macOS 26+
- **Menu Bar Timer**: Optional countdown display in the menu bar

## Requirements

- macOS 15.0 or later
- Xcode 16.0 or later (for building)

## Building

### Option 1: Using Xcode

1. Open `Just Pomodoro/Just Pomodoro.xcodeproj` in Xcode
2. Select your Mac as the target
3. Press Cmd+R to build and run

### Option 2: Using Swift Package Manager

```bash
cd "Just Pomodoro"
swift build
```

## Project Structure

```
Just Pomodoro/
├── App/
│   ├── JustPomodoroApp.swift      # App entry point
│   └── AppDelegate.swift          # Menu bar setup
├── Models/
│   ├── TimerState.swift           # Timer states & session types
│   └── Settings.swift             # User preferences
├── ViewModels/
│   └── TimerViewModel.swift       # Business logic
├── Views/
│   ├── MenuBarView.swift          # Main popover UI
│   ├── SettingsView.swift         # Configuration panel
│   └── LiquidGlassView.swift      # macOS 26+ glass effects
├── Services/
│   ├── NotificationService.swift  # Push notifications
│   └── SoundService.swift         # Audio alerts
└── Resources/
    ├── Info.plist
    ├── JustPomodoro.entitlements
    └── Assets.xcassets/
```

## Installation

Since this app isn't signed with an Apple Developer certificate, macOS will show a security warning on first launch. Here's how to install it:

### Method 1: Right-click to Open (Recommended)
1. Download and open the DMG file
2. Drag "Just Pomodoro.app" to your Applications folder
3. **Right-click** (or Control+click) on "Just Pomodoro.app"
4. Select **"Open"** from the menu
5. Click **"Open"** in the security dialog

That's it! After this one-time approval, the app will open normally forever.

### Alternative Methods
If Method 1 doesn't work:
- **System Settings**: Go to System Settings → Privacy & Security → click "Open Anyway"
- **Terminal**: Run `xattr -cr /Applications/Just\ Pomodoro.app`

## Usage

1. Click the timer icon in your menu bar
2. Press play to start a work session
3. The timer automatically transitions between work and break sessions
4. Access settings via the gear icon to customize durations

## License

MIT License
