//
//  CheckCircle.swift
//  habit tracker
//
//  Created by Helene on 04.08.25.
//
import SwiftUI

// CheckCircle.swift
struct CheckCircle: View {
    @State private var isChecked: Bool
    let checked: Bool
    let onToggle: (Bool) -> Void

    init(checked: Bool, onToggle: @escaping (Bool) -> Void) {
        self.checked = checked
        _isChecked = State(initialValue: checked)
        self.onToggle = onToggle
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isChecked.toggle()
                onToggle(isChecked)
            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(.secondary, lineWidth: 2)
                    .frame(width: 28, height: 28)
                if isChecked {
                    Circle().frame(width: 24, height: 24).opacity(0.25)
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .bold))
                }
            }
            .contentShape(Circle())
            .padding(4)
        }
        .buttonStyle(.borderless) // <- important for macOS lists
        .onChange(of: checked) { newVal in
            // keep local state in sync with the source of truth
            isChecked = newVal
        }
    }
}
