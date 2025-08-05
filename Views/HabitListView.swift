//
//  HabitListView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var vm: HabitsVM
    @State private var includeArchived = false
    @State private var list: [Habit] = []   // local source for this screen

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Toggle("Show archived", isOn: $includeArchived).toggleStyle(.switch)
                Spacer()
                Button("New Habit") { vm.showNewHabitSheet = true }
            }

            List {
                ForEach(list, id: \.id) { h in
                    HStack {
                        Text(h.emoji.isEmpty ? "🏷️" : h.emoji).font(.title3)
                        VStack(alignment: .leading) {
                            Text(h.name).font(.headline)
                            Text(cadenceSummary(h)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(h.archived ? "Unarchive" : "Archive") {
                            var m = h; m.archived.toggle()
                            try? vm.store.upsertHabit(m)
                            load() // refresh
                            vm.reload()
                        }
                        Button("Edit") {
                            vm.editingHabit = h
                            vm.showEditor = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .onDelete(perform: delete(at:))
            }
            .listStyle(.inset)
        }
        .padding()
        .onAppear { load() }
        .onChange(of: includeArchived) { _ in load() }
        .sheet(isPresented: $vm.showEditor) {
            if let editing = vm.editingHabit {
                HabitEditorView(habit: .constant(editing))
                    .onDisappear { load() } // reflect edits
            }
        }
    }

    // MARK: - Data
    private func load() {
        // Pull from DB with or without archived, without touching vm.habits
        list = (try? vm.store.allHabits(includeArchived: includeArchived)) ?? []
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            try? vm.store.deleteHabit(list[i].id)
        }
        load()
        vm.reload()
    }

    // MARK: - Helpers
    private func cadenceSummary(_ h: Habit) -> String {
        switch h.cadenceKind {
        case .daily: return "Daily"
        case .everyNDays: return "Every \(h.cadenceN ?? 2) day(s)"
        case .weekdays:
            let names = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
            let sel = (0..<7).compactMap { (h.weekdaysMask ?? 0) & (1<<$0) != 0 ? names[$0] : nil }
            return "On: " + sel.joined(separator: ", ")
        case .weekly:
            return "Weekly (every \(h.cadenceN ?? 1) week(s))"
        case .monthly:
            if h.monthlyRule == .dayOfMonth { return "Monthly on day \(h.dayOfMonth ?? 1)" }
            if h.monthlyRule == .nthWeekday {
                let nth = h.nth == -1 ? "last" : "\(h.nth ?? 1)th"
                let weekday = weekdayName(h.weekday ?? 2)
                return "Monthly on \(nth) \(weekday)"
            }
            return "Monthly"
        }
    }

    private func weekdayName(_ w: Int) -> String {
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return names[(w - 1 + 7) % 7]
    }
}
