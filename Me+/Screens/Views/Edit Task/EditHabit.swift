import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: EditHabitViewModel
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.green.opacity(0.4)
                    .ignoresSafeArea()
                
              oldUI
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button{
                    viewModel.updateActivity(in: context)
                    dismiss()
                }label:{
                    Text("Save")
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    var oldUI: some View {
        Form {
            Section(header: Text("Habit Info")) {
                TextField("Habit Name", text: $viewModel.habitName)
            }
            
            
            Section(header: Text("Reminder")) {
                
                DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                
                Picker("Reminder Type", selection: $viewModel.reminderType) {
                    ForEach(viewModel.ReminderType, id: \.self) { type in
                        Text(type)
                    }
                }
                if viewModel.reminderType != "No reminder" {
                    DatePicker("Time", selection: $viewModel.time, displayedComponents: .hourAndMinute)
                }
                Picker("Repeat", selection: $viewModel.selectedRepeat) {
                    ForEach(RepeatOption.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                    }
                }
            }
            
            Section(header: Text("Subtasks")) {
                ForEach(viewModel.subtasks.indices, id: \.self) { index in
                    HStack {
                        TextField("Subtask", text: Binding(
                            get: { viewModel.subtasks[index].name },
                            set: { viewModel.subtasks[index].name = $0 }
                        ))
                        Spacer()
                        if viewModel.subtasks.count > 1 {
                            Button(role: .destructive) {
                                viewModel.subtasks.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                        }
                    }
                }
                HStack {
                    TextField("New subtask", text: $viewModel.subtaskName)
                    Button(action: viewModel.addSubtask) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            
        }
        .scrollContentBackground(.hidden)
    }
    var formInputs: some View {
        VStack(spacing: 5) {
            NavigationLink(destination: EditDateAddedView(date: $viewModel.date)) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Date")
                    Spacer()
                    Text("\(viewModel.date.displayDate)")
                    Image(systemName:"chevron.right")
                }
                .foregroundStyle(Color.black)
                
            }
            .padding(15)
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.headline)
                Text("Time")
                Button{
                  // here we are going to time selector view
                }label: {
                    Image(systemName:"chevron.right")
                        .foregroundStyle(Color.black)
                }
            }
            .padding(15)
            
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            
            HStack(spacing: 12) {
                Image(systemName: "repeat.circle")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Repeat")
                Spacer()
                Text("\(viewModel.selectedRepeat)")
            }
            .padding(15)
            
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
            
            HStack(spacing: 12) {
                Image(systemName: "calendar.day.timeline.left")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Reminder")
                Spacer()
                Picker("", selection: $viewModel.reminderType) {
                    ForEach(viewModel.ReminderType, id: \.self) {
                        Text($0).tag($0)
                    }.foregroundStyle(.black)
                }
            }
            .padding(10)
            
            Divider().frame(width: 300, height: 0.5).background(Color.gray.opacity(0.5))
        }
        .frame(width: 360, height:  330)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.7)))
    }
}

#Preview {
    EditHabitView(viewModel: EditHabitViewModel(activity: Activity(name: "Preview", date: Date.now, duration: 0)))
        .environmentObject(AlarmManager.shared)
}
