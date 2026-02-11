import SwiftUI

struct MenuBarView: View {
    @StateObject var viewModel: TimerViewModel
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsView(viewModel: viewModel, isPresented: $showingSettings)
            } else {
                TimerContentView(viewModel: viewModel, showingSettings: $showingSettings)
            }
        }
        .frame(width: 300)
    }
}

struct TimerContentView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Timer Display - Large and clear
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.currentSessionType.icon)
                        .foregroundStyle(sessionColor)
                    Text(viewModel.currentSessionType.rawValue)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(.secondary)
                
                Text(viewModel.timeString)
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                
                if viewModel.timerState == .paused {
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
            
            Divider()
            
            // Progress bar - native style
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.sessionProgressText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .tint(sessionColor)
            }
            
            // Control buttons - native macOS style
            HStack(spacing: 12) {
                // Reset/Skip
                Button(action: {
                    if viewModel.timerState == .running {
                        viewModel.skipSession()
                    } else {
                        viewModel.resetTimer()
                    }
                }) {
                    Image(systemName: viewModel.timerState == .running ? "forward.fill" : "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                // Play/Pause
                Button(action: {
                    if viewModel.timerState == .running {
                        viewModel.pauseTimer()
                    } else {
                        viewModel.startTimer()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.timerState == .running ? "pause.fill" : "play.fill")
                        Text(viewModel.timerState == .running ? "Pause" : "Start")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(sessionColor)
            }
            
            Divider()
            
            // Daily Stats
            VStack(alignment: .leading, spacing: 6) {
                Text("Today")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Work")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        Text(viewModel.dailyStats.formattedWorkTime)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    }
                    
                    Divider()
                        .frame(height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Breaks")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        Text(viewModel.dailyStats.formattedBreakTime)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    }
                    
                    Divider()
                        .frame(height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        Text(viewModel.dailyStats.formattedTotalTime)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Bottom actions - Settings and Quit
            HStack {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: quitApp) {
                    Text("Quit")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private var sessionColor: Color {
        switch viewModel.currentSessionType {
        case .work:
            return .red
        case .shortBreak:
            return .green
        case .longBreak:
            return .blue
        }
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
