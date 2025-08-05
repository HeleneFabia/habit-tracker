//
//  DateUtils.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation

enum MonthShortfallBehavior {
    case fallbackToLastDay // default
    case skipMonth
}

// Defaults you can flip if you change your mind later:
let MONTH_SHORTFALL_BEHAVIOR: MonthShortfallBehavior = .fallbackToLastDay
let EVERY_N_DAYS_ANCHORED_TO_START: Bool = true

extension Calendar {
    static var app: Calendar {
        var cal = Calendar.current
        cal.timeZone = .current
        return cal
    }
}

func dateAtLocalNoon(_ date: Date) -> Date {
    let cal = Calendar.app
    let comps = cal.dateComponents([.year, .month, .day], from: date)
    return cal.date(from: DateComponents(year: comps.year, month: comps.month, day: comps.day, hour: 12))!
}

func startOfDay(_ date: Date) -> Date {
    Calendar.app.startOfDay(for: date)
}

func endOfDay(_ date: Date) -> Date {
    let cal = Calendar.app
    return cal.date(byAdding: .day, value: 1, to: startOfDay(date))!.addingTimeInterval(-1)
}

func clampToMonthDay(year: Int, month: Int, day: Int) -> (actualDay: Int, skipped: Bool) {
    var comps = DateComponents(year: year, month: month)
    let cal = Calendar.app
    let range = cal.range(of: .day, in: .month, for: cal.date(from: comps)!)!
    if range.contains(day) { return (day, false) }
    switch MONTH_SHORTFALL_BEHAVIOR {
    case .fallbackToLastDay:
        return (range.upperBound - 1, false)
    case .skipMonth:
        return (day, true)
    }
}

