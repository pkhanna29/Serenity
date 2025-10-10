import SwiftUI
import Charts

// MARK: - Data Model

enum Mood: String, CaseIterable, Identifiable, Codable {
    case happy, sad, calm, angry, anxious, tired, lazy, excited, focused
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .calm: return "Calm"
        case .angry: return "Angry"
        case .anxious: return "Anxious"
        case .tired: return "Tired"
        case .lazy: return "Lazy"
        case .excited: return "Excited"
        case .focused: return "Focused"
        }
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .calm: return "😌"
        case .angry: return "😡"
        case .anxious: return "😰"
        case .tired: return "🥱"
        case .lazy: return "🛋️"
        case .excited: return "🤩"
        case .focused: return "🎯"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .sad: return .blue
        case .calm: return .teal
        case .angry: return .red
        case .anxious: return .purple
        case .tired: return .gray
        case .lazy: return .brown
        case .excited: return .orange
        case .focused: return .green
        }
    }
}

// MARK: - Mood Entry

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Mood
    let note: String?
    
    init(id: UUID = UUID(), date: Date = .now, mood: Mood, note: String? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
    }
}

// MARK: - Persistence

@MainActor
final class MoodStore: ObservableObject {
    @Published var entries: [MoodEntry] = [] { didSet { save() } }
    private let storageKey = "moodEntries.v1"
    
    init() { load() }
    
    func add(_ mood: Mood, note: String? = nil) {
        entries.append(MoodEntry(mood: mood, note: note))
    }
    
    func delete(_ offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
    
    func clearAll() { entries.removeAll() }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            entries = try JSONDecoder().decode([MoodEntry].self, from: data)
        } catch {
            print("Failed to load entries: \(error)")
        }
    }
}

// MARK: - Root View

struct EmotionHomeView: View {
    @StateObject private var store = MoodStore()
    
    var body: some View {
        TabView {
            EmotionLogView()
                .environmentObject(store)
                .tabItem { Label("Log", systemImage: "face.smiling") }
            
            TrendsView()
                .environmentObject(store)
                .tabItem { Label("Trends", systemImage: "chart.bar") }
            
            HistoryView()
                .environmentObject(store)
                .tabItem { Label("History", systemImage: "list.bullet") }
        }
    }
}

// MARK: - Log View

struct EmotionLogView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var note: String = ""
    @State private var showSavedToast = false
    
    let grid = [GridItem(.adaptive(minimum: 110), spacing: 12)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: grid, spacing: 12) {
                    ForEach(Mood.allCases) { mood in
                        MoodButton(mood: mood) {
                            store.add(mood, note: note.isEmpty ? nil : note)
                            note = ""
                            withAnimation { showSavedToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation { showSavedToast = false }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Optional note")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("Add a quick note…", text: $note)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
            }
            .overlay(alignment: .top) {
                if showSavedToast {
                    Label("Saved", systemImage: "checkmark.circle.fill")
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Emotion Tracker")
        }
    }
}

// MARK: - Mood Button

struct MoodButton: View {
    let mood: Mood
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 40))
                Text(mood.label)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 90)
            .padding()
            .background(mood.color.opacity(0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(mood.color.opacity(0.5), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Trends View

struct TrendsView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var daysBack: Int = 14
    
    var groupedByDay: [(date: Date, counts: [Mood: Int])] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date().addingTimeInterval(TimeInterval(-daysBack * 24 * 3600)))
        let filtered = store.entries.filter { $0.date >= start }
        let groups = Dictionary(grouping: filtered) { cal.startOfDay(for: $0.date) }
        let sortedDates = groups.keys.sorted()
        return sortedDates.map { day in
            let counts = Dictionary(grouping: groups[day] ?? [], by: { $0.mood }).mapValues { $0.count }
            return (date: day, counts: counts)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Last \(daysBack) days")
                        .font(.headline)
                    Spacer()
                    Stepper(value: $daysBack, in: 7...60) { EmptyView() }
                        .labelsHidden()
                }
                
                Chart {
                    ForEach(groupedByDay, id: \.date) { day in
                        let total = day.counts.values.reduce(0, +)
                        ForEach(Mood.allCases) { mood in
                            if let c = day.counts[mood], c > 0 {
                                BarMark(
                                    x: .value("Day", day.date),
                                    y: .value("Count", c)
                                )
                                .foregroundStyle(mood.color)
                                .position(by: .value("Mood", mood.label))
                            }
                        }
                        if total > 0 {
                            RuleMark(x: .value("Day", day.date))
                                .annotation(position: .top, alignment: .center) {
                                    Text("\(total)").font(.caption2)
                                }
                                .foregroundStyle(.secondary)
                                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                    }
                }
                .frame(height: 280)
                .padding(.horizontal)
                
                let distribution = Dictionary(grouping: store.entries, by: { $0.mood }).mapValues { $0.count }
                
                if !store.entries.isEmpty {
                    Text("Overall distribution")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(distribution.sorted { $0.key.label < $1.key.label }, id: \.key) { mood, count in
                        SectorMark(angle: .value("Count", count))
                            .foregroundStyle(mood.color)
                            .annotation(position: .overlay) {
                                if count > 0 {
                                    Text(mood.emoji).font(.caption)
                                }
                            }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "No data yet",
                        systemImage: "chart.bar",
                        description: Text("Log a mood to see your trends.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Trends")
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @EnvironmentObject private var store: MoodStore
    @State private var search = ""
    
    var filtered: [MoodEntry] {
        guard !search.isEmpty else {
            return store.entries.sorted { $0.date > $1.date }
        }
        return store.entries.filter {
            ($0.note ?? "").localizedCaseInsensitiveContains(search) ||
            $0.mood.label.localizedCaseInsensitiveContains(search)
        }
        .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { entry in
                    HStack(spacing: 12) {
                        Text(entry.mood.emoji).font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.mood.label).font(.headline)
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let note = entry.note, !note.isEmpty {
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: store.delete)
            }
            .searchable(text: $search)
            .toolbar { EditButton() }
            .navigationTitle("History")
        }
    }
}

// MARK: - Preview

#Preview {
    EmotionHomeView()
}
