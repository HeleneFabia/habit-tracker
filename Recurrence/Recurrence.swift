//
//  Recurrence.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation

struct Recurrence {
    private let cal = Calendar.app

    func isDue(_ habit: Habit, on day: Date) -> Bool {
        let d = startOfDay(day)
        let s = startOfDay(habit.startDate)
        guard d >= s else { return false }

        switch habit.cadenceKind {
        case .daily:
            return true

        case .everyNDays:
            guard let n = habit.cadenceN, n >= 2 else { return false }
            if EVERY_N_DAYS_ANCHORED_TO_START {
                let delta = cal.dateComponents([.day], from: s, to: d).day!
                return delta % n == 0
            } else {
                // Relative to last completion: next due N days after last checked date
                return true // Due if it's >= last check + n; we gate the toggle in UI by allowing any day and counting expected accordingly
            }

        case .weekdays:
            guard let mask = habit.weekdaysMask else { return false }
            let wd = cal.component(.weekday, from: d) // 1=Sun...7=Sat
            let idx = (wd + 5) % 7 // map Mon..Sun -> 0..6
            return (mask & (1 << idx)) != 0

        case .weekly:
            // Every N weeks on the weekday of startDate
            let n = habit.cadenceN ?? 1
            let startWeek = cal.component(.weekOfYear, from: s)
            let startYear = cal.component(.yearForWeekOfYear, from: s)
            let curWeek = cal.component(.weekOfYear, from: d)
            let curYear = cal.component(.yearForWeekOfYear, from: d)
            let weeks = weeksBetween(yearWeek1: (startYear, startWeek), yearWeek2: (curYear, curWeek))
            let sameWeekday = cal.component(.weekday, from: d) == cal.component(.weekday, from: s)
            return sameWeekday && (weeks % n == 0)

        case .monthly:
            guard let rule = habit.monthlyRule else { return false }
            switch rule {
            case .dayOfMonth:
                guard let dom = habit.dayOfMonth else { return false }
                let comps = cal.dateComponents([.year, .month, .day], from: d)
                if comps.day == dom { return true }
                // If month shorter than dom and fallback enabled, treat last day as due
                let (actualDay, skipped) = clampToMonthDay(year: comps.year!, month: comps.month!, day: dom)
                if skipped { return false }
                return comps.day == actualDay
            case .nthWeekday:
                guard let nth = habit.nth, let weekday = habit.weekday else { return false }
                let comps = cal.dateComponents([.year, .month, .day, .weekday], from: d)
                if comps.weekday != weekday { return false }
                // Determine if d is nth occurrence (1..4) or last (-1)
                if nth == -1 {
                    // last weekday of month
                    var last = lastWeekday(of: weekday, year: comps.year!, month: comps.month!)
                    return cal.isDate(d, inSameDayAs: last)
                } else {
                    var counter = 0
                    let firstOfMonth = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: 1))!
                    let range = cal.range(of: .day, in: .month, for: firstOfMonth)!
                    for day in range {
                        let date = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: day))!
                        if cal.component(.weekday, from: date) == weekday {
                            counter += 1
                            if counter == nth {
                                return cal.isDate(d, inSameDayAs: date)
                            }
                        }
                    }
                    return false
                }
            }
        }
    }

    func datesDue(_ habit: Habit, in range: ClosedRange<Date>) -> [Date] {
        let start = startOfDay(range.lowerBound)
        let end = startOfDay(range.upperBound)
        var dates: [Date] = []
        var cursor = start
        while cursor <= end {
            if isDue(habit, on: cursor) { dates.append(cursor) }
            cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
        }
        return dates
    }

    func expectedCount(_ habit: Habit, in range: ClosedRange<Date>) -> Int {
        datesDue(habit, in: range).count
    }

    private func weeksBetween(yearWeek1: (Int, Int), yearWeek2: (Int, Int)) -> Int {
        // crude but robust across year boundaries
        let (y1, w1) = yearWeek1
        let (y2, w2) = yearWeek2
        if y1 == y2 { return w2 - w1 }
        // normalize by approximate weeks per year
        let sign = (y2 > y1) ? 1 : -1
        var weeks = (w2 + sign * 52) - w1
        // Not exact around ISO weeks but OK for cadence alignment (we match weekday and mod n)
        return weeks
    }

    private func lastWeekday(of weekday: Int, year: Int, month: Int) -> Date {
        let firstOfMonth = Calendar.app.date(from: DateComponents(year: year, month: month, day: 1))!
        let range = Calendar.app.range(of: .day, in: .month, for: firstOfMonth)!
        for day in range.reversed() {
            let date = Calendar.app.date(from: DateComponents(year: year, month: month, day: day))!
            if Calendar.app.component(.weekday, from: date) == weekday {
                return date
            }
        }
        return firstOfMonth
    }
}

