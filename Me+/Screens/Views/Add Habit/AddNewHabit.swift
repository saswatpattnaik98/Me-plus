import SwiftUI
import SwiftData
import UserNotifications

// Only the repeat task part is not working except that all is perfectly good.
struct AddNewHabit: View {
    
    @ObservedObject var addHabitViewModel: AddhabitViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query private var activities: [Activity]
    @EnvironmentObject var alarmManager: AlarmManager
    
    var isValid: Bool {
        !addHabitViewModel.habitName.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                addHabitViewModel.selectedColor
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    VStack {
                        if let uiImage = UIImage(named: addHabitViewModel.habitName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .scaledToFit()
                        } else {
                            Image("default")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .scaledToFit()
                        }
                        TextField("New Task", text: $addHabitViewModel.habitName)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.none)
                    }
                    
                    ColorPaletteView(selectedColor: $addHabitViewModel.selectedColor)
                    
                    Spacer()
                    
                    formInputs
                    
                    // Subtask
                    VStack(spacing: 8) {
                        ForEach(addHabitViewModel.subtasks, id: \.id) { subtask in
                            HStack {
                                Text(subtask.name)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            .padding(10)
                            .frame(width: 360, height: 40)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.7)))
                            
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            TextField("Subtask", text: $addHabitViewModel.subtaskName)
                                .onSubmit {
                                    addHabitViewModel.addSubtask()
                                }
                        }
                        .padding(12)
                        .frame(width: 360, height: 50)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.7)))
                    }

                    Spacer()
                }
            }
            .onAppear {
                AddhabitViewModel.notificationManager.requestPermission() // Ask for permission on first open
            }
            .toolbar {
                Button {
                    let newactivity = Activity(name: addHabitViewModel.habitName, date: addHabitViewModel.date, duration: addHabitViewModel.tempduration, isCompleted: false, subtasks: addHabitViewModel.subtasks)
                    modelContext.insert(newactivity)
                    
                    if let combinedDate = addHabitViewModel.combineDateAndTime(date: addHabitViewModel.date, time: addHabitViewModel.time) {
                        if addHabitViewModel.reminderType == "Alarm" {
                            addHabitViewModel.scheduleAlarm(for: combinedDate)
                        } else if addHabitViewModel.reminderType == "Notification" {
                            addHabitViewModel.scheduleNotification(for: combinedDate)
                        }
                    }
                    dismiss()
                    dismiss()
                } label: {
                    Text("Create")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                }
            }
        }
    }
    
    var formInputs: some View {
        VStack(spacing: 3) {
            NavigationLink(destination: EditDateAddedView(date: $addHabitViewModel.date)) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar").fontWeight(.bold)
                    Text("Date")
                    Spacer()
                    Text("\(addHabitViewModel.date.displayDate)")
                    Image(systemName:"chevron.right")
                }
                .foregroundStyle(Color.black)
                .padding(15)
            }
            
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            
            HStack(spacing: 12) {
                Image(systemName: "clock")
                Text("Time")
                Spacer()
                if addHabitViewModel.periodTime {
                    Text("\(addHabitViewModel.time.formatted(date: .omitted, time: .shortened)) - \(addHabitViewModel.endTime.formatted(date: .omitted, time: .shortened))")
                } else {
                    Text("\(addHabitViewModel.time.formatted(date: .omitted, time: .shortened))")
                }
                Button{
                    withAnimation{
                        addHabitViewModel.showEditTime.toggle()
                    }
                }label: {
                    Image(systemName:"chevron.right")
                        .foregroundStyle(Color.black)
                }
            }
            .padding(15)
            
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            
            HStack(spacing: 12) {
                Image(systemName: "repeat.circle").fontWeight(.bold)
                Text("Repeat")
                Spacer()
                Text("\(addHabitViewModel.selectedRepeat)")
                Button{
                   // $addHabitViewModel.showRepeatPicker.toggle
                    // Make some changes here it is not functioning
                }label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black)
                }
            }
            .padding(15)
            
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            HStack(spacing: 12) {
                Image(systemName: "calendar.day.timeline.left").fontWeight(.bold)
                Text("Reminder")
                Spacer()
                Picker("", selection: $addHabitViewModel.reminderType) {
                    ForEach(addHabitViewModel.ReminderType, id: \.self) {
                        Text($0).tag($0)
                    }
                }
            }
            .padding(15)
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                Text("Remind me @")
                Spacer()
                Picker("", selection: $addHabitViewModel.reminderTime) {
                    ForEach(ReminderOffset.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
            .padding(15)
        }
        .frame(width: 360, height:  340)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.7)))
        .sheet(isPresented: $addHabitViewModel.showEditTime){
            EditTimeView(time1: $addHabitViewModel.time, time2: $addHabitViewModel.endTime, showTimePicker: $addHabitViewModel.showTimePicker, periodTime : $addHabitViewModel.periodTime)
        }
//        .sheet(isPresented: $addHabitViewModel.showRepeatPicker){
//            RepeatBottomSelect(selectedRepeat: $addHabitViewModel.selectedRepeat, endDate: $addHabitViewModel.date)
//            .presentationDetents([.fraction(0.5), .medium])
//            .presentationDragIndicator(.hidden)
//        }
    }
}

extension Date {
    var displayDate: String {
        self.formatted(.dateTime.day().month(.wide).year())
    }
}
#Preview {
    AddNewHabit(addHabitViewModel: AddhabitViewModel())
        .environmentObject(AlarmManager.shared)
}
