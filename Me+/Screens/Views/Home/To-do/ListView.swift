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
    @State private var selectedHabitName : String = ""
    @State private var pressedTaskID: UUID? = nil
    let today = Calendar.current.startOfDay(for: Date())
    @State var subtaskDone : Bool = false
    @State var temptext: String = ""
    
    
    // Add reminder format the task in listview
    @State private var text: String = ""
    let impactfeebackgenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedbackgenerator = UINotificationFeedbackGenerator()
    let selectionFeedbackgenerator = UISelectionFeedbackGenerator()
    
    // Keyboard handling
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    var body: some View {
        NavigationStack{
            ZStack{
                if filteredActivities.isEmpty {
                    PlaceholderView()
                }
                List{
                    Section{
                        ForEach(filteredActivities, id: \.id) { activity in
                            HStack {
                                if let uiImage = UIImage(named: activity.name) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .scaledToFit()
                                } else {
                                    Image("default")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .scaledToFit()
                                }
                                VStack(alignment: .leading){
                                    if activity.isRescheduled{
                                        Text("Missed")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                    else{
                                        if !activity.subtasks.isEmpty{
                                            Text("\(activity.subtasks.count) subtasks" + (activity.isRepeating ? " • Repeating" : ""))
                                                .font(.system(size: 9))
                                        } else {
                                            Text("Anytime")
                                                .font(.system(size: 9))
                                                .strikethrough(activity.isCompleted,pattern: .solid, color: .black)
                                        }
                                    }
                                    
                                    if !activity.isCompleted{
                                        Text(activity.name)
                                            .fontWeight(.semibold)
                                            .font(.system(size: 14))
                                    }
                                    else{
                                        Text(activity.name)
                                            .fontWeight(.semibold)
                                            .strikethrough(activity.isCompleted,pattern: .solid, color: .black)
                                            .font(.system(size: 15))
                                    }
                                }
                                Spacer()
                                let isToday = Calendar.current.isDate(activity.date, inSameDayAs: Date())
                                
                                // Button to mark task as done...
                                Button(action: {
                                    impactfeebackgenerator.impactOccurred()
                                    toggleCompleted(for: activity)
                                    onHabitCompleted?()
                                }) {
                                    Image(systemName: activity.isCompleted ? "checkmark.seal.fill" : "circle")
                                        .foregroundColor(activity.isCompleted ? .green : .gray)
                                        .font(.title)
                                }
                                .buttonStyle(.borderless)
                                .disabled(!isToday)
                            }
                            .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 15))
                            .background(activity.color.opacity(0.2))
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            .contentShape(Rectangle())
                            .scaleEffect(pressedTaskID == activity.id ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: pressedTaskID == activity.id)
                            .onTapGesture{
                                pressedTaskID = activity.id
                                passtheIDofHabit = activity.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    selectionFeedbackgenerator.selectionChanged()
                                    openAddHabit = true
                                    selectedHabitName = activity.name
                                    pressedTaskID = nil
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                if !activity.isCompleted {
                                    if activity.isRepeating{
                                        Button {
                                            deleteAllFutureTasks(for: activity.baseID, from: activity.date)
                                        } label: {
                                            Text("Delete All")
                                        }
                                        .tint(.orange)
                                        Button{
                                            deleteSingleActivity(activity: activity)
                                        }label:{
                                            Text("Delete")
                                        }.tint(.red)
                                    }else{
                                        Button{
                                            deleteSingleActivity(activity: activity)
                                        }label:{
                                            Text("Delete")
                                        }.tint(.red)
                                    }
                                }
                            }
                            .listRowSeparator(.hidden) // Hide separator for this row
                            .listRowInsets(EdgeInsets(top: 2, leading: 15, bottom: 2, trailing: 15)) // Add some spacing between items
                        }// HStack
                        
                    }// Section of the lists
                    .padding(2)
                    .listSectionSeparator(.hidden) // Hide section separators
                }// List
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(PlainListStyle()) // Use PlainListStyle to help remove default styling
                .environment(\.defaultMinListRowHeight, 0) // Minimize default row height
                .padding(.top, -1)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 10 : 60) // Adjust based on keyboard
                
                VStack {
                    Spacer()
                    if selectedDate >= Calendar.current.startOfDay(for: Date()) {
                        HStack {
                            Spacer()
                            Button {
                                showEditHabit = true
                                selectionFeedbackgenerator.selectionChanged()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 55))
                                    .foregroundColor(.indigo)
                                    .shadow(radius: 4)
                            }
                            .padding(.trailing, 15)
                            .padding(.bottom, Calendar.current.isDateInToday(selectedDate) ? 5 : 0)
                            .animation(.default, value: selectedDate)
                        }
                    }
                    HStack{
                        if selectedDate >= Calendar.current.startOfDay(for: Date()) {
                            HStack {
                                TextField("Add Task", text: $text)
                                    .fontWeight(.bold)
                                    .focused($isTextFieldFocused)
                                    .onSubmit {
                                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !trimmed.isEmpty else { return }
                                        selectionFeedbackgenerator.selectionChanged()
                                        withAnimation{
                                            let activity = Activity(name: trimmed, date: Date.now, duration: 0, isCompleted: false)
                                            modelContext.insert(activity)
                                            text = ""
                                        }
                                        isTextFieldFocused = false // Dismiss keyboard after submission
                                    }
                            }
                            .padding(EdgeInsets(top: 10, leading: 50, bottom: 12, trailing: 10))
                            .foregroundColor(.black)
                            .background(
                                Color.gray.opacity(0.2),
                              in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                    }
                }
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 85 : 20)
                .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
                
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
        }// NavigationStack
        // Keyboard observers
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut) {
                keyboardHeight = 0
            }
        }
    }
    // Function to be called when task is completed ...
    private func toggleCompleted(for activity: Activity) {
        activity.isCompleted = true
        if activity.subtasks.count > 0{
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
    // Delete solo task...
    private func deleteSingleActivity(activity: Activity) {
        AlarmManager.shared.stopAlarm(for: activity.id)
        notificationManager.cancelNotification(for: activity.id)
        modelContext.delete(activity)
        do {
            try modelContext.save()
            print("Deleted and saved context") // Debugging statement
        } catch {
            print("Failed to save after deletion: \(error)")
        }
    }
    // Delete tasks that are created for repeat ...
    func deleteAllFutureTasks(for baseID: UUID?, from date: Date) {
        guard let baseID = baseID else {
            print("Cannot delete tasks with nil baseID")
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

#Preview {
    let modelContainer = try! ModelContainer(for: Activity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = modelContainer.mainContext
    context.insert(Activity(name: "_____________", date: Date(), duration: 0, isCompleted: false))
    
    return ListView(selectedDate:.constant(Date()),showBronzeStar: .constant(true))
        .modelContainer(modelContainer)
}
