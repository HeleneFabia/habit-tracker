//
//  ContentView.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: HabitsVM

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "largecircle.fill.circle") }
            WeekView()
                .tabItem { Label("Week", systemImage: "calendar") }
            //MonthView()
            //    .tabItem { Label("Month", systemImage: "calendar.circle") }
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.pie") }
            HabitListView()
                .tabItem { Label("Habits", systemImage: "list.bullet") }
        }
        .sheet(isPresented: $vm.showNewHabitSheet) {
            HabitEditorView(habit: .constant(nil))
                .frame(minWidth: 400, minHeight: 420)
        }
    }
}
