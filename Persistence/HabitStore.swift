//
//  HabitStore.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation
import GRDB

final class HabitStore {
    private let db: DatabaseQueue
    private let recurrence = Recurrence()

    init(db: DatabaseQueue) { self.db = db }

    func allHabits(includeArchived: Bool = false) throws -> [Habit] {
        try db.read { db in
            if includeArchived { return try Habit.fetchAll(db) }
            return try Habit.filter(Habit.Columns.archived == false).fetchAll(db)
        }
    }

    func upsertHabit(_ habit: Habit) throws {
        try db.write { db in try habit.save(db) }
    }

    func deleteHabit(_ id: String) throws {
        try db.write { db in _ = try Habit.deleteOne(db, key: id) }
    }

    func isChecked(habitId: String, on day: Date) throws -> Bool {
        try db.read { db in
            let d = dateAtLocalNoon(day).timeIntervalSince1970
            return try Checkmark
                .filter(Checkmark.Columns.habit_id == habitId && Checkmark.Columns.date == d)
                .fetchOne(db) != nil
        }
    }

    @discardableResult
    func toggle(habit: Habit, on day: Date) throws -> Bool {
        try db.write { db in
            let d = dateAtLocalNoon(day).timeIntervalSince1970
            if let existing = try Checkmark
                .filter(Checkmark.Columns.habit_id == habit.id && Checkmark.Columns.date == d)
                .fetchOne(db) {
                try existing.delete(db)
                return false
            } else {
                try Checkmark(habitId: habit.id, date: dateAtLocalNoon(day)).insert(db)
                return true
            }
        }
    }

    func checkedCount(_ habit: Habit, in range: ClosedRange<Date>) throws -> Int {
        try db.read { db in
            let lower = dateAtLocalNoon(range.lowerBound).timeIntervalSince1970
            let upper = dateAtLocalNoon(range.upperBound).timeIntervalSince1970
            return try Checkmark
                //.filter(Checkmark.Columns.habit_id == habit.id && (lower ... upper) ~= Checkmark.Columns.date)
                .filter(
                    (Checkmark.Columns.habit_id == habit.id)
                    && (Checkmark.Columns.date >= lower)
                    && (Checkmark.Columns.date <= upper)
                )
                .fetchCount(db)
        }
    }

    func expectedCount(_ habit: Habit, in range: ClosedRange<Date>) -> Int {
        recurrence.expectedCount(habit, in: range)
    }

    func dueHabits(on day: Date) throws -> [Habit] {
        let all = try allHabits()
        return all.filter { recurrence.isDue($0, on: day) }
    }

    func datesDue(_ habit: Habit, in range: ClosedRange<Date>) -> [Date] {
        recurrence.datesDue(habit, in: range)
    }
}
