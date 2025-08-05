//
//  WeekView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct WeekView: View {
    @EnvironmentObject var vm: HabitsVM
    @State private var anchorDate = Date()

    private var weekDays: [Date] {
        let cal = Calendar.app
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: anchorDate))!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        let habits = vm.habits
        ScrollView([.vertical, .horizontal]) {
            VStack(spacing: 8) {
                header
                if habits.isEmpty {
                    ContentUnavailableView("No habits yet", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                        GridRow {
                            Text("") // corner
                            ForEach(weekDays, id: \.self) { d in
                                VStack {
                                    Text(shortWeekday(d)).font(.caption2)
                                    Text(dayNumber(d)).font(.caption)
                                }
                                .frame(minWidth: 48)
                            }
                        }
                        ForEach(habits, id: \.id) { h in
                            GridRow {
                                HStack {
                                    Text(h.emoji.isEmpty ? "🏷️" : h.emoji)
                                    Text(h.name).font(.subheadline)
                                }
                                .frame(minWidth: 140, alignment: .leading)
                                ForEach(weekDays, id: \.self) { d in
                                    let due = vm.dueHabits(on: d).contains(where: { $0.id == h.id })
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8).strokeBorder(.quaternary)
                                        if due {
                                            CheckCircle(
                                                checked: vm.isChecked(h, on: d),
                                                onToggle: { newVal in
                                                    vm.set(h, on: d, to: newVal)
                                                }
                                            )
                                        } else {
                                            Text("—").foregroundStyle(.secondary).font(.caption)
                                        }
                                    }
                                    .frame(width: 56, height: 40)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var header: some View {
        HStack {
            Button {
                anchorDate = Calendar.app.date(byAdding: .day, value: -7, to: anchorDate)!
            } label: { Image(systemName: "chevron.left") }
            Text(weekTitle(anchorDate)).font(.headline).frame(minWidth: 160)
            Button {
                anchorDate = Calendar.app.date(byAdding: .day, value: +7, to: anchorDate)!
            } label: { Image(systemName: "chevron.right") }
            Spacer()
            // (Removed) Button("New Habit") { vm.showNewHabitSheet = true }
        }
    }

    private func shortWeekday(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("EEE")
        return f.string(from: d)
    }

    private func dayNumber(_ d: Date) -> String {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("d")
        return f.string(from: d)
    }

    private func weekTitle(_ d: Date) -> String {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMM d")
        let start = Calendar.app.date(from: Calendar.app.dateComponents([.yearForWeekOfYear, .weekOfYear], from: d))!
        let end = Calendar.app.date(byAdding: .day, value: 6, to: start)!
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }
}
