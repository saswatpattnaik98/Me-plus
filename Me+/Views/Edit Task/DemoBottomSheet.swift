//import SwiftUI
//
//struct BottomSheetEditView: View {
//    var activity: Activity
//    @State private var showEditHabit = false
//    @StateObject var addHabitViewModel = AddhabitViewModel()
//    @StateObject var editHabitViewModel: EditHabitViewModel
//    @State private var subtaskCount = 0
//    @State private var subtaskCompleted = 0
//    @State private var animateCompletion = false
//    @State private var showConfetti = false
//
//    init(activity: Activity) {
//        self.activity = activity
//        _editHabitViewModel = StateObject(wrappedValue: EditHabitViewModel(activity: activity))
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Beautiful gradient background
//                LinearGradient(
//                    colors: [
//                        Color.cyan.opacity(0.15),
//                        Color.mint.opacity(0.1),
//                        Color.white.opacity(0.9)
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//
//                ScrollView(.vertical, showsIndicators: false) {
//                    VStack(spacing: 24) {
//                        // Handle bar for bottom sheet feel
//                        handleBar
//
//                        // Main content
//                        VStack(spacing: 20) {
//                            headerSection
//                            progressSection
//                            subtasksSection
//                        }
//                        .padding(.horizontal, 20)
//
//                        Spacer(minLength: 100)
//                    }
//                    .padding(.top, 8)
//                }
//
//                // Floating edit button
//                VStack {
//                    Spacer()
//                    editButton
//                        .padding(.bottom, 20)
//                }
//
//                // Confetti effect
//                if showConfetti {
//                    ConfettiView()
//                        .allowsHitTesting(false)
//                }
//            }
//        }
//        .onAppear {
//            refreshData()
//        }
//        // Add this to refresh when returning from edit view
//        .onChange(of: showEditHabit) {
//            if !showEditHabit {
//                // Refresh data when returning from edit view
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    refreshData()
//                }
//            }
//        }
//    }
//
//    // MARK: - Handle Bar
//    private var handleBar: some View {
//        RoundedRectangle(cornerRadius: 3)
//            .fill(Color.gray.opacity(0.3))
//            .frame(width: 40, height: 6)
//            .padding(.top, 8)
//    }
//
//    // MARK: - Header Section
//    private var headerSection: some View {
//        VStack(spacing: 16) {
//            // Activity icon and status
//            HStack(spacing: 16) {
//                // Activity image with gradient border
//                ZStack {
//                    Circle()
//                        .fill(
//                            LinearGradient(
//                                colors: activity.isCompleted ?
//                                    [.green.opacity(0.2), .mint.opacity(0.1)] :
//                                    [.orange.opacity(0.2), .yellow.opacity(0.1)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .frame(width: 70, height: 70)
//                        .overlay(
//                            Circle()
//                                .stroke(
//                                    LinearGradient(
//                                        colors: activity.isCompleted ? [.green, .mint] : [.orange, .yellow],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ),
//                                    lineWidth: 3
//                                )
//                        )
//
//                    imageForActivity(name: activity.name)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 35, height: 35)
//                        .clipShape(Circle())
//                }
//                .scaleEffect(animateCompletion ? 1.1 : 1.0)
//                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateCompletion)
//
//                // Activity details
//                VStack(alignment: .leading, spacing: 6) {
//                    statusBadge
//
//                    Text(activity.name)
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundStyle(.primary)
//                        .lineLimit(2)
//
//                    Text(activity.date.formatted(date: .abbreviated, time: .omitted))
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                }
//
//                Spacer()
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.ultraThinMaterial)
//                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
//        )
//    }
//
//    // MARK: - Status Badge
//    private var statusBadge: some View {
//        HStack(spacing: 6) {
//            Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "clock.circle.fill")
//                .font(.system(size: 14, weight: .semibold))
//
//            Text(activity.isCompleted ? "Completed" : "In Progress")
//                .font(.caption)
//                .fontWeight(.medium)
//        }
//        .foregroundStyle(activity.isCompleted ? .green : .orange)
//        .padding(.horizontal, 12)
//        .padding(.vertical, 6)
//        .background(
//            Capsule()
//                .fill(activity.isCompleted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
//        )
//    }
//
//    // MARK: - Progress Section
//    private var progressSection: some View {
//        VStack(spacing: 12) {
//            HStack {
//                Image(systemName: "chart.bar.fill")
//                    .font(.headline)
//                    .foregroundStyle(.mint)
//
//                Text("Progress")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//
//                Spacer()
//
//                if !activity.subtasks.isEmpty {
//                    Text("\(subtaskCompleted)/\(subtaskCount)")
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                        .foregroundStyle(.secondary)
//                }
//            }
//
//            if !activity.subtasks.isEmpty {
//                // Progress bar
//                GeometryReader { geometry in
//                    ZStack(alignment: .leading) {
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.gray.opacity(0.2))
//                            .frame(height: 12)
//
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(
//                                LinearGradient(
//                                    colors: [.mint, .cyan],
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .frame(
//                                width: geometry.size.width * (subtaskCount > 0 ? Double(subtaskCompleted) / Double(subtaskCount) : 0),
//                                height: 12
//                            )
//                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: subtaskCompleted)
//                    }
//                }
//                .frame(height: 12)
//
//                // Progress percentage
//                HStack {
//                    Spacer()
//                    Text("\(Int((Double(subtaskCompleted) / Double(max(subtaskCount, 1))) * 100))%")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .foregroundStyle(.mint)
//                }
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.ultraThinMaterial)
//                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
//        )
//    }
//
//    // MARK: - Fixed Subtasks Section
//    private var subtasksSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Image(systemName: "list.bullet.circle.fill")
//                    .font(.headline)
//                    .foregroundStyle(.cyan)
//
//                Text("Subtasks")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//
//                Spacer()
//            }
//
//            if !activity.subtasks.isEmpty {
//                LazyVStack(spacing: 12) {
//                    // Use ID-based ForEach instead of index-based
//                    ForEach(activity.subtasks, id: \.id) { subtask in
//                        subtaskRowSafe(for: subtask)
//                    }
//                }
//            } else {
//                emptySubtasksView
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.ultraThinMaterial)
//                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
//        )
//    }
//
//
//    // MARK: - Subtask Row
//    private func subtaskRowSafe(for task: Subtask) -> some View {
//        HStack(spacing: 12) {
//            // Checkbox button
//            Button {
//                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
//                    // Find the task in the array safely and toggle its completion
//                    if let index = activity.subtasks.firstIndex(where: { $0.id == task.id }) {
//                        let wasCompleted = activity.subtasks[index].isCompleted
//
//                        if !wasCompleted {
//                            activity.subtasks[index].isCompleted = true
//                            subtaskCompleted += 1
//                            checkAllSubtaskCompleted()
//
//                            // Trigger completion animation
//                            animateCompletion = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                animateCompletion = false
//                            }
//
//                            // Show confetti if all tasks completed
//                            if activity.isCompleted {
//                                showConfetti = true
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                    showConfetti = false
//                                }
//                            }
//                        }
//                    }
//                }
//            } label: {
//                ZStack {
//                    Circle()
//                        .fill(task.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
//                        .frame(width: 32, height: 32)
//                        .overlay(
//                            Circle()
//                                .stroke(
//                                    task.isCompleted ? Color.green : Color.gray.opacity(0.5),
//                                    lineWidth: 2
//                                )
//                        )
//
//                    if task.isCompleted {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 14, weight: .bold))
//                            .foregroundStyle(.green)
//                    }
//                }
//            }
//            .scaleEffect(task.isCompleted ? 1.1 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: task.isCompleted)
//
//            // Task name
//            Text(task.name)
//                .font(.body)
//                .fontWeight(.medium)
//                .foregroundStyle(task.isCompleted ? .secondary : .primary)
//                .strikethrough(task.isCompleted)
//                .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
//
//            Spacer()
//
//            // Completion indicator
//            if task.isCompleted {
//                Image(systemName: "checkmark.seal.fill")
//                    .font(.title3)
//                    .foregroundStyle(.green)
//                    .scaleEffect(0.8)
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(task.isCompleted ? Color.green.opacity(0.05) : Color.white.opacity(0.7))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(
//                            task.isCompleted ? Color.green.opacity(0.3) : Color.clear,
//                            lineWidth: 1
//                        )
//                )
//        )
//    }
//
//
//    // MARK: - Empty Subtasks View
//    private var emptySubtasksView: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "tray")
//                .font(.system(size: 32))
//                .foregroundStyle(.gray.opacity(0.6))
//
//            Text("No Subtasks")
//                .font(.body)
//                .fontWeight(.medium)
//                .foregroundStyle(.secondary)
//
//            Text("Add subtasks to break down your task into smaller steps")
//                .font(.caption)
//                .foregroundStyle(.tertiary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(.vertical, 20)
//    }
//
//    // MARK: - Edit Button
//    private var editButton: some View {
//        VStack {
//            NavigationLink(
//                destination: EditHabitView(viewModel: editHabitViewModel),
//                isActive: $showEditHabit,
//                label: { EmptyView() }
//            )
//            Button {
//                // Refresh view model before navigating - this ensures we have the latest data
//                refreshData()
//                showEditHabit = true
//            } label: {
//                HStack(spacing: 12) {
//                    Image(systemName: "pencil.circle.fill")
//                        .font(.system(size: 18, weight: .semibold))
//
//                    Text("Edit Task")
//                        .font(.body)
//                        .fontWeight(.semibold)
//                }
//                .foregroundStyle(.white)
//                .padding(.horizontal, 24)
//                .padding(.vertical, 16)
//                .background(
//                    LinearGradient(
//                        colors: [.mint, .cyan],
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    ),
//                    in: Capsule()
//                )
//                .shadow(color: .mint.opacity(0.4), radius: 10, x: 0, y: 5)
//            }
//            .scaleEffect(1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showEditHabit)
//        }
//        .padding(.horizontal, 20)
//    }
//
//    // MARK: - Helper Functions
//    func imageForActivity(name: String) -> Image {
//        if let _ = UIImage(named: name) {
//            return Image(name)
//        } else {
//            return Image("default")
//        }
//    }
//
//    // MARK: - Updated Helper Functions
//    private func refreshData() {
//        // Update subtask counts safely
//        subtaskCount = activity.subtasks.count
//        subtaskCompleted = activity.subtasks.filter { $0.isCompleted }.count
//
//        // Update view model with current activity data
//        editHabitViewModel.habitID = activity.id
//        editHabitViewModel.habitName = activity.name
//        editHabitViewModel.date = activity.date
//        editHabitViewModel.tempduration = activity.duration
//
//        // Create a copy of subtasks to avoid reference issues
//        editHabitViewModel.subtasks = activity.subtasks.map { originalSubtask in
//            Subtask(name: originalSubtask.name, isCompleted: originalSubtask.isCompleted)
//        }
//    }
//
//    private func checktaskCompleted(task: Subtask) {
//        // This function is no longer needed as we handle completion in the button action
//        // But keeping it for compatibility if used elsewhere
//        if task.isCompleted {
//            // Logic handled in button action now
//        }
//    }
//
//    private func checkAllSubtaskCompleted() {
//        if activity.subtasks.allSatisfy({ $0.isCompleted }) {
//            activity.isCompleted = true
//        }
//    }
//}
//// Preview
//#Preview {
//    let sampleActivity = Activity(
//        name: "Sample Habit",
//        date: .now,
//        duration: 30,
//        isCompleted: false,
//        subtasks: [
//            Subtask(name: "Drink water", isCompleted: false),
//            Subtask(name: "Meditate", isCompleted: false)
//        ]
//    )
//
//    BottomSheetEditView(activity: sampleActivity)
//}

