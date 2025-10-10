import SwiftUI
import UIKit // for UIImage(named:)

private enum SerenityTheme {
    static let top = Color(red: 0.75, green: 0.80, blue: 0.96)
    static let bottom = Color(red: 0.83, green: 0.94, blue: 0.84)
    static let accent = Color(red: 0.30, green: 0.45, blue: 0.70)
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.80)
}

struct HomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    @State private var didAppear = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var pulse = false   // drives the CTA ring

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [SerenityTheme.top, SerenityTheme.bottom],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Logo + Title
                    VStack(spacing: 10) {
                        if UIImage(named: "SerenityLogo") != nil {
                            Image("SerenityLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .accessibilityLabel("Serenity Logo")
                                .scaleEffect(didAppear && !reduceMotion ? 1.0 : 0.94)
                                .opacity(didAppear ? 1 : 0)
                                .animation(reduceMotion ? nil :
                                           .interpolatingSpring(stiffness: 180, damping: 20).delay(0.0),
                                           value: didAppear)
                        } else {
                            Image(systemName: "waveform.path.ecg")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                                .foregroundStyle(.white)
                                .accessibilityHidden(true)
                                .scaleEffect(didAppear && !reduceMotion ? 1.0 : 0.94)
                                .opacity(didAppear ? 1 : 0)
                                .animation(reduceMotion ? nil :
                                           .interpolatingSpring(stiffness: 180, damping: 20).delay(0.0),
                                           value: didAppear)
                        }

                        Text("SERENITY")
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundStyle(SerenityTheme.textPrimary)
                            .opacity(showTitle ? 1 : 0)
                            .offset(y: showTitle || reduceMotion ? 0 : 6)
                            .animation(reduceMotion ? nil :
                                       .easeOut(duration: 0.35).delay(0.10),
                                       value: showTitle)
                    }

                    // Tagline
                    VStack(spacing: 6) {
                        Text("Welcome to Serenity")
                            .font(.headline)
                            .foregroundStyle(SerenityTheme.textPrimary)

                        Text("Your space for mindfulness, emotional balance, and growth.")
                            .font(.subheadline)
                            .foregroundStyle(SerenityTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                    }
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline || reduceMotion ? 0 : 8)
                    .animation(reduceMotion ? nil :
                               .easeOut(duration: 0.35).delay(0.22),
                               value: showTagline)

                    // CTA with tighter pulse ring (inside bounds)
                    NavigationLink {
                        HomeViewPage()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.white.opacity(0.92))
                            .foregroundStyle(SerenityTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                // Ring stays within button via inset; tiny scale range
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .inset(by: 2)
                                    .stroke(SerenityTheme.accent.opacity(0.28), lineWidth: 2)
                                    .scaleEffect(pulse ? 1.015 : 1.0, anchor: .center) // ~1.5% only
                                    .opacity(pulse ? 0.0 : 1.0)
                                    .animation(reduceMotion ? nil :
                                               .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                               value: pulse)
                            )
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 6)
                    .task {
                        // Start pulse when view appears if motion allowed
                        guard !reduceMotion else { return }
                        pulse = false
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }

                    // Disclaimer
                    VStack(spacing: 4) {
                        Text("This app is not a substitute for medical care.")
                            .font(.caption)
                            .foregroundStyle(SerenityTheme.textSecondary)
                        Text("If you are in crisis, call 911 or 988.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SerenityTheme.textPrimary)
                    }
                    .padding(.top, 8)
                    .opacity(didAppear ? 1 : 0)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                // staged intro, respecting Reduce Motion
                didAppear = true
                if !reduceMotion {
                    showTitle = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { showTagline = true }
                } else {
                    showTitle = true; showTagline = true
                }
            }
            // NEW: use task(id:) instead of deprecated onChange
            .task(id: scenePhase) {
                guard !reduceMotion else { return }
                if scenePhase == .active {
                    // restart the pulse loop when returning to foreground
                    pulse = false
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                } else {
                    // stop pulse to save cycles
                    pulse = false
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
