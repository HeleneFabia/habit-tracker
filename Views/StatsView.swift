//
//  StatsView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var vm: HabitsVM
    @State private var year: Int = Calendar.app.component(.year, from: Date())

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header

            ScrollView([.vertical, .horizontal]) {
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                    // Header row
                    GridRow {
                        Text("") // top-left corner
                            .frame(minWidth: 120, alignment: .leading)
                        ForEach(vm.habits, id: \.id) { h in
                            HStack(spacing: 6) {
                                Text(h.emoji.isEmpty ? "🏷️" : h.emoji)
                                Text(h.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .font(.subheadline)
                            .frame(minWidth: 120, alignment: .leading)
                        }
                    }

                    // Month rows (Jan...limit)
                    ForEach(1...monthLimit(for: year), id: \.self) { m in
                        GridRow {
                            Text(monthLabel(year: year, month: m))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(minWidth: 120, alignment: .leading)

                            ForEach(vm.habits, id: \.id) { h in
                                let r = monthRange(year: year, month: m)
                                let counts = counts(h, in: r)
                                CountCell(checked: counts.checked, expected: counts.expected)
                                    .frame(minWidth: 120, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .overlay {
                if vm.habits.isEmpty {
                    ContentUnavailableView("No habits to show", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { year -= 1 } label: { Image(systemName: "chevron.left") }

            Text(String(year))
                .font(.headline)
                .frame(minWidth: 100)

            Button {
                // Don’t go into the future
                let current = Calendar.app.component(.year, from: Date())
                if year < current { year += 1 }
            } label: { Image(systemName: "chevron.right") }

            Spacer()
        }
    }

    // MARK: - Helpers

    private func monthLimit(for y: Int) -> Int {
        let currentYear = Calendar.app.component(.year, from: Date())
        if y == currentYear {
            return Calendar.app.component(.month, from: Date()) // 1...current month
        } else {
            return 12
        }
    }

    private func monthLabel(year: Int, month: Int) -> String {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = 1
        let d = Calendar.app.date(from: comps)!
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMM yyyy")
        return f.string(from: d)
    }

    private func monthRange(year: Int, month: Int) -> ClosedRange<Date> {
        let cal = Calendar.app
        let start = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        let startNext = cal.date(byAdding: DateComponents(month: 1), to: start)!
        // Inclusive range: start-of-month ... end-of-month
        return startOfDay(start)...endOfDay(startNext.addingTimeInterval(-24*60*60))
    }

    private func counts(_ habit: Habit, in range: ClosedRange<Date>) -> (checked: Int, expected: Int) {
        let expected = vm.store.expectedCount(habit, in: range)
        let checked = (try? vm.store.checkedCount(habit, in: range)) ?? 0
        return (checked, expected)
    }
}

private struct CountCell: View {
    let checked: Int
    let expected: Int

    var body: some View {
        Text("\(checked) / \(expected)")
            .font(.subheadline)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
            )
    }
}
