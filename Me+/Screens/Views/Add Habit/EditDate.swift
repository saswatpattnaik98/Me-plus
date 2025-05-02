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
            .onChange(of:selectedDayOption){ oldValue,newValue in
                updateDate(from: newValue)
            }
        }
        .padding()
    }

    func updateDate(from option: String) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        switch option {
        case "Today":
            date = today

        case "Tomorrow":
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                date = tomorrow
            }

        case "Next Monday":
            if let nextMonday = calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime) {
                date = nextMonday
            }

        default:
            break
        }
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
#Preview {
    EditDateAddedView(date: .constant(Date()))
}

