import SwiftUI
import SwiftData

struct ActivityRowView: View {
    let activity: Activity
    let index: Int
    let isPressed: Bool
    let isAnimatingCompletion: Bool
    let isNewTask: Bool
    let onTap: () -> Void
    let onComplete: () -> Void
    @Binding var selectedDate: Date
    let onDeleteSingle: () -> Void
    let Today: Date = Calendar.current.startOfDay(for: Date())
    @Environment(\.modelContext) var modelContext
    
    // State for alert
    @State private var showMoveTaskAlert = false
    
    // Query to get all activities for deletion logic
    @Query var allActivities: [Activity]
    
    var body: some View {
        HStack {
           // ActivityIconView(activity: activity, isNewTask: isNewTask)
            
            VStack(alignment: .leading) {
                ActivityStatusView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
                ActivityNameView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
            }
            
            Spacer()
            
            CompletionButtonView(
                activity: activity,
                isAnimatingCompletion: isAnimatingCompletion,
                onComplete: onComplete,
                selectedDate: $selectedDate
            )
        }
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 15))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .animation(.easeOut(duration: 0.1), value: activity.color) // Add this
        )
        .foregroundColor(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onTapGesture {
            if selectedDate >= Calendar.current.startOfDay(for: Date()) {
                onTap()
            } else {
                // Show alert for past tasks
                showMoveTaskAlert = true
            }
        }
        .overlay(
            // Left accent bar
            RoundedRectangle(cornerRadius: 12)
                .fill(activity.color)
                .frame(width: 3)
                .opacity(activity.isCompleted ? 0.3 : 1.0),
            alignment: .leading
        )
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .alert("Move Task to Today?", isPresented: $showMoveTaskAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Move to Today") {
                moveTaskToToday()
            }
        } message: {
            Text("Do you want to move '\(activity.name)' to today? This will remove all past instances of this task and add it to today.")
        }
    }
    
    private func moveTaskToToday() {
        withAnimation {
            // First, check if this task already exists today to avoid duplicates
            let existingTodayTask = allActivities.first { task in
                Calendar.current.isDate(task.date, inSameDayAs: Today) &&
                task.name == activity.name &&
                !task.isCompleted
            }
            
            if existingTodayTask == nil{
                // Create new activity for today only if it doesn't exist
                let newActivity = Activity(
                    name: activity.name,
                    date: Today,
                    duration: activity.duration,
                    isCompleted: false,
                    movedFromPast: true
                )
                
                // Copy any additional properties if they exist
                if let baseID = activity.baseID {
                    newActivity.baseID = baseID
                }
                
                // Copy subtasks if any
                if !activity.subtasks.isEmpty {
                    for subtask in activity.subtasks {
                        let newSubtask = Subtask(
                            name: subtask.name,
                            isCompleted: false
                        )
                        newActivity.subtasks.append(newSubtask)
                    }
                }
                
                modelContext.insert(newActivity)
                print("Created new task for today: \(activity.name)")
            } else {
                print("Task already exists today, not creating duplicate")
            }
            
            // Delete all instances of this task from past dates (including carried-over ones)
            deleteAllMissingTaskInstances()
            
            try? modelContext.save()
        }
    }
    
    private func deleteAllMissingTaskInstances(){
        _ = Calendar.current
        // Find all activities with the same name or baseID that are incomplete and in the past
        var tasksToDelete: [Activity] = []
        
        if let baseID = activity.baseID {
            // If task has baseID, delete all tasks with same baseID that are incomplete and in the past
            tasksToDelete = allActivities.filter { task in
                task.baseID == baseID &&
                !task.isCompleted &&
                task.date < Today
            }
        } else {
            // If no baseID, find tasks with same name that are incomplete and in the past
            // This handles carried-over tasks that might not have baseID
            tasksToDelete = allActivities.filter { task in
                task.name == activity.name &&
                !task.isCompleted &&
                task.date < Today
            }
        }
        // Delete all found tasks (including the current one since it's already in the filter)
        for task in tasksToDelete {
            // Cancel any notifications/alarms for these tasks
            LocalNotificationManager().cancelNotification(for: task.id)
            AlarmManager.shared.stopAlarm(for: task.id)
            
            modelContext.delete(task)
        }
    }
}
