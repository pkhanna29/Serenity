import SwiftUI

// MARK: - Serenity Theme (lightweight + consistent)
private enum SerenityTheme {
    static let top = Color(red: 0.75, green: 0.80, blue: 0.96)   // soft lavender-blue
    static let bottom = Color(red: 0.83, green: 0.94, blue: 0.84) // light sage-green
    static let accent = Color(red: 0.30, green: 0.45, blue: 0.70) // muted blue
    static let cardBG = Color.white.opacity(0.92)
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.80)
}

struct HomeViewPage: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient (cheap)
                LinearGradient(colors: [SerenityTheme.top, SerenityTheme.bottom],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {

                        // Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Home")
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(SerenityTheme.textPrimary)
                                Text("Your calm space")
                                    .font(.subheadline)
                                    .foregroundStyle(SerenityTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "cloud.fill")
                                .foregroundStyle(SerenityTheme.textPrimary)
                                .imageScale(.large)
                        }
                        .padding(.top, 4)

                        // Prompt + Log button
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center) {
                                Text("How are you feeling today?")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(SerenityTheme.textPrimary)
                                
                                Spacer()
                                
                                NavigationLink {
                                    EmotionHomeView()
                                }label:{
                                    Text("Log")
                                        .frame(alignment: .center)
                                        .buttonStyle(.bordered)             // compact, consistent height
                                        .controlSize(.small)                // .mini / .small / .regular
                                        .tint(SerenityTheme.accent)         // theme color
                                }
                            }
                        }
                        .padding()
                        .background(SerenityTheme.cardBG)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // Daily Journal (non-navigation card; swap to NavigationLink when you have a view)
                        HStack(spacing: 12) {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(SerenityTheme.accent)
                                .imageScale(.large)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Journal")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Write a few lines to reflect and reset.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(SerenityTheme.cardBG)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // Tools
                        Text("Your Tools")
                            .font(.headline)
                            .foregroundStyle(SerenityTheme.textPrimary)
                            .padding(.top, 6)

                        HStack(spacing: 12) {
                            NavigationLink(destination: GratitudeView()) {
                                ToolButton(title: "Gratitude", icon: "book")
                            }
                            NavigationLink(destination: AIView()) {
                                ToolButton(title: "AI Chat", icon: "message")
                            }
                            NavigationLink(destination: HabitTracker()) {
                                ToolButton(title: "Habits", icon: "checklist")
                            }
                        }

                        // Spacer for comfort
                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Tool Button (Serenity style)
struct ToolButton: View {
    var title: String
    var icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(SerenityTheme.accent)
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(SerenityTheme.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Tabs (tinted to theme)
struct ContentView: View {
    var body: some View {
        TabView {
            HomeViewPage()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            GratitudeView()
                .tabItem {
                    Image(systemName: "heart.circle")
                    Text("Gratitude")
                }

            AIView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("AI")
                }
        }
        .tint(SerenityTheme.accent) // accent across the tab bar / controls
        // Optional: a subtle background for the whole tab view
        .background(
            LinearGradient(colors: [SerenityTheme.top, SerenityTheme.bottom],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
        )
    }
}

// MARK: - Preview
#Preview {
    HomeViewPage()
}
