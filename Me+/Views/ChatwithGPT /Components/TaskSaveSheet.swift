//
//  TaskSaveSheet.swift
//  Me+
//
//  Created by Hari's Mac on 25.06.2025.
//

import SwiftUI

// MARK: - Task Save Sheet
struct TaskSaveSheet: View {
    let tasks: [ParsedTask]
    let onSave: ([ParsedTask]) -> Void
    let onCancel: () -> Void
    
    @State private var selectedTasks: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("Save Tasks")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Verify the tasks going to add ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(tasks) { task in
                            TaskSelectionRow(
                                task: task,
                                isSelected: selectedTasks.contains(task.id)
                            ) { isSelected in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if isSelected {
                                        selectedTasks.insert(task.id)
                                    } else {
                                        selectedTasks.remove(task.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button("Add \(selectedTasks.count) Tasks") {
                        let tasksToSave = tasks.filter { selectedTasks.contains($0.id) }
                        onSave(tasksToSave)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: selectedTasks.isEmpty ?
                                [Color(.systemGray5)] : [Color.indigo, Color.indigo.opacity(0.8)]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(selectedTasks.isEmpty ? .secondary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(selectedTasks.isEmpty)
                    .shadow(color: selectedTasks.isEmpty ? .clear : .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .onAppear {
            selectedTasks = Set(tasks.map { $0.id })
        }
    }
}
#Preview{
    TaskSaveSheet(
        tasks: [ParsedTask(name: "Sample", duration: 0, suggestedDate: Date.now, originalLine: "For example")],
        onSave: { selectedTasks in
           // viewModel.saveTasksToTodoApp(selectedTasks, modelContext: modelContext)
        }, onCancel: {}
    )
}
