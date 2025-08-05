//
//  HabitApp.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct HabitsApp: App {
    @StateObject private var habitsVM: HabitsVM

    init() {
        let db = DatabaseManager.shared.dbQueue
        _habitsVM = StateObject(wrappedValue: HabitsVM(store: HabitStore(db: db)))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitsVM)
        }
        .commands {
            // New Habit shortcut
            CommandGroup(replacing: .newItem) {
                Button("New Habit") { habitsVM.showNewHabitSheet = true }
                    .keyboardShortcut("n", modifiers: [.command])
            }

            // Data menu
            CommandMenu("Data") {
                Button("Reveal Data Folder…") {
                    revealDataFolder()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
        }
    }

    // MARK: - Helpers

    private func revealDataFolder() {
        #if os(macOS)
        do {
            let supportURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("Habits", isDirectory: true)

            // Ensure the folder exists
            try FileManager.default.createDirectory(at: supportURL, withIntermediateDirectories: true)

            NSWorkspace.shared.activateFileViewerSelecting([supportURL])
        } catch {
            NSSound.beep()
            print("Reveal data failed:", error)
        }
        #endif
    }
}
