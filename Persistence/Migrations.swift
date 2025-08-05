//
//  Migrations.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import GRDB

let migrator: DatabaseMigrator = {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("createHabitAndCheckmark") { db in
        try db.create(table: "habit") { t in
            t.column("id", .text).primaryKey()
            t.column("name", .text).notNull()
            t.column("emoji", .text).defaults(to: "")
            t.column("start_date", .double).notNull()
            t.column("archived", .boolean).notNull().defaults(to: false)

            t.column("cadence_kind", .integer).notNull() // 0..4
            t.column("cadence_n", .integer)
            t.column("weekdays_mask", .integer)
            t.column("monthly_rule", .integer)
            t.column("day_of_month", .integer)
            t.column("nth", .integer)
            t.column("weekday", .integer) // 1=Sun..7=Sat
        }

        try db.create(table: "checkmark") { t in
            t.column("id", .text).primaryKey()
            t.column("habit_id", .text).notNull().indexed().references("habit", onDelete: .cascade)
            t.column("date", .double).notNull()
            t.column("checked", .boolean).notNull().defaults(to: true)
            t.uniqueKey(["habit_id", "date"])
        }
    }

    return migrator
}()
