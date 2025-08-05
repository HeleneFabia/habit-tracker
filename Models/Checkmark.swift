//
//  Checkmark.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation
import GRDB

struct Checkmark: Codable, FetchableRecord, PersistableRecord, Identifiable, Equatable {
    var id: String
    var habitId: String
    var date: Date     // stored at local noon
    var checked: Bool

    static let databaseTableName = "checkmark"

    enum Columns: String, ColumnExpression {
        case id, habit_id, date, checked
    }

    init(id: String = UUID().uuidString, habitId: String, date: Date, checked: Bool = true) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.checked = checked
    }

    init(row: Row) {
        id = row[Columns.id]
        habitId = row[Columns.habit_id]
        date = Date(timeIntervalSince1970: row[Columns.date])
        checked = row[Columns.checked]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.habit_id] = habitId
        container[Columns.date] = date.timeIntervalSince1970
        container[Columns.checked] = checked
    }
}

