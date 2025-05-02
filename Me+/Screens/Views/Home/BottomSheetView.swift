import SwiftUI

struct BottomSheetEditView: View {
      var activity: Activity
    @State private var showEditHabit = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.cyan.opacity(0.2))
                .ignoresSafeArea()
            VStack{
            VStack(alignment: .leading, spacing: 20) {
                
                // Top section
                HStack {
                    Image(activity.name.isEmpty ? "defaultImage" : activity.name)
                        .resizable()
                        .frame(width: 60, height: 60)
                    
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
                                        task.isCompleted.toggle()
                                    }label: {
                                        Image(systemName: task.isCompleted ? "checkmark.seal.fill" : "circle")
                                            .font(.title2)
                                            .foregroundStyle(task.isCompleted ? .green : .black)
                                    }
                                }
                            }
                        }
                }else{
                    Text("No Subtask")
                }
                
               // Spacer()
            }
                
                // Here is the error
                
//            .sheet(isPresented: $showEditHabit) {
//                AddNewHabit(
//                    habitName: activity.name,
//            // You must match what AddNewHabit expects!
//                )
//            }
            Spacer()
                VStack{
                    // Edit button
                    Button("Edit Task") {
                        showEditHabit = true
                    }
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

