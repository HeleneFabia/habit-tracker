//
//  Habit.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation
import GRDB

enum CadenceKind: Int, Codable {
    case daily = 0
    case everyNDays = 1
    case weekdays = 2
    case weekly = 3
    case monthly = 4
}

enum MonthlyRule: Int, Codable {
    case dayOfMonth = 0
    case nthWeekday = 1
}

struct Habit: Codable, FetchableRecord, PersistableRecord, Identifiable, Equatable {
    var id: String
    var name: String
    var emoji: String
    var startDate: Date
    var archived: Bool

    var cadenceKind: CadenceKind
    var cadenceN: Int?            // every N days/weeks
    var weekdaysMask: Int?        // bitmask: Mon=1<<0 ... Sun=1<<6
    var monthlyRule: MonthlyRule?
    var dayOfMonth: Int?
    var nth: Int?
    var weekday: Int?             // 1=Sun ... 7=Sat

    static let databaseTableName = "habit"

    enum Columns: String, ColumnExpression {
        case id, name, emoji, start_date, archived,
             cadence_kind, cadence_n, weekdays_mask, monthly_rule, day_of_month, nth, weekday
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        emoji: String = "",
        startDate: Date = .now,
        archived: Bool = false,
        cadenceKind: CadenceKind,
        cadenceN: Int? = nil,
        weekdaysMask: Int? = nil,
        monthlyRule: MonthlyRule? = nil,
        dayOfMonth: Int? = nil,
        nth: Int? = nil,
        weekday: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.startDate = startDate
        self.archived = archived
        self.cadenceKind = cadenceKind
        self.cadenceN = cadenceN
        self.weekdaysMask = weekdaysMask
        self.monthlyRule = monthlyRule
        self.dayOfMonth = dayOfMonth
        self.nth = nth
        self.weekday = weekday
    }

    // GRDB <-> Swift mapping
    init(row: Row) {
        id = row[Columns.id]
        name = row[Columns.name]
        emoji = row[Columns.emoji]
        startDate = Date(timeIntervalSince1970: row[Columns.start_date])
        archived = row[Columns.archived]
        cadenceKind = CadenceKind(rawValue: row[Columns.cadence_kind])!
        cadenceN = row[Columns.cadence_n]
        weekdaysMask = row[Columns.weekdays_mask]
        // monthlyRule = row[Columns.monthly_rule].flatMap(MonthlyRule.init(rawValue:))
        monthlyRule = (row[Columns.monthly_rule] as Int?).flatMap(MonthlyRule.init(rawValue:))
        //let monthlyRaw: Int? = row[Columns.monthly_rule]
        //monthlyRule = monthlyRaw.flatMap(MonthlyRule.init(rawValue:))
        dayOfMonth = row[Columns.day_of_month]
        nth = row[Columns.nth]
        weekday = row[Columns.weekday]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.emoji] = emoji
        container[Columns.start_date] = startDate.timeIntervalSince1970
        container[Columns.archived] = archived
        container[Columns.cadence_kind] = cadenceKind.rawValue
        container[Columns.cadence_n] = cadenceN
        container[Columns.weekdays_mask] = weekdaysMask
        container[Columns.monthly_rule] = monthlyRule?.rawValue
        container[Columns.day_of_month] = dayOfMonth
        container[Columns.nth] = nth
        container[Columns.weekday] = weekday
    }
}

