//
//  TaskSelectionRow.swift
//  Me+
//
//  Created by Hari's Mac on 25.06.2025.
//

import SwiftUI


// MARK: - Task Selection Row
struct TaskSelectionRow: View {
    let task: ParsedTask
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.indigo : Color(.systemGray4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.indigo)
                            .font(.system(size: 10, weight: .bold))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Label("\(task.duration) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.indigo.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Label(formatDate(task.suggestedDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.indigo.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
#Preview{
    TaskSelectionRow(
        task: ParsedTask(name: "Sample", duration: 0, suggestedDate: Date.now, originalLine: "Hey hello"),isSelected: true, onToggle: {_ in }
    )
}
