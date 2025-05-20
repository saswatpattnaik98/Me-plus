import SwiftUI
import SwiftData

struct HomeView: View {
    // MARK: - Properties
        @Environment(\.modelContext) private var context
        
        // Streak related properties
        @AppStorage("streakCount") private var storedStreakCount: Int = 0
        @AppStorage("lastStreakUpdateDate") private var lastStreakUpdateDate: String = ""
        @AppStorage("lastCheckedDate") private var lastCheckedDate: String = ""
    @AppStorage("lastStreakResetCheckDate") private var lastStreakResetCheckDate: String = ""
    @AppStorage("streakResetToday") private var streakResetToday: Bool = false
    
        @State private var streaknumber: Int = 0

        // UI related properties
        @State private var showGraphicalCalendar = false
        @State private var dragOffset: CGFloat = 0
        @State private var currentWeekStart: Date = Calendar.current.startOfDay(for: Date()).startOfWeek()
        @State private var openManageTasks = false
        @State private var selectedDate: Date = Date()
        @State private var showBronzeStar: Bool = false
        @State private var streakView = false
    
        @Query var activities: [Activity]
        
    
    
func hasCompletedActivity(on date: Date) -> Bool {
        let calendar = Calendar.current
        return activities.contains { activity in
            calendar.isDate(activity.date, inSameDayAs: date) && activity.isCompleted
        }
    }
    
private var weeks: [[Date]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .weekOfYear, value: -2, to: today.startOfWeek())!
        let endDate = calendar.date(byAdding: .weekOfYear, value: 4, to: today.startOfWeek())!
        
        var weekDates: [[Date]] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let week = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: currentDate) }
            weekDates.append(week)
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        
        return weekDates
    }
    
    
    // Body Property
    var body: some View {
        ZStack(alignment: .top){
            Color(.systemBackground)
                    .ignoresSafeArea()
            VStack(spacing: 1) {
                ZStack(alignment: .top) {
                    Color.white.opacity(0.2)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 195)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.indigo.opacity(0.2))
                        )
                    VStack(spacing: 0) {
                        HStack {
                            Text(dateLabel(for: selectedDate))
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            // The Streak Button on Home screen
                            Button{
                                checkStreakResetIfNeeded()
                                streakView.toggle()
                                
                            }label: {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                        .font(.title2)
                                    Text("\(streaknumber)")
                                        .foregroundStyle(.black)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 60, height: 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                )
                            }
                            Menu {
                                Button {
                                    openManageTasks = true
                                } label: {
                                    Label("Manage my tasks", systemImage: "checkmark.square")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.top, 52) //space below notch
                        .padding(.horizontal)//Space so buttons wont feels away from the alignment
// Table view of the calendar in scroll ...
        TabView(selection: $currentWeekStart) {
                ForEach(weeks, id: \.[0]) { week in
                    HStack(spacing: 5) {
                            ForEach(week, id: \.self) { date in
                                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                        
                                        VStack(spacing: 4) {
                                            Text(dayOfWeek(from: date))
                                                .font(.caption)
                                                .foregroundColor(isSelected ? .black : .secondary)
                                                .fontWeight(isSelected ? .bold : .regular)
                                            
                                            let hasStreak = hasCompletedActivity(on: date)
                                            ZStack {
                                                let isToday = Calendar.current.isDateInToday(date)
                                                if hasStreak {
                                                    Image("streak")
                                                        .resizable()
                                                        .frame(width: 36, height: 36)
                                                } else {
                                                    if isToday{
                                                        Circle()
                                                            .fill(Color.white)
                                                            .frame(width: 36, height: 36)
                                                    } else {
                                                        Circle()
                                                            .fill(isSelected ? .white : Color.secondary.opacity(0.1))
                                                            .frame(width: 36, height: 36)
                                                    }
                                                    
                                                    Text(dayNumber(from: date))
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(isSelected ? .black : .gray)
                                                }
                                            }
                                            
                                        }
        
                                        .frame(width: 47, height: 71)
                                        // For that effect of light apprearance even when today is not selected
                                        .background(
                                            Group {
                                                let isToday = Calendar.current.isDateInToday(date)
                                                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

                                                if isSelected {
                                                    RoundedRectangle(cornerRadius: 58)
                                                        .fill(Color.purple.opacity(0.3))
                                                } else if isToday {
                                                    RoundedRectangle(cornerRadius: 58)
                                                        .fill(Color.purple.opacity(0.09)) // duller version for today
                                                } else {
                                                    Color.clear
                                                }
                                            }
                                        )
                                        .onTapGesture {
                                            selectedDate = date
                                        }
                                    }
                                }
                                .tag(week[0])
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 90)
                        
                        // Today Text or date text on upperright Corner of Homeview
                        HStack(spacing: 0){
                            Spacer()
                          //  Spacer()
                            VStack(spacing: 2) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.6))
                                    .frame(width: 24, height: 3)
                                Capsule()
                                    .fill(Color.gray.opacity(0.6))
                                    .frame(width: 24, height: 3)
                            }
                            .padding(8)
                            .background(Color.clear)
                            .offset(x:25)
                            Spacer()
                            
                            // This preserves layout even when the button is hidden
                            Group {
                                if !Calendar.current.isDateInToday(selectedDate) {
                                    Button {
                                        let today = Calendar.current.startOfDay(for: Date())
                                        selectedDate = today
                                        currentWeekStart = today.startOfWeek()
                                    } label: {
                                        Text("Today")
                                            .foregroundStyle(.black)
                                            .font(.footnote)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 3)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.black)
                                            )
                                    }
                                } else {
                                    // Empty view with same size as the button
                                    Text("Today")
                                        .font(.footnote)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 3)
                                        .opacity(0)
                                }
                            }
                        }

                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 30 {
                                    withAnimation(.easeInOut) {
                                        showGraphicalCalendar = true
                                    }
                                }
                            }
                    )
                }
                
                // List of Habits
                ListView(selectedDate: $selectedDate, showBronzeStar: $showBronzeStar, onHabitCompleted: {
                  onTaskCompleted()
                })
            }
            // Modifier to update the schdeduled task
            .onAppear {
                checkAndCarryOverTasksIfNeeded(context: context)
                initializeStreakState()
            }
            
            
            // Graphical Calendar Overlay ------------
            if showGraphicalCalendar {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showGraphicalCalendar = false
                        }
                    }
                
                VStack(spacing: 12) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .scaleEffect(0.9)
                        .padding()
                }
                .frame(width: 380)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .padding(.top, 60)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            withAnimation(.easeInOut) {
                                if value.translation.height < -30 {
                                    withAnimation{
                                        showGraphicalCalendar = false
                                    }
                                }
                                dragOffset = 0
                            }
                        }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }// if conditon showCalendar
        }// ZStack
        
        .sheet(isPresented: $openManageTasks){
            ManageTasks()
        }
        .sheet(isPresented: $streakView){
            StreakExpandView(streakCount: $streaknumber)
        }
    }// body
    
private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    // These are the functions for rescheduling
    
private func carryOverUncompletedActivities(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())

        let fetchDescriptor = FetchDescriptor<Activity>(
            predicate: #Predicate { activity in
                activity.isCompleted == false && activity.date < today
            }
        )

        if let oldActivities = try? context.fetch(fetchDescriptor) {
            for activity in oldActivities {
                let newActivity = Activity(
                    name : activity.name,
                    date: today,
                    duration: 0,
                    isCompleted: false,
                    isRescheduled: true
                )
                context.insert(newActivity)
            }
        }
    }

private func checkAndCarryOverTasksIfNeeded(context: ModelContext) {
        let todayString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        
        if todayString != lastCheckedDate {
            carryOverUncompletedActivities(context: context)
            lastCheckedDate = todayString
        }
    }
    func initializeStreakState() {
           // Load stored streak and update the UI
           streaknumber = storedStreakCount
           
           // Check if we need to reset the streak (no activity completed yesterday)
           checkStreakResetIfNeeded()
       }
    
    func checkStreakResetIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayString = DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none)
        
        // Only run this check once per day, using a dedicated tracking variable
        if todayString != lastStreakResetCheckDate {
            print("Running streak reset check for \(todayString)")
            
            // Get yesterday's date
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            
            // Check if any activity was completed yesterday
            let completedYesterday = activities.contains { activity in
                calendar.isDate(activity.date, inSameDayAs: yesterday) && activity.isCompleted
            }
            
            // If streak is > 0 and no activity was completed yesterday, reset streak
            if storedStreakCount > 0 && !completedYesterday {
                print("Streak reset: No activity completed yesterday")
                storedStreakCount = 0
                streaknumber = 0
                // Mark that streak was reset today so we can increment it when task is completed
                streakResetToday = true
            } else {
                streakResetToday = false
            }
            lastStreakResetCheckDate = todayString
        }
    }
    // Call this when a task is marked as completed
    func onTaskCompleted() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Count completed tasks for today
        let completedTasksToday = activities.filter { activity in
            calendar.isDate(activity.date, inSameDayAs: today) && activity.isCompleted
        }.count
        
        // If this is the first completed task of the day, update streak
        if completedTasksToday == 1 {
            checkAndUpdateStreakOnFirstCompletion()
        }
    }
    
    // Update streak when first activity is completed in a day
    func checkAndUpdateStreakOnFirstCompletion() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayString = DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none)

        // Check if we already updated streak for today
        if todayString != lastStreakUpdateDate {
            // Increment streak and update last update date
            storedStreakCount += 1
            lastStreakUpdateDate = todayString
            streaknumber = storedStreakCount
            
            // If streak was reset today, we need to clear the flag since we've now
            // successfully started a new streak
            if streakResetToday {
                streakResetToday = false
            }
            
            print("Streak incremented to: \(streaknumber)")
        }
    }
}
extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}
extension Date {
    var displayTime: String {
        self.formatted(.dateTime.hour().minute())
    }
}

#Preview {
    HomeView()
}

