//
//  DatabaseManager.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import Foundation
import GRDB

final class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    let dbQueue: DatabaseQueue

    private init() {
        do {
            let supportURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("Habits", isDirectory: true)

            try FileManager.default.createDirectory(at: supportURL, withIntermediateDirectories: true)
            let dbURL = supportURL.appendingPathComponent("habits.sqlite")

            var config = Configuration()
            config.foreignKeysEnabled = true
            config.prepareDatabase { db in
                try db.execute(sql: "PRAGMA journal_mode=WAL;")
            }
            dbQueue = try DatabaseQueue(path: dbURL.path, configuration: config)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
}
