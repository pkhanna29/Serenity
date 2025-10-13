//
//  HabitTracker.swift
//  Help2
//
//  Created by Pranav Khanna on 6/23/25.
//

import SwiftUI
// MARK: - Model

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var color: HabitColor = .blue
    var activeDays: Set<Int> = [2,3,4,5,6] // default: Mon-Fri (1=Sun)
    var completedDays: Set<String> = []
    
    mutating func toggle(on date: Date, calendar: Calendar = .current) {
        let key = dateKey(date, calendar: calendar)
        if completedDays.contains(key) {
            completedDays.remove(key)
        } else {
            completedDays.insert(key)
        }
    }
    
    func isDone(on date: Date, calendar: Calendar = .current) -> Bool {
        completedDays.contains(dateKey(date, calendar: calendar))
    }
    
    func isScheduled(for date: Date, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return activeDays.contains(weekday)
    }
}

enum HabitColor: String, CaseIterable, Codable, Identifiable {
    case blue, green, orange, pink, purple, teal, red
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .teal: return .teal
        case .red: return .red
        }
    }
}

// MARK: - Persistence

private let habitsKey = "habits.v3"

extension Array where Element == Habit {
    func encoded() -> Data { (try? JSONEncoder().encode(self)) ?? Data() }
    static func decoded(from data: Data) -> [Habit] {
        (try? JSONDecoder().decode([Habit].self, from: data)) ?? []
    }
}

private func dateKey(_ date: Date, calendar: Calendar = .current) -> String {
    let comps = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
}

// MARK: - Add/Edit Sheet

struct EditHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var color: HabitColor
    @State private var activeDays: Set<Int>
    let onSave: (String, HabitColor, Set<Int>) -> Void
    
    init(habit: Habit? = nil, onSave: @escaping (String, HabitColor, Set<Int>) -> Void) {
        _name = State(initialValue: habit?.name ?? "")
        _color = State(initialValue: habit?.color ?? .blue)
        _activeDays = State(initialValue: habit?.activeDays ?? [2,3,4,5,6])
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Habit name", text: $name)
                    Picker("Color", selection: $color) {
                        ForEach(HabitColor.allCases) { c in
                            HStack {
                                Circle().fill(c.color).frame(width: 16, height: 16)
                                Text(c.rawValue.capitalized)
                            }.tag(c)
                        }
                    }
                }
                
                Section("Days of Week") {
                    HStack {
                        ForEach(1...7, id: \.self) { day in
                            let symbol = String(Calendar.current.shortWeekdaySymbols[day-1].prefix(2))
                            let selected = activeDays.contains(day)
                            
                            Text(symbol)
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(selected ? color.color.opacity(0.9) : Color.secondary.opacity(0.15))
                                )
                                .foregroundStyle(selected ? .white : .primary)
                                .onTapGesture {
                                    if selected { activeDays.remove(day) }
                                    else { activeDays.insert(day) }
                                }
                                .animation(.easeInOut(duration: 0.15), value: activeDays)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), color, activeDays)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Daily List
struct HabitListView: View {
    @AppStorage(habitsKey) private var habitsData: Data = Data()
    @State private var habits: [Habit] = []
    @State private var showAddSheet = false
    private let calendar = Calendar.current

    // Indexes of habits scheduled for *today* (used for safe delete mapping)
    private var todayIndexes: [Int] {
        habits.indices.filter { habits[$0].isScheduled(for: Date(), calendar: calendar) }
    }

    // MARK: - Persistence
    private func load() {
        habits = [Habit].decoded(from: habitsData)
    }
    private func save() {
        habitsData = habits.encoded()
    }

    var body: some View {
        NavigationStack {
            Group {
                if todayIndexes.isEmpty {
                    ContentUnavailableView(
                        "No Habits Today",
                        systemImage: "sun.max",
                        description: Text("Enjoy your rest day or add a new habit!")
                    )
                } else {
                    List {
                        ForEach(todayIndexes, id: \.self) { i in
                            let binding = $habits[i]
                            HStack(spacing: 12) {
                                Button {
                                    binding.wrappedValue.toggle(on: Date(), calendar: calendar)
                                    save()
                                } label: {
                                    Image(systemName: binding.wrappedValue.isDone(on: Date(), calendar: calendar)
                                          ? "checkmark.circle.fill" : "circle")
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(binding.wrappedValue.name)
                                        .font(.headline)
                                    // Optional: add a subtitle if you have one
                                    // Text(binding.wrappedValue.scheduleSummary)
                                    //   .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Circle()
                                    .fill(binding.wrappedValue.color.color)
                                    .frame(width: 10, height: 10)
                                    .accessibilityHidden(true)
                            }
                            .contentShape(Rectangle())
                        }
                        .onDelete { offsets in
                            // Map the visible row offsets back to real indices
                            let real = IndexSet(offsets.map { todayIndexes[$0] })
                            habits.remove(atOffsets: real)
                            save()
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Today's Habits")
        }
        // Floating "+" button overlay
        .overlay(alignment: .bottomTrailing) {
            Button { showAddSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 52, weight: .semibold))
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle().inset(by: -6))
                    .shadow(radius: 6)
                    .accessibilityLabel("Add Habit")
            }
            .padding(.trailing, 16)
            .padding(.bottom, 28) // keep clear of Tab Bar
        }
        // Add/Edit sheet (uses your EditHabitSheet defined above)
        .sheet(isPresented: $showAddSheet) {
            EditHabitSheet { name, color, activeDays in
                let newHabit = Habit(name: name, color: color, activeDays: activeDays)
                habits.append(newHabit)
                save()
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear(perform: load)
    }
}



// MARK: - Calendar Progress

struct HabitCalendarView: View {
    @AppStorage(habitsKey) private var habitsData: Data = Data()
    @State private var habits: [Habit] = []
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()
            
            let shown = habits.filter { $0.isScheduled(for: selectedDate, calendar: calendar) }
            if shown.isEmpty {
                ContentUnavailableView(
                    "No Habits",
                    systemImage: "calendar",
                    description: Text("No scheduled habits for this day.")
                )
            } else {
                List {
                    ForEach(shown) { habit in
                        HStack {
                            Circle()
                                .fill(habit.color.color)
                                .frame(width: 10, height: 10)
                            Text(habit.name)
                            Spacer()
                            Image(systemName: habit.isDone(on: selectedDate) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(habit.isDone(on: selectedDate) ? habit.color.color : .gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendar Progress")
        .onAppear { habits = [Habit].decoded(from: habitsData) }
    }
}


// MARK: - Root TabView

struct HabitTracker: View {
    var body: some View {
        TabView {
            NavigationStack {
                HabitListView()   // keeps its .navigationTitle and .toolbar
            }
            .tabItem { Label("Today", systemImage: "checkmark.circle") }

            NavigationStack {
                HabitCalendarView()
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }
}



// MARK: - Preview

#Preview {
    HabitTracker()
}
