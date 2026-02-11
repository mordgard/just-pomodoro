import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Binding var isPresented: Bool
    @State private var settings: PomodoroSettings
    
    init(viewModel: TimerViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self._settings = State(initialValue: viewModel.settings)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .medium))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Settings")
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                Button(action: resetToDefaults) {
                    Text("Reset")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Durations Section
                    settingsSection("Timer Durations") {
                        VStack(spacing: 12) {
                            durationStepper(
                                icon: "figure.mind.and.body",
                                color: .red,
                                title: "Work",
                                value: $settings.workDuration,
                                range: PomodoroSettings.minWorkDuration...PomodoroSettings.maxWorkDuration
                            )
                            
                            Divider()
                            
                            durationStepper(
                                icon: "cup.and.saucer.fill",
                                color: .green,
                                title: "Short Break",
                                value: $settings.shortBreakDuration,
                                range: PomodoroSettings.minBreakDuration...PomodoroSettings.maxShortBreakDuration
                            )
                            
                            Divider()
                            
                            durationStepper(
                                icon: "bed.double.fill",
                                color: .blue,
                                title: "Long Break",
                                value: $settings.longBreakDuration,
                                range: PomodoroSettings.minBreakDuration...PomodoroSettings.maxLongBreakDuration
                            )
                        }
                    }
                    
                    // Sessions Section
                    settingsSection("Session Settings") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sessions before long break: \(settings.sessionsBeforeLongBreak)")
                                .font(.system(size: 13))
                            
                            Slider(
                                value: Binding(
                                    get: { Double(settings.sessionsBeforeLongBreak) },
                                    set: { settings.sessionsBeforeLongBreak = Int($0) }
                                ),
                                in: Double(PomodoroSettings.minSessionsBeforeLongBreak)...Double(PomodoroSettings.maxSessionsBeforeLongBreak),
                                step: 1
                            )
                            .controlSize(.small)
                        }
                    }
                    
                    // Automation Section
                    settingsSection("Automation") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Auto-start breaks", isOn: $settings.autoStartBreaks)
                                .font(.system(size: 13))
                                .toggleStyle(.checkbox)
                            
                            Toggle("Auto-start work sessions", isOn: $settings.autoStartWork)
                                .font(.system(size: 13))
                                .toggleStyle(.checkbox)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Display & Alerts Section
                    settingsSection("Display & Alerts") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Show timer in menu bar", isOn: $settings.showTimerInMenuBar)
                                .font(.system(size: 13))
                                .toggleStyle(.checkbox)
                            
                            Toggle("Sound alerts", isOn: $settings.soundEnabled)
                                .font(.system(size: 13))
                                .toggleStyle(.checkbox)
                            
                            Toggle("Notification alerts", isOn: $settings.notificationsEnabled)
                                .font(.system(size: 13))
                                .toggleStyle(.checkbox)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Save button
                    Button(action: saveSettings) {
                        Text("Save Changes")
                            .font(.system(size: 13, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .frame(height: 420)
    }
    
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            VStack(spacing: 0) {
                content()
            }
            .padding()
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(8)
        }
    }
    
    private func durationStepper(icon: String, color: Color, title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 13))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(value.wrappedValue <= range.lowerBound)
                
                Text("\(value.wrappedValue) min")
                    .font(.system(size: 13, design: .rounded))
                    .monospacedDigit()
                    .frame(width: 60, alignment: .center)
                
                Button(action: {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(value.wrappedValue >= range.upperBound)
            }
        }
    }
    
    private func saveSettings() {
        viewModel.updateSettings(settings)
        isPresented = false
    }
    
    private func resetToDefaults() {
        settings = .default
    }
}
