import SwiftUI
import SwiftData

struct ManageTasks: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Activity.date) var activities: [Activity]  // Sorted by date
    @State private var searchtext: String = ""
    @State private var sortOption: SortOption = .today

    // Enum to represent different sorting options
    enum SortOption: String, CaseIterable, Identifiable {
        case all = "All Tasks"
        case today = "Today"
        case tomorrow = "Tomorrow"
        case upcoming = "Upcoming"
        
        var id: String { self.rawValue }
    }

    var filteredActivities: [Activity] {
        // First filter by searchtext
        let searchFiltered = activities.filter { activity in
            searchtext.isEmpty || activity.name.lowercased().contains(searchtext.lowercased())
        }
        
        // Then filter based on the selected sort option
        switch sortOption {
        case .today:
            return searchFiltered.filter { Calendar.current.isDateInToday($0.date) }
        case .tomorrow:
            return searchFiltered.filter { Calendar.current.isDateInTomorrow($0.date) }
        case .upcoming:
            return searchFiltered.filter { $0.date > Date() }
        case .all:
            return searchFiltered
        }
    }

    var body: some View {
        NavigationStack {
            VStack{
                HStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                    TextField("Search for task name", text: $searchtext)
                        .padding(8)
                }
                //.padding(8)
                .frame(width: 318, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()
            List {
                ForEach(filteredActivities) { activity in
                    HStack {
                        Image("\(activity.name)") // Replace with an appropriate image if needed
                            .resizable()
                            .frame(width: 25, height: 30)
                        VStack(alignment: .leading) {
                            if activity.isCompleted {
                                Text("\(activity.date.displayDate)")
                                    .font(.system(size: 10))
                            }else{
                              Text("Not completed")
                                    .font(.system(size: 10))
                            }
                            Text("\(activity.name)")
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(activity.color.opacity(0.4))
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 19))
                }
                .onDelete(perform: deleteActivity)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("Manage Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button(option.rawValue) {
                                sortOption = option
                            }
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
    }

    private func deleteActivity(at offsets: IndexSet) {
        for index in offsets {
            let activity = activities[index]
            modelContext.delete(activity)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Activity.self, configurations: config)

    let sampleActivity = Activity(name: "Test Task", date: .now, duration: 30, isCompleted: false)
    container.mainContext.insert(sampleActivity)

    return ManageTasks()
        .modelContainer(container)
}

