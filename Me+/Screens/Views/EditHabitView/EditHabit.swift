import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: EditHabitViewModel

    var body: some View {
        
        Form {
            Section(header: Text("Habit Info")) {
                TextField("Habit Name", text: $viewModel.habitName)
                DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                Stepper(value: $viewModel.tempduration, in: 1...180) {
                    Text("Duration: \(viewModel.tempduration) min")
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

            Section(header: Text("Reminder")) {
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

            Button("Save Changes") {
                viewModel.updateActivity(in: context)
                dismiss()
            }
        }
        .navigationTitle("Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EditHabitView(viewModel: EditHabitViewModel(activity: Activity(name: "Preview", date: Date.now, duration: 0)))
        .environmentObject(AlarmManager.shared)
}
