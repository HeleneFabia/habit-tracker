//
//  HabitsVM.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation

final class HabitsVM: ObservableObject {
    let store: HabitStore
    @Published var selectedDate: Date = Date()
    @Published var habits: [Habit] = []
    @Published var showEditor: Bool = false
    @Published var editingHabit: Habit? = nil
    @Published var showNewHabitSheet: Bool = false

    init(store: HabitStore) {
        self.store = store
        reload()
    }

    func reload() {
        do { habits = try store.allHabits() } catch { print("Reload error: \(error)") }
    }

    func dueHabits(on day: Date) -> [Habit] {
        (try? store.dueHabits(on: day)) ?? []
    }

    func toggle(_ habit: Habit, on day: Date) {
        do { _ = try store.toggle(habit: habit, on: day); objectWillChange.send() }
        catch { print("Toggle error: \(error)") }
    }

    func isChecked(_ habit: Habit, on day: Date) -> Bool {
        (try? store.isChecked(habitId: habit.id, on: day)) ?? false
    }

    func percent(for habit: Habit, days: Int) -> Double {
        let end = startOfDay(Date())
        let start = Calendar.app.date(byAdding: .day, value: -days + 1, to: end)!
        let range = start...end
        let expected = store.expectedCount(habit, in: range)
        guard expected > 0 else { return .nan }
        let checked = (try? store.checkedCount(habit, in: range)) ?? 0
        return 100.0 * Double(checked) / Double(expected)
    }
    
    func set(_ habit: Habit, on day: Date, to newValue: Bool) {
        do {
            let already = try store.isChecked(habitId: habit.id, on: day)
            if newValue != already {
                _ = try store.toggle(habit: habit, on: day)
            }
            objectWillChange.send()
        } catch { print("Toggle error: \(error)") }
    }
}
