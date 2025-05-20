import SwiftUI

struct BottomSheetEditView: View {
      var activity: Activity
    @State private var showEditHabit = false
    @StateObject var addHabitViewModel = AddhabitViewModel()
    @StateObject var editHabitViewModel : EditHabitViewModel
    @State private var subtaskCount = 0
    @State private var subtaskCompleted = 0
    
    
    init(activity: Activity) {
           self.activity = activity
           _editHabitViewModel = StateObject(wrappedValue: EditHabitViewModel(activity: activity))
       }
    var body: some View {
        NavigationStack{
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.cyan.opacity(0.2))
                    .ignoresSafeArea()
                VStack{
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Top section
                        HStack {
                            imageForActivity(name: activity.name)
                                .resizable()
                                .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading) {
                                Text(activity.isCompleted ? "Completed" : "Not Completed")
                                    .font(.headline)
                                Text(activity.name)
                                    .font(.title3)
                            }
                        }.padding()
                        
                        Divider()
                        // Subtasks section
                        if !activity.subtasks.isEmpty{
                            VStack(spacing: 10) {
                                ForEach(activity.subtasks, id: \.self) { task in
                                    HStack{
                                        Text(task.name)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white.opacity(0.7))
                                            )
                                        Spacer()
                                        Button{
                                            if !task.isCompleted{
                                              task.isCompleted = true
                                             checkAllSubtaskCompleted()
                                            }
                                        }label: {
                                            Image(systemName: task.isCompleted ? "checkmark.seal.fill" : "circle")
                                                .font(.title2)
                                                .foregroundStyle(task.isCompleted ? .green : .black)
                                        }
                                    }
                                    .padding(5)
                                    .onChange(of: task.isCompleted){
                                        checktaskCompleted(task: task)
                                    }
                                }
                            }
                        }else{
                            Text("No Subtask")
                                .padding()
                        }
                    }
                    
                    Spacer()
                    // Edit button
                    NavigationLink(
                        destination:EditHabitView(viewModel: editHabitViewModel),
                        isActive: $showEditHabit,
                        label: { EmptyView() }
                    )
                    Button {
                        editHabitViewModel.habitID = activity.id
                        editHabitViewModel.habitName = activity.name
                        editHabitViewModel.date = activity.date
                        editHabitViewModel.subtasks = activity.subtasks
                        showEditHabit = true
                    } label: {
                        Text("Edit Task")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.6))
                            )
                            .foregroundStyle(.black)
                            .padding()
                    }
                
                }
                .onAppear {
                    subtaskCount = activity.subtasks.count
                    subtaskCompleted = activity.subtasks.filter { $0.isCompleted }.count
                }
            }
        }
    }
    func imageForActivity(name: String) -> Image {
          if let _ = UIImage(named: name) {
              return Image(name)
          } else {
              return Image("default") // your fallback image name
          }
      }
    func checktaskCompleted(task: Subtask) {
        if task.isCompleted{
           subtaskCompleted += 1
        }
    }
    func checkAllSubtaskCompleted(){
        if activity.subtasks.allSatisfy({ $0.isCompleted }) {
              activity.isCompleted = true
          }
    }
}

// Preview
#Preview {
    let sampleActivity = Activity(
        name: "Sample Habit",
        date: .now,
        duration: 30,
        isCompleted: false,
        subtasks: [
        Subtask(name: "Drink water", isCompleted: false),
        Subtask(name: "Meditate", isCompleted: false)
        ]
    )
    
    BottomSheetEditView(activity: sampleActivity)
}

