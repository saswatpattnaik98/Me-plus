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
    @State private var hasInitialized: Bool = false // Prevent multiple initializations
    
    // UI related properties
    @State private var showGraphicalCalendar = false
    @State private var dragOffset: CGFloat = 0
    @State private var currentWeekStart: Date = Calendar.current.startOfDay(for: Date()).startOfWeek()
    @State private var selectedDate: Date = Date()
    @State private var showBronzeStar: Bool = false
    @State private var streakView = false
    
    // Cache the weeks to avoid recalculation
    @State private var cachedWeeks: [[Date]] = []
    @State private var lastWeekCalculationDate: Date = Date()
    
    @Query var activities: [Activity]
    let notificationfeedbackgenerator = UINotificationFeedbackGenerator()
    
    func hasCompletedActivity(on date: Date) -> Bool {
        let calendar = Calendar.current
        return activities.contains { activity in
            calendar.isDate(activity.date, inSameDayAs: date) && activity.isCompleted
        }
    }
    
    // Cached weeks computation
    private func calculateWeeks() -> [[Date]] {
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
    
    // Update cached weeks when needed
    private func updateWeeksIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Only recalculate if date has changed or cache is empty
        if cachedWeeks.isEmpty || !calendar.isDate(lastWeekCalculationDate, inSameDayAs: today) {
            cachedWeeks = calculateWeeks()
            lastWeekCalculationDate = today
        }
    }
    
    // Body Property
    var body: some View {
        ZStack(alignment: .top){
          //  Color(.systemBackground)
            //    .ignoresSafeArea()
            VStack(spacing: 1) {
                ZStack(alignment: .top) {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 195)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                    VStack(spacing: 0) {
                        HStack {
                            Text(dateLabel(for: selectedDate))
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            // The Streak Button on Home screen
                            Button{
                                // Only check streak reset when user manually opens streak view
                                if !hasInitialized {
                                    checkStreakResetIfNeeded()
                                }
                                streakView.toggle()
                            }label: {
                                HStack {
                                    Image("flame")
                                        .resizable()
                                        .frame(width: 30,height: 30)
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
                        }
                        .padding(.top, 52)
                        .padding(.horizontal)
                        
                        // Table view of the calendar in scroll with week navigation
                        TabView(selection: $currentWeekStart) {
                            ForEach(cachedWeeks, id: \.[0]) { week in
                                WeekRowView(
                                    week: week,
                                    selectedDate: $selectedDate,
                                    hasCompletedActivity: hasCompletedActivity
                                )
                                .tag(week[0])
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 90)
                        .onChange(of: currentWeekStart) { oldWeek, newWeek in
                            // When user swipes to change week, update selectedDate to same day of week
                            updateSelectedDateForNewWeek(oldWeek: oldWeek, newWeek: newWeek)
                        }
                        
                        // Today Text or date text on upperright Corner of Homeview
                        HStack(spacing: 0){
                            Spacer()
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
                                if !Calendar.current.isDateInToday(selectedDate){
                                    Button {
                                        let today = Calendar.current.startOfDay(for: Date())
                                        withAnimation{
                                            selectedDate = today
                                            currentWeekStart = today.startOfWeek()
                                        }
                                    } label: {
                                        Text("Today")
                                            .foregroundStyle(.gray)
                                            .font(.footnote)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 3)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.gray)
                                            )
                                    }
                                } else {
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
                                // Only handle vertical drag for calendar
                                if abs(value.translation.height) > abs(value.translation.width) && value.translation.height > 30 {
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
            // Modified onAppear to prevent loops
            .onAppear {
                // Only run initialization once
                if !hasInitialized {
                    updateWeeksIfNeeded()
                    performInitialSetup()
                    hasInitialized = true
                }
            }
            .onChange(of: selectedDate) { _, _ in
                // Update weeks when date changes significantly
                updateWeeksIfNeeded()
            }
            
            // Graphical Calendar Overlay
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
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.black))
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
            }
        }
        .sheet(isPresented: $streakView){
            StreakExpandView(streakCount: $streaknumber)
        }
    }
    
    // MARK: - Helper Functions
    private func performInitialSetup() {
        // Run all initialization tasks once
        checkAndCarryOverTasksIfNeeded(context: context)
        initializeStreakState()
    }
    
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
    
    // Updated carry-over function in HomeView
    private func carryOverUncompletedActivities(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get all uncompleted activities from yesterday and before
        let fetchDescriptor = FetchDescriptor<Activity>(
            predicate: #Predicate { activity in
                activity.isCompleted == false &&
                activity.isRescheduled == false &&
                activity.date < today
            }
        )
        
        if let oldActivities = try? context.fetch(fetchDescriptor) {
            // Group activities by name or baseID to avoid duplicates
            var uniqueActivities: [String: Activity] = [:]
            
            for activity in oldActivities {
                let key = activity.baseID?.uuidString ?? activity.name
                
                // Keep the most recent version of each unique task
                if let existingActivity = uniqueActivities[key] {
                    if activity.date > existingActivity.date {
                        uniqueActivities[key] = activity
                    }
                } else {
                    uniqueActivities[key] = activity
                }
            }
            
            // Create new activities for today from unique tasks
            for (_, activity) in uniqueActivities {
                let newActivity = Activity(
                    name: activity.name,
                    date: today,
                    duration: activity.duration,
                    isCompleted: false,
                    isRescheduled: true
                )
                
                // Copy baseID if it exists
                if let baseID = activity.baseID {
                    newActivity.baseID = baseID
                }
                
                // Copy subtasks if any
                if !activity.subtasks.isEmpty {
                    for subtask in activity.subtasks {
                        let newSubtask = Subtask(
                            name: subtask.name,
                            isCompleted: false
                        )
                        newActivity.subtasks.append(newSubtask)
                    }
                }
                
                context.insert(newActivity)
            }
            
            // Mark all old activities as rescheduled instead of deleting
            for activity in oldActivities {
                activity.isRescheduled = true
            }
            
            try? context.save()
        }
    }
    
    private func checkAndCarryOverTasksIfNeeded(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayString = DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none)
        
        if todayString != lastCheckedDate {
            carryOverUncompletedActivities(context: context)
            lastCheckedDate = todayString
        }
    }
    
    // MARK: - Streak Management Functions
    func initializeStreakState() {
        streaknumber = storedStreakCount
        checkStreakResetIfNeeded()
    }
    
    func checkStreakResetIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayString = DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none)
        
        // Prevent multiple checks per day
        guard todayString != lastStreakResetCheckDate else { return }
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let completedYesterday = activities.contains { activity in
            calendar.isDate(activity.date, inSameDayAs: yesterday) && activity.isCompleted
        }
        
        if storedStreakCount > 0 && !completedYesterday {
            storedStreakCount = 0
            streaknumber = 0
            streakResetToday = true
        } else {
            streakResetToday = false
        }
        lastStreakResetCheckDate = todayString
    }
    
    func onTaskCompleted() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let completedTasksToday = activities.filter { activity in
            calendar.isDate(activity.date, inSameDayAs: today) && activity.isCompleted
        }.count
        
        if completedTasksToday == 1 {
            checkAndUpdateStreakOnFirstCompletion()
        }
    }
    
    func checkAndUpdateStreakOnFirstCompletion(){
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayString = DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none)
        
        guard todayString != lastStreakUpdateDate else { return }
        
        storedStreakCount += 1
        lastStreakUpdateDate = todayString
        streaknumber = storedStreakCount
        
        if streakResetToday {
            streakResetToday = false
        }
        
        notificationfeedbackgenerator.notificationOccurred(.success)
    }
    
    // MARK: - Navigation Functions
    private func updateSelectedDateForNewWeek(oldWeek: Date, newWeek: Date) {
        let calendar = Calendar.current
        
        // Get the day of week of the currently selected date
        let dayOfWeek = calendar.component(.weekday, from: selectedDate)
        
        // Find the corresponding day in the new week
        if let newSelectedDate = calendar.dateInterval(of: .weekOfYear, for: newWeek)?.start {
            // Calculate the same day of week in the new week
            let daysToAdd = dayOfWeek - 1 // weekday is 1-based, we need 0-based
            if let updatedDate = calendar.date(byAdding: .day, value: daysToAdd, to: newSelectedDate) {
                selectedDate = updatedDate
            }
        }
    }
    
    private func navigateWeek(direction: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: direction, to: selectedDate) {
            selectedDate = newDate
            currentWeekStart = newDate.startOfWeek()
        }
    }
}

// MARK: - Separate Week Row Component
struct WeekRowView: View {
    let week: [Date]
    @Binding var selectedDate: Date
    let hasCompletedActivity: (Date) -> Bool
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(week, id: \.self) { date in
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                
                VStack(spacing: 4) {
                    Text(dayOfWeek(from: date))
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : .secondary)
                        .fontWeight(isSelected ? .bold : .regular)
                    
                    let hasStreak = hasCompletedActivity(date)
                    ZStack {
                        let isToday = Calendar.current.isDateInToday(date)
                        if hasStreak {
                            Image("flame")
                                .resizable()
                                .frame(width: 36, height: 36)
                        } else {
                            if isToday{
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 36, height: 36)
                            } else {
                                Circle()
                                    .fill(isSelected ? .gray.opacity(0.1) : Color.secondary.opacity(0.1))
                                   // .stroke(Color.white)
                                    .frame(width: 36, height: 36)
                            }
                            
                            Text(dayNumber(from: date))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(isSelected ? .white : .gray)
                        }
                    }
                }
                .frame(width: 47, height: 71)
                .background(
                    Group {
                        let isToday = Calendar.current.isDateInToday(date)
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        
                        if isSelected {
                            RoundedRectangle(cornerRadius: 58)
                                .fill(Color.indigo.opacity(0.3))
                        } else if isToday {
                            RoundedRectangle(cornerRadius: 58)
                                .fill(Color.indigo.opacity(0.09))
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
}

// MARK: - Extensions
extension Date {
    var displayTime: String {
        self.formatted(.dateTime.hour().minute())
    }
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.light)
}
