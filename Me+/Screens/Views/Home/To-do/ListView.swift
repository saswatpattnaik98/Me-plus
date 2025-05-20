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
    
    
    // Add reminder format the task in listview
    @State private var text: String = ""
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                if filteredActivities.isEmpty {
                    // Placeholder when no task added ...
                    VStack(spacing: 12) {
                        Image("noHabits") // Make sure "noHabits" exists in Assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .opacity(0.8)
                        
                        Text("Top athletes follow 'Top Heaviness'")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Text("1.⁠ ⁠More on Mon, Tue, Wed\n2.⁠ ⁠More in morning than evening\n3.⁠ ⁠⁠Definitely set time for rest")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding()
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
                                        Text("Missed from yesterday")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .italic()
                                    }
                                    else{
                                        if !activity.subtasks.isEmpty{
                                            Text("\(activity.subtasks.count) subtasks ")
                                                .font(.system(size: 9))
                                            
                                        }else{
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
                                            .font(.system(size: 12))
                                            .strikethrough(activity.isCompleted,pattern: .solid, color: .black)
                                    }
                                }
                                Spacer()
                                let isToday = Calendar.current.isDate(activity.date, inSameDayAs: Date())
                                
                                // Button to mark task as done...
                                Button(action: {
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
                            .padding(22)
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
                                    openAddHabit = true
                                    selectedHabitName = activity.name
                                    pressedTaskID = nil
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                if !activity.isCompleted {
                                    Button {
                                        deleteAllFutureTasks(for: activity.baseID, from: activity.date)
                                    } label: {
                                        Label("Delete All", systemImage: "trash.slash")
                                    }
                                    .tint(.orange)
                                    Button{
                                        deleteSingleActivity(activity: activity)
                                    }label:{
                                        Label("Delete",systemImage:"trash")
                                    }.tint(.red)
                                }
                            }
                            .listRowSeparator(.hidden) // Hide separator for this row
                            .listRowInsets(EdgeInsets(top: 3, leading: 35, bottom: 3, trailing: 35)) // Add some spacing between items
                        }// HStack
                        if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                            HStack {
                                VStack {
                                    TextField("Add Task", text: $text)
                                        .onSubmit {
                                            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                                            guard !trimmed.isEmpty else { return }

                                            let activity = Activity(name: trimmed, date: Date.now, duration: 0, isCompleted: false)
                                            modelContext.insert(activity)
                                            text = ""
                                        }
                                }

                                Image(systemName: "circle.dotted")
                            }
                            .padding(EdgeInsets(top: 15, leading: 50, bottom: 15, trailing: 26))
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .listRowInsets(EdgeInsets(top: 1, leading: 35, bottom: 1, trailing: 35))
                           // .listRowSeparator(.hidden)
                           // .listRowBackground(Color.clear)
                        }
                    }// Section of the lists
                    .listSectionSeparator(.hidden) // Hide section separators
                }// List
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle()) // Use PlainListStyle to help remove default styling
                .environment(\.defaultMinListRowHeight, 0) // Minimize default row height
                .padding(.top, -1)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button {
                            showEditHabit = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50, weight: .thin))
                                .foregroundColor(.indigo)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditHabit) {
                PreloadedTaskView()
            }
            .sheet(isPresented: $openAddHabit) {
                if let selectedActivity = activities.first(where: { $0.id == passtheIDofHabit }) {
                    BottomSheetEditView(activity: selectedActivity)

                } else {
                    Text("Activity not found.")
                }
            }
        }// NavigationStack
    }
    // Function to be called when task is completed ...
    private func toggleCompleted(for activity: Activity) {
        activity.isCompleted = true
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
