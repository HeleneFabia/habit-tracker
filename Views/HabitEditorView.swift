//
//  HabitEditorView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct HabitEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: HabitsVM

    @Binding var habit: Habit? // if nil, create new

    @State private var name: String = ""
    @State private var emoji: String = ""
    @State private var startDate: Date = Date()
    @State private var cadenceKind: CadenceKind = .daily
    @State private var cadenceN: Int = 2
    @State private var weekdaysMask: Int = 0b0111110 // Mon-Fri default
    @State private var monthlyRule: MonthlyRule = .dayOfMonth
    @State private var dayOfMonth: Int = 1
    @State private var nth: Int = 1
    @State private var weekday: Int = 2 // Monday

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(habit == nil ? "New Habit" : "Edit Habit").font(.title2).bold()
            Form {
                TextField("Name", text: $name)
                TextField("Emoji (optional)", text: $emoji)
                DatePicker("Start date", selection: $startDate, displayedComponents: .date)

                Picker("Cadence", selection: $cadenceKind) {
                    Text("Daily").tag(CadenceKind.daily)
                    Text("Every N days").tag(CadenceKind.everyNDays)
                    Text("Specific weekdays").tag(CadenceKind.weekdays)
                    Text("Weekly").tag(CadenceKind.weekly)
                    Text("Monthly").tag(CadenceKind.monthly)
                }

                switch cadenceKind {
                case .everyNDays:
                    Stepper(value: $cadenceN, in: 2...30) { Text("Every \(cadenceN) day(s)") }
                case .weekdays:
                    WeekdayPicker(mask: $weekdaysMask)
                case .weekly:
                    Stepper(value: $cadenceN, in: 1...12) { Text("Every \(cadenceN) week(s)") }
                case .monthly:
                    Picker("Rule", selection: $monthlyRule) {
                        Text("Day of month").tag(MonthlyRule.dayOfMonth)
                        Text("Nth weekday").tag(MonthlyRule.nthWeekday)
                    }
                    if monthlyRule == .dayOfMonth {
                        Stepper(value: $dayOfMonth, in: 1...31) { Text("Day \(dayOfMonth)") }
                        Text("Short months will \(MONTH_SHORTFALL_BEHAVIOR == .fallbackToLastDay ? "fallback to the last day" : "be skipped").")
                            .font(.caption).foregroundStyle(.secondary)
                    } else {
                        Stepper(value: $nth, in: -1...4) { Text(nth == -1 ? "Last" : "\(nth)th") }
                        Picker("Weekday", selection: $weekday) {
                            ForEach(1...7, id: \.self) { Text(weekdayName($0)).tag($0) }
                        }
                    }
                default: EmptyView()
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") { save() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 420)
        .onAppear { loadIfEditing() }
    }

    private func loadIfEditing() {
        guard let h = habit else { return }
        name = h.name
        emoji = h.emoji
        startDate = h.startDate
        cadenceKind = h.cadenceKind
        cadenceN = h.cadenceN ?? 2
        weekdaysMask = h.weekdaysMask ?? 0
        monthlyRule = h.monthlyRule ?? .dayOfMonth
        dayOfMonth = h.dayOfMonth ?? 1
        nth = h.nth ?? 1
        weekday = h.weekday ?? 2
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var record = habit ?? Habit(name: name, emoji: emoji, startDate: startDate, archived: false, cadenceKind: cadenceKind)
        record.name = name
        record.emoji = emoji
        record.startDate = startDate
        record.cadenceKind = cadenceKind
        switch cadenceKind {
        case .daily:
            record.cadenceN = nil; record.weekdaysMask = nil; record.monthlyRule = nil; record.dayOfMonth = nil; record.nth = nil; record.weekday = nil
        case .everyNDays:
            record.cadenceN = cadenceN; record.weekdaysMask = nil; record.monthlyRule = nil; record.dayOfMonth = nil; record.nth = nil; record.weekday = nil
        case .weekdays:
            record.weekdaysMask = weekdaysMask; record.cadenceN = nil; record.monthlyRule = nil; record.dayOfMonth = nil; record.nth = nil; record.weekday = nil
        case .weekly:
            record.cadenceN = cadenceN; record.weekdaysMask = nil; record.monthlyRule = nil; record.dayOfMonth = nil; record.nth = nil; record.weekday = nil
        case .monthly:
            record.monthlyRule = monthlyRule
            if monthlyRule == .dayOfMonth {
                record.dayOfMonth = dayOfMonth
                record.nth = nil; record.weekday = nil
            } else {
                record.nth = nth; record.weekday = weekday
                record.dayOfMonth = nil
            }
            record.cadenceN = nil; record.weekdaysMask = nil
        }

        do {
            try vm.store.upsertHabit(record)
            vm.reload()
            dismiss()
        } catch {
            print("Save error: \(error)")
        }
    }

    private func weekdayName(_ w: Int) -> String {
        let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return names[(w - 1 + 7) % 7]
    }
}

struct WeekdayPicker: View {
    @Binding var mask: Int
    private let labels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

    var body: some View {
        HStack {
            ForEach(0..<7) { i in
                Toggle(labels[i], isOn: Binding(get: {
                    (mask & (1 << i)) != 0
                }, set: { newVal in
                    if newVal { mask |= (1 << i) } else { mask &= ~(1 << i) }
                }))
                .toggleStyle(.button)
            }
        }
    }
}

