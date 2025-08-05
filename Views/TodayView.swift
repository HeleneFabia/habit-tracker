//
//  TodayView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct TodayView: View {
    @EnvironmentObject var vm: HabitsVM
    @State private var date = Date()

    var body: some View {
        let due = vm.dueHabits(on: date)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.field)
                    .labelsHidden()
                Spacer()
                // (Removed) Button("New Habit") { vm.showNewHabitSheet = true }
            }

            if due.isEmpty {
                ContentUnavailableView("Nothing due today", systemImage: "sun.max")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(due, id: \.id) { h in
                    HStack(spacing: 12) {
                        Text(h.emoji.isEmpty ? "🔘" : h.emoji)
                            .font(.title2)
                        Text(h.name)
                            .font(.headline)
                        Spacer()
                        CheckCircle(
                            checked: vm.isChecked(h, on: date),
                            onToggle: { newVal in
                                vm.set(h, on: date, to: newVal)
                            }
                        )
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
        .padding()
    }
}
