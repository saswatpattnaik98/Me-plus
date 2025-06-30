//import SwiftUI
//import SwiftData
//
//struct ActivityRowView: View {
//    let activity: Activity
//    let index: Int
//    let isPressed: Bool
//    let isAnimatingCompletion: Bool
//    let isNewTask: Bool
//    let onTap: () -> Void
//    let onComplete: () -> Void
//    @Binding var selectedDate: Date
//    let onDeleteSingle: () -> Void
//    let Today: Date = Calendar.current.startOfDay(for: Date())
//    @Environment(\.modelContext) var modelContext
//    
//    // State for alert and interactions
//    @State private var showMoveTaskAlert = false
//    @State private var isLongPressed = false
//    @State private var dragOffset = CGSize.zero
//    
//    // Query to get all activities for deletion logic
//    @Query var allActivities: [Activity]
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            // Enhanced Activity Icon with subtle glow
//            ActivityIconView(activity: activity, isNewTask: isNewTask)
//                .shadow(color: activity.color.opacity(0.3), radius: isNewTask ? 8 : 4, x: 0, y: 2)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                // Priority indicator (optional - add if Activity has priority)
//                HStack(spacing: 6) {
//                    ActivityNameView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
//                    
//                    Spacer()
//                    
//                    // Time/Duration indicator
//                    if activity.duration > 0 {
//                        HStack(spacing: 4) {
//                            Image(systemName: "clock")
//                                .font(.system(size: 10, weight: .medium))
//                                .foregroundColor(.secondary)
//                            Text("\(activity.duration)m")
//                                .font(.system(size: 11, weight: .medium, design: .rounded))
//                                .foregroundColor(.secondary)
//                        }
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .background(
//                            Capsule()
//                                .fill(Color.secondary.opacity(0.15))
//                        )
//                    }
//                }
//                
//                // Status with subtle animation
//                ActivityStatusView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
//                
//                // Subtasks progress (if any)
//                if !activity.subtasks.isEmpty {
//                    SubtaskProgressView(subtasks: activity.subtasks)
//                }
//            }
//            
//            Spacer()
//            
//            // Enhanced completion button
//            CompletionButtonView(
//                activity: activity,
//                isAnimatingCompletion: isAnimatingCompletion,
//                onComplete: onComplete,
//                selectedDate: $selectedDate
//            )
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 16)
//        .background(
//            ZStack {
//                // Main background with subtle gradient
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(
//                        LinearGradient(
//                            colors: [
//                                activity.color.opacity(0.08),
//                                activity.color.opacity(0.12)
//                            ],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                
//                // Subtle border
//                RoundedRectangle(cornerRadius: 16)
//                    .strokeBorder(
//                        LinearGradient(
//                            colors: [
//                                activity.color.opacity(0.2),
//                                activity.color.opacity(0.1)
//                            ],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        ),
//                        lineWidth: 1
//                    )
//                
//                // New task shimmer effect
//                if isNewTask {
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(
//                            LinearGradient(
//                                colors: [
//                                    Color.white.opacity(0.1),
//                                    Color.white.opacity(0.05),
//                                    Color.white.opacity(0.1)
//                                ],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .opacity(0.6)
//                }
//                
//                // Completion overlay
//                if activity.isCompleted {
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color.green.opacity(0.05))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
//                        )
//                }
//            }
//        )
//        .overlay(
//            // Subtle inner shadow for depth
//            RoundedRectangle(cornerRadius: 16)
//                .strokeBorder(
//                    LinearGradient(
//                        colors: [
//                            Color.white.opacity(0.1),
//                            Color.clear,
//                            Color.black.opacity(0.1)
//                        ],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ),
//                    lineWidth: 0.5
//                )
//        )
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .contentShape(Rectangle())
//        .scaleEffect(isPressed ? 0.98 : 1.0)
//        .opacity(isPressed ? 0.9 : 1.0)
//        .offset(dragOffset)
//        .shadow(
//            color: activity.color.opacity(isPressed ? 0.3 : 0.1),
//            radius: isPressed ? 12 : 6,
//            x: 0,
//            y: isPressed ? 6 : 3
//        )
//        .transition(.asymmetric(
//            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
//            removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.8))
//        ))
//        .onTapGesture {
//            if selectedDate >= Calendar.current.startOfDay(for: Date()) {
//                onTap()
//            } else {
//                showMoveTaskAlert = true
//            }
//        }
//        .onLongPressGesture(minimumDuration: 0.5) {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                isLongPressed.toggle()
//            }
//        }
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                        dragOffset = CGSize(width: value.translation.width * 0.1, height: 0)
//                    }
//                }
//                .onEnded { value in
//                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                        dragOffset = .zero
//                    }
//                    
//                    // Swipe to complete (right swipe)
//                    if value.translation.width > 50 && !activity.isCompleted {
//                        onComplete()
//                    }
//                    // Swipe to delete (left swipe)
//                    else if value.translation.width < -50 {
//                        onDeleteSingle()
//                    }
//                }
//        )
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAnimatingCompletion)
//        .alert("Move Task to Today?", isPresented: $showMoveTaskAlert) {
//            Button("Cancel", role: .cancel) { }
//            Button("Yes, Move to Today") {
//                moveTaskToToday()
//            }
//        } message: {
//            Text("Do you want to move '\(activity.name)' to today? This will remove all past instances of this task and add it to today.")
//        }
//    }
//    
//    private func moveTaskToToday() {
//        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
//            // First, check if this task already exists today to avoid duplicates
//            let existingTodayTask = allActivities.first { task in
//                Calendar.current.isDate(task.date, inSameDayAs: Today) &&
//                task.name == activity.name &&
//                !task.isCompleted
//            }
//            
//            if existingTodayTask == nil {
//                // Create new activity for today only if it doesn't exist
//                let newActivity = Activity(
//                    name: activity.name,
//                    date: Today,
//                    duration: activity.duration,
//                    isCompleted: false,
//                    movedFromPast: true
//                )
//                
//                // Copy any additional properties if they exist
//                if let baseID = activity.baseID {
//                    newActivity.baseID = baseID
//                }
//                
//                // Copy subtasks if any
//                if !activity.subtasks.isEmpty {
//                    for subtask in activity.subtasks {
//                        let newSubtask = Subtask(
//                            name: subtask.name,
//                            isCompleted: false
//                        )
//                        newActivity.subtasks.append(newSubtask)
//                    }
//                }
//                
//                modelContext.insert(newActivity)
//                print("Created new task for today: \(activity.name)")
//            } else {
//                print("Task already exists today, not creating duplicate")
//            }
//            
//            // Delete all instances of this task from past dates
//            deleteAllMissingTaskInstances()
//            
//            try? modelContext.save()
//        }
//    }
//    
//    private func deleteAllMissingTaskInstances() {
//        var tasksToDelete: [Activity] = []
//        
//        if let baseID = activity.baseID {
//            tasksToDelete = allActivities.filter { task in
//                task.baseID == baseID &&
//                !task.isCompleted &&
//                task.date < Today
//            }
//        } else {
//            tasksToDelete = allActivities.filter { task in
//                task.name == activity.name &&
//                !task.isCompleted &&
//                task.date < Today
//            }
//        }
//        
//        for task in tasksToDelete {
//            LocalNotificationManager().cancelNotification(for: task.id)
//            AlarmManager.shared.stopAlarm(for: task.id)
//            modelContext.delete(task)
//        }
//    }
//}
//
//// MARK: - Subtask Progress View
//struct SubtaskProgressView: View {
//    let subtasks: [Subtask]
//    
//    private var completedCount: Int {
//        subtasks.filter { $0.isCompleted }.count
//    }
//    
//    private var totalCount: Int {
//        subtasks.count
//    }
//    
//    private var progress: Double {
//        guard totalCount > 0 else { return 0 }
//        return Double(completedCount) / Double(totalCount)
//    }
//    
//    var body: some View {
//        HStack(spacing: 8) {
//            // Progress bar
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    // Background
//                    Capsule()
//                        .fill(Color.secondary.opacity(0.2))
//                        .frame(height: 4)
//                    
//                    // Progress fill
//                    Capsule()
//                        .fill(
//                            LinearGradient(
//                                colors: [Color.blue, Color.blue.opacity(0.7)],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .frame(width: geometry.size.width * progress, height: 4)
//                }
//            }
//            .frame(height: 4)
//            
//            // Progress text
//            Text("\(completedCount)/\(totalCount)")
//                .font(.system(size: 10, weight: .medium, design: .rounded))
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: 120)
//    }
//}
