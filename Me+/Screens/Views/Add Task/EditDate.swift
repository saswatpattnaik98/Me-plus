import SwiftUI

struct EditDateAddedView: View {
    @Binding var date: Date
    @State private var selectedDayOption = "Today"
    
    let nameDay = ["Today", "Tomorrow", "Next Monday"]

    var body: some View {
        VStack(spacing: 80) {
            Text("\(dateLabel(for: date))")
                .font(.title)
                .fontWeight(.bold)

            DatePicker("Pick a date", selection: $date, in: Date()... , displayedComponents: .date)
                .datePickerStyle(.graphical)

            Picker("Select day", selection: $selectedDayOption) {
                ForEach(nameDay, id: \.self) { day in
                    Text(day)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedDayOption) { oldValue, newValue in
                updateDate(from: newValue)
            }
        }
        .padding()
    }

    func updateDate(from option: String) {
        let calendar = Calendar.current
        
        // FIXED: Preserve the current time components from the existing date
        let currentTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
        
        let today = Date()
        var newDate: Date

        switch option {
        case "Today":
            newDate = today

        case "Tomorrow":
            newDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        case "Next Monday":
            newDate = calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime) ?? today

        default:
            return
        }
        
        // IMPORTANT: Combine the new date with the existing time components
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
        dateComponents.hour = currentTimeComponents.hour
        dateComponents.minute = currentTimeComponents.minute
        dateComponents.second = currentTimeComponents.second
        
        date = calendar.date(from: dateComponents) ?? newDate
    }
    
    private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
    }
}
