import SwiftUI

struct StreakCalendarView: View {
    @State private var currentMonth = Date()
    @State private var streakData: [Date: Bool] = [:]
    
    // MARK: - Calendar Helper
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday = 1, Monday = 2
        return calendar
    }
    
    // MARK: - Sample Data Generator
    private func generateSampleStreakData() {
        // Clear existing data
        streakData.removeAll()
        
        // Get current month's start date
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // Create sample streak data (true = completed task, false = missed)
        // Sample streak pattern: 3 days completed, 1 missed, 4 completed, 2 missed, 3 completed
        let pattern: [Bool] = [
            true, true, true, // First streak
            false, // Break
            true, true, true, true, // Second streak
            false, false, // Break
            true, true, true // Third streak
        ]
        
        // Apply pattern to dates
        for day in 0..<pattern.count {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                streakData[date] = pattern[day]
            }
        }
    }
    
    // MARK: - View Body
    var body: some View {
        VStack(spacing: 20) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday.prefix(1))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                
                // Empty cells for days before month start
                ForEach(0..<startingDayOfMonth(), id: \.self) { _ in
                    Text("")
                        .frame(height: 40)
                }
                
                // Day cells
                ForEach(1...daysInMonth(), id: \.self) { day in
                    DayCell(day: day, date: dateForDay(day), streakData: streakData)
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                legendItem(color: .orange, label: "Streak")
                legendItem(color: .gray.opacity(0.3), label: "No streak")
            }
            .padding(.top)
        }
        .padding()
        .onAppear {
            generateSampleStreakData()
        }
    }
    
    // MARK: - Helper Functions
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
            generateSampleStreakData()
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
            generateSampleStreakData()
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> Int {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        return range.count
    }
    
    private func startingDayOfMonth() -> Int {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    private func dateForDay(_ day: Int) -> Date {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        var newComponents = DateComponents()
        newComponents.year = components.year
        newComponents.month = components.month
        newComponents.day = day
        return calendar.date(from: newComponents)!
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Day Cell Component
struct DayCell: View {
    let day: Int
    let date: Date
    let streakData: [Date: Bool]
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var isComplete: Bool? {
        // Find if this date has streak data
        for (key, value) in streakData {
            if calendar.isDate(key, inSameDayAs: date) {
                return value
            }
        }
        return nil
    }
    
    private var isPartOfStreak: Bool {
        guard let isComplete = isComplete, isComplete else { return false }
        
        // Check if previous day was completed
        let previousDay = calendar.date(byAdding: .day, value: -1, to: date)!
        var isPreviousCompleted = false
        
        for (key, value) in streakData {
            if calendar.isDate(key, inSameDayAs: previousDay) {
                isPreviousCompleted = value
                break
            }
        }
        
        return isPreviousCompleted
    }
    // BOdy Property ...
    var body: some View {
        ZStack {
            // Background color based on completion status
            if let isComplete = isComplete {
                Circle()
                    .fill(isComplete ? Color.orange : Color.gray.opacity(0.3))
            } else {
                Circle()
                    .fill(Color.clear)
            }
            
            // Day number
            Text("\(day)")
                .foregroundColor(isComplete == true ? .white : .primary)
        }
        .frame(height: 55)
    }
}

// MARK: - Preview Provider
struct StreakCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        StreakCalendarView()
    }
}
