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
    var targetPerWeek: Int = 3
    // Store completed days as "yyyy-MM-dd" keys for simple, stable persistence
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
    
    func weekProgress(weekOf referenceDate: Date = Date(), calendar: Calendar = .current) -> (done: Int, target: Int) {
        let start = calendar.startOfWeek(for: referenceDate)
        let keys = (0..<7).map { dateKey(calendar.date(byAdding: .day, value: $0, to: start)!, calendar: calendar) }
        let done = completedDays.intersection(keys).count
        return (done, max(1, targetPerWeek))
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

// MARK: - Persistence helpers

private let habitsKey = "habits.v1"

extension Array where Element == Habit {
    func encoded() -> Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }
    
    static func decoded(from data: Data) -> [Habit] {
        (try? JSONDecoder().decode([Habit].self, from: data)) ?? []
    }
}

// MARK: - Calendar helpers

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let comps = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: comps) ?? date
    }
}

private func dateKey(_ date: Date, calendar: Calendar = .current) -> String {
    let comps = calendar.dateComponents([.year, .month, .day], from: date)
    let y = comps.year ?? 0
    let m = comps.month ?? 0
    let d = comps.day ?? 0
    return String(format: "%04d-%02d-%02d", y, m, d)
}

private func weekdaySymbolsShort(calendar: Calendar = .current) -> [String] {
    // Returns short symbols starting Monday
    var symbols = calendar.shortWeekdaySymbols
    // Convert to Monday-first
    let shift = (calendar.firstWeekday == 2) ? 0 : ((calendar.firstWeekday + 5) % 7)
    if shift > 0 {
        symbols = Array(symbols[shift...]) + Array(symbols[..<shift])
    }
    return symbols
}

// MARK: - Add/Edit Sheet

struct EditHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var color: HabitColor
    @State private var target: Int
    
    let onSave: (String, HabitColor, Int) -> Void
    
    init(habit: Habit? = nil, onSave: @escaping (String, HabitColor, Int) -> Void) {
        _name = State(initialValue: habit?.name ?? "")
        _color = State(initialValue: habit?.color ?? .blue)
        _target = State(initialValue: habit?.targetPerWeek ?? 3)
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
                    Stepper(value: $target, in: 1...7) {
                        Text("Weekly target: \(target)")
                    }
                }
            }
            .navigationTitle("Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), color, target)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Row View (weekly grid)

struct HabitRow: View {
    var habit: Habit
    var startOfWeek: Date
    var onToggle: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(habit.color.color)
                    .frame(width: 10, height: 10)
                Text(habit.name)
                    .font(.headline)
                Spacer()
                let progress = habit.weekProgress(weekOf: startOfWeek, calendar: calendar)
                Text("\(progress.done)/\(progress.target)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(0..<7, id: \.self) { offset in
                    let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
                    let isToday = calendar.isDateInToday(date)
                    let done = habit.isDone(on: date, calendar: calendar)
                    
                    Button {
                        onToggle(date)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(done ? habit.color.color.opacity(0.9) : Color.secondary.opacity(0.15))
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(isToday ? Color.primary.opacity(0.35) : .clear, lineWidth: 1.5)
                            Text(weekdaySymbolsShort()[offset].uppercased())
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(done ? Color.white : Color.primary.opacity(0.7))
                                .padding(.vertical, 8)
                        }
                        .frame(height: 30)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("\(weekdaySymbolsShort()[offset])"))
                    .accessibilityValue(Text(done ? "Completed" : "Not completed"))
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Main View

struct HabitTracker: View {
    // Persist encoded array in UserDefaults via AppStorage
    @AppStorage(habitsKey) private var habitsData: Data = Data()
    
    @State private var habits: [Habit] = []
    @State private var showAddSheet = false
    @State private var editingHabit: Habit? = nil
    
    private let calendar = Calendar.current
    
    var startOfWeek: Date {
        calendar.startOfWeek(for: Date())
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView("No Habits Yet", systemImage: "checklist", description: Text("Add a habit to start tracking this week."))
                } else {
                    List {
                        ForEach(habits) { habit in
                            HabitRow(habit: habit,
                                     startOfWeek: startOfWeek,
                                     onToggle: { date in
                                withAnimation {
                                    toggle(habit: habit, on: date)
                                }
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation { delete(habit: habit) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    editingHabit = habit
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add Habit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EditHabitSheet { name, color, target in
                    let newHabit = Habit(name: name, color: color, targetPerWeek: target)
                    habits.append(newHabit)
                }
            }
            .sheet(item: $editingHabit) { habit in
                EditHabitSheet(habit: habit) { name, color, target in
                    if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
                        habits[idx].name = name
                        habits[idx].color = color
                        habits[idx].targetPerWeek = target
                    }
                }
            }
            .onAppear(perform: load)
            .onChange(of: habits) { _ in save() }
        }
        // Optional: set a default suite for AppStorage if needed
        // .defaultAppStorage(UserDefaults.standard)
    }
    
    // MARK: - Intent
    
    private func load() {
        let decoded = [Habit].decoded(from: habitsData)
        habits = decoded
    }
    
    private func save() {
        habitsData = habits.encoded()
    }
    
    private func toggle(habit: Habit, on date: Date) {
        guard let idx = habits.firstIndex(of: habit) else { return }
        habits[idx].toggle(on: date, calendar: calendar)
    }
    
    private func delete(habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
}

#Preview {
    HabitTracker()
}
