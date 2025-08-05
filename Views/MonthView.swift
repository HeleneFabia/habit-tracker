//
//  MonthView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct MonthView: View {
    @EnvironmentObject var vm: HabitsVM
    @State private var anchorMonth = Date()
    @State private var selectedDay: Date? = nil
    @State private var isShowingSheet = false

    private var monthDays: [Date] {
        let cal = Calendar.app
        let comps = cal.dateComponents([.year, .month], from: anchorMonth)
        let first = cal.date(from: comps)!
        let range = cal.range(of: .day, in: .month, for: first)!
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: first) }
    }

    var body: some View {
        VStack(spacing: 8) {
            header

            let cal = Calendar.app
            let gridItems = Array(repeating: GridItem(.flexible(minimum: 44)), count: 7)

            LazyVGrid(columns: gridItems, spacing: 8) {
                ForEach(weekdayHeaders(), id: \.self) {
                    Text($0)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ForEach(paddedMonthDays(), id: \.self) { date in
                    if let day = date {
                        Button {
                            selectedDay = day
                            isShowingSheet = true
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(cal.component(.day, from: day))")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // show simple dot if anything due
                                if !vm.dueHabits(on: day).isEmpty {
                                    Circle()
                                        .frame(width: 6, height: 6)
                                } else {
                                    Spacer().frame(height: 6)
                                }
                            }
                            .padding(6)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(.quaternary)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 48)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            if let day = selectedDay {
                DayDetailSheet(day: day)
                    .environmentObject(vm)
            }
        }
        .padding()
    }

    private var header: some View {
        HStack {
            Button {
                anchorMonth = Calendar.app.date(byAdding: .month, value: -1, to: anchorMonth)!
            } label: { Image(systemName: "chevron.left") }

            Text(monthTitle(anchorMonth))
                .font(.headline)
                .frame(minWidth: 160)

            Button {
                anchorMonth = Calendar.app.date(byAdding: .month, value: +1, to: anchorMonth)!
            } label: { Image(systemName: "chevron.right") }

            Spacer()

            Button("New Habit") { vm.showNewHabitSheet = true }
        }
    }

    private func monthTitle(_ d: Date) -> String {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return f.string(from: d)
    }

    private func weekdayHeaders() -> [String] {
        let f = DateFormatter()
        f.locale = .current
        return f.shortWeekdaySymbols
    }

    private func paddedMonthDays() -> [Date?] {
        let cal = Calendar.app
        let days = monthDays
        guard let first = days.first else { return [] }
        let weekday = cal.component(.weekday, from: first) // 1=Sun..7=Sat
        let leading = (weekday + 6) % 7 // number of leading blanks for Monday-first grids
        return Array(repeating: nil, count: leading) + days.map { Optional($0) }
    }
}

private struct DayDetailSheet: View {
    let day: Date
    @EnvironmentObject var vm: HabitsVM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(dayTitle(day))
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Close") { dismiss() }
            }

            List(vm.dueHabits(on: day), id: \.id) { h in
                HStack {
                    Text(h.emoji.isEmpty ? "🔘" : h.emoji)
                        .font(.title2)
                    Text(h.name)
                        .font(.headline)
                    Spacer()
                    CheckCircle(
                        checked: vm.isChecked(h, on: day),
                        onToggle: { newVal in
                            vm.set(h, on: day, to: newVal)
                        }
                    )
                }
                .padding(.vertical, 4)
            }
            .listStyle(.inset)
            .frame(minWidth: 380, minHeight: 280)
            .padding(.top, 8)
        }
        .padding()
    }

    private func dayTitle(_ d: Date) -> String {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("EEEE, MMM d")
        return f.string(from: d)
    }
}
