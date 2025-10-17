import SwiftUI
import Combine

// MARK: - Data Models

struct GratitudeEntry: Identifiable, Codable {
    let id = UUID()
    let content: String
    let date: Date
    let mood: GratitudeMood
    let category: GratitudeCategory
    
    init(content: String, date: Date = Date(), mood: GratitudeMood = .grateful, category: GratitudeCategory = .general) {
        self.content = content
        self.date = date
        self.mood = mood
        self.category = category
    }
}

enum GratitudeMood: String, CaseIterable, Codable {
    case grateful = "Grateful"
    case blessed = "Blessed"
    case thankful = "Thankful"
    case joyful = "Joyful"
    case peaceful = "Peaceful"
    case content = "Content"
    
    var emoji: String {
        switch self {
        case .grateful: return "🙏"
        case .blessed: return "✨"
        case .thankful: return "💝"
        case .joyful: return "😊"
        case .peaceful: return "🕊️"
        case .content: return "😌"
        }
    }
    
    var color: Color {
        switch self {
        case .grateful: return .orange
        case .blessed: return .purple
        case .thankful: return .pink
        case .joyful: return .yellow
        case .peaceful: return .blue
        case .content: return .green
        }
    }
}

enum GratitudeCategory: String, CaseIterable, Codable {
    case general = "General"
    case family = "Family"
    case health = "Health"
    case work = "Work"
    case nature = "Nature"
    case experiences = "Experiences"
    case relationships = "Relationships"
    case achievements = "Achievements"
    
    var icon: String {
        switch self {
        case .general: return "heart"
        case .family: return "house"
        case .health: return "heart.fill"
        case .work: return "briefcase"
        case .nature: return "leaf"
        case .experiences: return "star"
        case .relationships: return "person.2"
        case .achievements: return "trophy"
        }
    }
}

// MARK: - Data Store

class GratitudeStore: ObservableObject {
    @Published var entries: [GratitudeEntry] = []
    private let storageKey = "gratitudeEntries"
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: GratitudeEntry) {
        entries.insert(entry, at: 0) // Add to top
        saveEntries()
    }
    
    func deleteEntry(_ entry: GratitudeEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func entriesForDate(_ date: Date) -> [GratitudeEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func entriesForMonth(_ date: Date) -> [GratitudeEntry] {
        let calendar = Calendar.current
        return entries.filter { 
            calendar.isDate($0.date, equalTo: date, toGranularity: .month)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([GratitudeEntry].self, from: data) {
            entries = decoded
        }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

// MARK: - Main Gratitude View

struct GratitudeView: View {
    @StateObject private var gratitudeStore = GratitudeStore()
    @State private var showingAddEntry = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            SerenityTheme.backgroundGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Today's Gratitude Tab
                NavigationStack {
                    TodaysGratitudeView(gratitudeStore: gratitudeStore)
                }
                .tabItem {
                    Label("Today", systemImage: "heart.fill")
                }
                .tag(0)
                
                // History Tab
                NavigationStack {
                    GratitudeHistoryView(gratitudeStore: gratitudeStore)
                }
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)
            }
            .tint(SerenityTheme.accent)
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundColor(SerenityTheme.accent)
                            .background(.ultraThinMaterial, in: Circle().inset(by: -8))
                            .shadow(radius: 8)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddGratitudeEntryView(gratitudeStore: gratitudeStore)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Today's Gratitude View

struct TodaysGratitudeView: View {
    @ObservedObject var gratitudeStore: GratitudeStore
    @State private var todaysEntries: [GratitudeEntry] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Gratitude")
                        .font(.largeTitle.bold())
                        .foregroundStyle(SerenityTheme.textPrimary)
                    
                    Text("What are you grateful for today?")
                        .font(.subheadline)
                        .foregroundStyle(SerenityTheme.textSecondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                if todaysEntries.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "heart.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(SerenityTheme.accent)
                        
                        Text("No gratitude entries yet")
                            .font(.title2.weight(.medium))
                            .foregroundStyle(SerenityTheme.textPrimary)
                        
                        Text("Take a moment to reflect on what you're grateful for today")
                            .font(.body)
                            .foregroundStyle(SerenityTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                } else {
                    // Today's Entries
                    LazyVStack(spacing: 12) {
                        ForEach(todaysEntries) { entry in
                            GratitudeEntryCard(entry: entry, gratitudeStore: gratitudeStore)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            updateTodaysEntries()
        }
        .refreshable {
            updateTodaysEntries()
        }
        .navigationBarHidden(true)
    }
    
    private func updateTodaysEntries() {
        todaysEntries = gratitudeStore.entriesForDate(Date())
    }
}

// MARK: - Gratitude Entry Card

struct GratitudeEntryCard: View {
    let entry: GratitudeEntry
    @ObservedObject var gratitudeStore: GratitudeStore
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with mood and category
            HStack {
                HStack(spacing: 6) {
                    Text(entry.mood.emoji)
                        .font(.title2)
                    Text(entry.mood.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(entry.mood.color)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: entry.category.icon)
                        .font(.caption)
                    Text(entry.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(SerenityTheme.textSecondary)
                }
            }
            
            // Content
            Text(entry.content)
                .font(.body)
                .foregroundStyle(SerenityTheme.textPrimary)
                .lineLimit(nil)
            
            // Timestamp
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundStyle(SerenityTheme.textSecondary)
        }
        .padding()
        .background(SerenityTheme.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                gratitudeStore.deleteEntry(entry)
            }
        } message: {
            Text("Are you sure you want to delete this gratitude entry?")
        }
    }
}

// MARK: - Add Gratitude Entry View

struct AddGratitudeEntryView: View {
    @ObservedObject var gratitudeStore: GratitudeStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var selectedMood: GratitudeMood = .grateful
    @State private var selectedCategory: GratitudeCategory = .general
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What are you grateful for?")
                            .font(.title2.bold())
                            .foregroundStyle(SerenityTheme.textPrimary)
                        
                        Text("Take a moment to reflect and write it down")
                            .font(.subheadline)
                            .foregroundStyle(SerenityTheme.textSecondary)
                    }
                    
                    // Text Editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your gratitude")
                            .font(.headline)
                            .foregroundStyle(SerenityTheme.textPrimary)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(SerenityTheme.cardBG)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(SerenityTheme.accent.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Mood Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How does this make you feel?")
                            .font(.headline)
                            .foregroundStyle(SerenityTheme.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(GratitudeMood.allCases, id: \.self) { mood in
                                Button {
                                    selectedMood = mood
                                } label: {
                                    VStack(spacing: 6) {
                                        Text(mood.emoji)
                                            .font(.title2)
                                        Text(mood.rawValue)
                                            .font(.caption.weight(.medium))
                                            .foregroundColor(mood.color)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedMood == mood ? 
                                        mood.color.opacity(0.2) : SerenityTheme.cardBG
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.headline)
                            .foregroundStyle(SerenityTheme.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(GratitudeCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.title3)
                                            .foregroundColor(selectedCategory == category ? SerenityTheme.accent : SerenityTheme.textSecondary)
                                        Text(category.rawValue)
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(selectedCategory == category ? SerenityTheme.textPrimary : SerenityTheme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ? 
                                        SerenityTheme.accent.opacity(0.1) : SerenityTheme.cardBG
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveEntry() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        let entry = GratitudeEntry(
            content: trimmedContent,
            mood: selectedMood,
            category: selectedCategory
        )
        
        gratitudeStore.addEntry(entry)
        dismiss()
    }
}

// MARK: - History View (Placeholder)

struct GratitudeHistoryView: View {
    @ObservedObject var gratitudeStore: GratitudeStore
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gratitudeStore.entries) { entry in
                    GratitudeEntryCard(entry: entry, gratitudeStore: gratitudeStore)
                }
            }
            .padding()
        }
        .navigationTitle("Gratitude History")
        .navigationBarTitleDisplayMode(.large)
    }
}


#Preview {
    GratitudeView()
}
