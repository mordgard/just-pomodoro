import SwiftUI

// MARK: - Liquid Glass Support for macOS 26+
// This provides glass morphism effects for newer macOS versions

@available(macOS 26.0, *)
struct LiquidGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background {
                // Glass-like gradient overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
    }
}

@available(macOS 26.0, *)
struct LiquidGlassButtonStyle: ButtonStyle {
    var color: Color
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: isProminent ? .semibold : .medium))
            .foregroundStyle(isProminent ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if isProminent {
                    // Glass morphism for prominent buttons
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            color.opacity(configuration.isPressed ? 0.6 : 0.8)
                        )
                        .overlay {
                            // Highlight effect
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        }
                }
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@available(macOS 26.0, *)
struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        // Glass shine effect
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - View Extensions

extension View {
    @ViewBuilder
    func liquidGlassBackground() -> some View {
        if #available(macOS 26.0, *) {
            self.modifier(LiquidGlassBackground())
        } else {
            self.background(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    func liquidGlassCard() -> some View {
        if #available(macOS 26.0, *) {
            self.modifier(LiquidGlassCard())
        } else {
            self
                .padding()
                .background(.secondary.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

// MARK: - Button Style Extensions

@available(macOS 26.0, *)
extension ButtonStyle where Self == LiquidGlassButtonStyle {
    static func liquidGlass(color: Color, prominent: Bool = false) -> LiquidGlassButtonStyle {
        LiquidGlassButtonStyle(color: color, isProminent: prominent)
    }
}
