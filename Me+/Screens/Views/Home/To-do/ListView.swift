import SwiftUI
import SwiftData

struct ListView: View {
    @State private var showGraphicalCalendar = false
    @State private var dragOffset: CGFloat = 0
    @State private var currentWeekStart: Date = Calendar.current.startOfDay(for: Date()).startOfWeek()
    
    @Environment(\.dismiss) var dismiss
    @State private var showEditHabit = false
    @State private var openAddHabit = false
    @Environment(\.modelContext) var modelContext
    
    @State private var notificationManager = LocalNotificationManager()
    @State private var alarmManager = AlarmManager()
    
    @Binding var selectedDate: Date
    @Binding var showBronzeStar: Bool
    var onHabitCompleted: (() -> Void)? = nil
    
    @Query var activities: [Activity]
    
    @State private var passtheIDofHabit: UUID? = nil
    @State private var selectedHabitName: String = ""
    @State private var pressedTaskID: UUID? = nil
    let today = Calendar.current.startOfDay(for: Date())
    @State var subtaskDone: Bool = false
    @State var temptext: String = ""
    
    // Add reminder format the task in listview
    @State private var text: String = ""
    let impactfeebackgenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedbackgenerator = UINotificationFeedbackGenerator()
    let selectionFeedbackgenerator = UISelectionFeedbackGenerator()
    let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // Improved keyboard handling for different screen sizes
    @State private var keyboardHeight: CGFloat = 0
    @State private var safeAreaBottom: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    // Animation states - Fixed to prevent loops
    @State private var animateCompletion: UUID? = nil
    @State private var showCelebration = false
    @State private var newTaskAnimation: UUID? = nil
    @State private var backgroundGlow = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var animationTimer: Timer?
    
    // Celebration view states
    @State private var showTaskCelebration = false
    @State private var celebrationTaskName = ""
    @State private var isFirstTaskOfDay = false
    @State private var currentStreak = 1
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    // Helper to check if this is the first completed task of the day
    private var completedTasksToday: Int {
        filteredActivities.filter { $0.isCompleted }.count
    }
    
    // Computed property for adaptive bottom padding
    private var adaptiveBottomPadding: CGFloat {
        if keyboardHeight > 0 {
            // When keyboard is shown, position just above keyboard with some spacing
            return keyboardHeight + 16
        } else {
            // When keyboard is hidden, use safe area + some padding
            return max(safeAreaBottom + 25, 60)
        }
    }
    
    // Computed property for list bottom padding
    private var listBottomPadding: CGFloat {
        if keyboardHeight > 0 {
            return keyboardHeight + 80 // Extra space for the text field
        } else {
            return max(safeAreaBottom + 85, 120) // Adaptive to safe area
        }
    }
    
    // Helper to calculate current streak (you might want to implement actual streak logic)
    private func calculateStreak() -> Int {
        // This is a simplified version - implement your actual streak calculation
        let calendar = Calendar.current
        var streak = 0
        var currentDate = selectedDate
        
        // Count consecutive days with completed tasks going backwards
        while true {
            let tasksForDate = activities.filter {
                calendar.isDate($0.date, inSameDayAs: currentDate) && $0.isCompleted
            }
            
            if tasksForDate.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            
            // Limit to prevent infinite loop
            if streak > 365 { break }
        }
        
        return max(streak, 1)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    if filteredActivities.isEmpty {
                        PlaceholderView()
                            .scaleEffect(pulseScale)
                            .onAppear {
                                startPulseAnimation()
                            }
                            .onDisappear {
                                stopPulseAnimation()
                            }
                    }
                    
                    List {
                        Section {
                            ForEach(Array(filteredActivities.enumerated()), id: \.element.id) { index, activity in
                                ActivityRowView(
                                    activity: activity,
                                    index: index,
                                    isPressed: pressedTaskID == activity.id,
                                    isAnimatingCompletion: animateCompletion == activity.id,
                                    isNewTask: newTaskAnimation == activity.id,
                                    onTap: {
                                        handleActivityTap(activity)
                                    },
                                    onComplete: {
                                        handleActivityCompletion(activity, at: index)
                                    },selectedDate:$selectedDate,
                                    onDeleteSingle: {deleteSingleActivity(activity: activity)}
                                )
                                .swipeActions(edge: .trailing) {
                                    if !activity.isCompleted {
                                        SwipeActionsView(
                                            activity: activity,
                                            onDeleteSingle: { deleteSingleActivity(activity: activity) },
                                            onDeleteAll: { deleteAllFutureTasks(for: activity.baseID, from: activity.date) }
                                        )
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 2, leading: 15, bottom: 2, trailing: 15))
                            }
                        }
                        .padding(2)
                        .listSectionSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                    .scrollIndicators(.hidden)
                    .listStyle(PlainListStyle())
                    .environment(\.defaultMinListRowHeight, 0)
                    .padding(.top, -1)
                    .padding(.bottom, listBottomPadding)
                    
                    // Improved positioning for different screen sizes
                    VStack {
                        Spacer()
                        if selectedDate >= Calendar.current.startOfDay(for: Date()) {
                            AddTaskTextField(
                                text: $text,
                                isTextFieldFocused: $isTextFieldFocused,
                                onSubmit: handleAddTask
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, adaptiveBottomPadding)
                    .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
                }
                .onAppear {
                    // Get safe area bottom for this device
                    safeAreaBottom = geometry.safeAreaInsets.bottom
                }
            }
            .sheet(isPresented: $showEditHabit) {
                PreloadedTaskView(selectedDate: $selectedDate)
            }
            .sheet(isPresented: $openAddHabit) {
                if let selectedActivity = activities.first(where: { $0.id == passtheIDofHabit }) {
                    BottomSheetEditView(activity: selectedActivity)
                } else {
                    Text("Activity not found.")
                }
            }
            .fullScreenCover(isPresented: $showTaskCelebration) {
                TaskCompletionCelebrationView(
                    taskName: celebrationTaskName,
                    isFirstTaskOfDay: isFirstTaskOfDay,
                    currentStreak: currentStreak,
                    isPresented: $showTaskCelebration
                )
                .background(.clear)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            handleKeyboardShow(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            handleKeyboardHide()
        }
        .onAppear {
            setupInitialAnimations()
        }
        .onDisappear {
            cleanupAnimations()
        }
    }
    
    // MARK: - Animation Helper Functions
    private func startPulseAnimation() {
        pulseScale = 1.05
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }
    
    private func stopPulseAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            pulseScale = 1.0
        }
    }
    
    private func setupInitialAnimations() {
        backgroundGlow = true
    }
    
    private func cleanupAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
        backgroundGlow = false
    }
    
    // MARK: - Event Handlers
    
    private func handleActivityTap(_ activity: Activity) {
        lightImpactGenerator.impactOccurred()
        pressedTaskID = activity.id
        passtheIDofHabit = activity.id
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectionFeedbackgenerator.selectionChanged()
            openAddHabit = true
            selectedHabitName = activity.name
            pressedTaskID = nil
        }
    }
    
    private func handleActivityCompletion(_ activity: Activity, at index: Int) {
        lightImpactGenerator.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            animateCompletion = activity.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            heavyImpactGenerator.impactOccurred()
            
            // Check if this is the first task of the day before toggling
            let wasFirstTask = completedTasksToday == 0
            
            toggleCompleted(for: activity)
            onHabitCompleted?()
            
            // Prepare celebration data
            celebrationTaskName = activity.name
            isFirstTaskOfDay = wasFirstTask
            currentStreak = calculateStreak()
            
            // Show celebration after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showTaskCelebration = true
                animateCompletion = nil
            }
        }
    }
    
    private func handleAddTask() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        lightImpactGenerator.impactOccurred()
        selectionFeedbackgenerator.selectionChanged()
        
        let activity = Activity(name: trimmed, date: selectedDate, duration: 0, isCompleted: false)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            modelContext.insert(activity)
            
            // Trigger new task animation
            newTaskAnimation = activity.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                newTaskAnimation = nil
            }
            
            text = ""
        }
        isTextFieldFocused = false
    }
    
    private func handleKeyboardShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = keyboardFrame.height
            }
        }
    }
    
    private func handleKeyboardHide() {
        withAnimation(.easeInOut(duration: 0.3)) {
            keyboardHeight = 0
        }
    }
    
    // MARK: - Core Functions
    
    private func toggleCompleted(for activity: Activity) {
        activity.isCompleted = true
        if activity.subtasks.count > 0 {
            activity.subtasks.forEach { $0.isCompleted = true }
        }
        notificationManager.cancelNotification(for: activity.id)
        alarmManager.stopAlarm(for: activity.id)
        try? modelContext.save()
        
        // After toggling, check if any activities are completed
        DispatchQueue.main.async {
            showBronzeStar = activities.contains { $0.isCompleted }
        }
    }
    
    private func deleteSingleActivity(activity: Activity) {
        AlarmManager.shared.stopAlarm(for: activity.id)
        notificationManager.cancelNotification(for: activity.id)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            modelContext.delete(activity)
            do {
                try modelContext.save()
                print("Deleted and saved context")
            } catch {
                print("Failed to save after deletion: \(error)")
            }
        }
    }
    
    func deleteAllFutureTasks(for baseID: UUID?, from date: Date) {
        guard let baseID = baseID else {
            print("Cannot delete tasks with baseID")
            return
        }
        guard !activities.isEmpty else {
            print("No activities to delete.")
            return
        }
        let futureTasks = activities.filter {
            $0.baseID == baseID && $0.date >= date
        }
        guard !futureTasks.isEmpty else {
            print("No future tasks found for deletion.")
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            for task in futureTasks {
                alarmManager.stopAlarm(for: task.id)
                notificationManager.cancelNotification(for: task.id)
                modelContext.delete(task)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving after deletion: \(error)")
            }
        }
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Activity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = modelContainer.mainContext
    context.insert(Activity(name: "Sample Activity", date: Date(), duration: 0, isCompleted: false))
    
    return ListView(selectedDate: .constant(Date()), showBronzeStar: .constant(true))
        .modelContainer(modelContainer)
}
