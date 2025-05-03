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
    
    // for animation when click the task
    @State private var pressedTaskID: UUID? = nil
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                if filteredActivities.isEmpty {
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
                                                .font(.system(size: 12))
                                            
                                        }else{
                                            Text("\(activity.date.displayTime)")
                                                .font(.system(size: 12))
                                                .strikethrough(activity.isCompleted,pattern: .solid, color: .black)
                                        }
                                    }
                                    
                                    if !activity.isCompleted{
                                        Text(activity.name)
                                            .fontWeight(.semibold)
                                            .font(.system(size: 15))
                                    }
                                    else{
                                        Text(activity.name)
                                            .fontWeight(.semibold)
                                            .font(.system(size: 15))
                                            .strikethrough(activity.isCompleted,pattern: .solid, color: .black)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    toggleCompleted(for: activity)
                                    onHabitCompleted?()
                                }) {
                                    Image(systemName: activity.isCompleted ? "checkmark.seal.fill" : "circle")
                                        .foregroundColor(activity.isCompleted ? .green : .gray)
                                        .font(.title)
                                }.buttonStyle(.borderless)
                                
                            }
                            .padding(22)
                            .background(activity.color.opacity(0.2))
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            .contentShape(Rectangle())
                            .scaleEffect(pressedTaskID == activity.id ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: pressedTaskID == activity.id)
                            .onLongPressGesture {
                                pressedTaskID = activity.id
                                passtheIDofHabit = activity.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    openAddHabit = true
                                    selectedHabitName = activity.name
                                    pressedTaskID = nil
                                }
                            }
                        }// HStack of the list instance
                        // Modifiers to perform on the overall instance at once
                        .onDelete(perform: deleteActivity)
                        
                    }// Section of the lists
                    
                }// List
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .padding(.top, -20)
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
                        .presentationDetents([.fraction(0.4), .medium])
                        .presentationDragIndicator(.hidden)
                } else {
                    Text("Activity not found.")
                }
            }
        }// NavigationStack
    }
    
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
    
    private func deleteActivity(at offsets: IndexSet) {
        for index in offsets {
            let activity = filteredActivities[index]
            // Cancel alarm for this activity
                AlarmManager.shared.stopAlarm(for: activity.id)
            
            // Cancel notifications for this specific activity
            notificationManager.cancelNotification(for: activity.id)
        
            modelContext.delete(activity)
        }
        do {
            try modelContext.save()
            print("Deleted and saved context") // Debugging statement
        } catch {
            print("Failed to save after deletion: \(error)")
        }
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Activity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = modelContainer.mainContext
    context.insert(Activity(name: "_____________", date: Date(), duration: 30, isCompleted: false))
    
    return ListView(selectedDate:.constant(Date()),showBronzeStar: .constant(true))
        .modelContainer(modelContainer)
}

