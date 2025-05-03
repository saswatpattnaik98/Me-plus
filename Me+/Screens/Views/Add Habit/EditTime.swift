import SwiftUI

struct EditTimeView: View {
    @Binding var time1: Date
    @Binding var time2: Date
    @Binding var showTimePicker: Bool
    @Environment(\.dismiss) var dismiss
    @Binding var periodTime: Bool
    let timeType = ["Point Time", "Time Period"]
    @State private var timeSelection = "Point Time"
    var body: some View {
        NavigationStack{
            VStack(spacing: 40){
                Text("Do it any time of the day")
                    .font(.title)
                    .fontWeight(.semibold)
                HStack{
                    Image(systemName: "clock.fill")
                        .font(.title2)
                    VStack(alignment: .leading){
                        Text("Specified time")
                            .fontWeight(.semibold)
                        Text("Set a specific time to do it")
                            .font(.caption)
                    }//vstack
                    Spacer()
                    Toggle("", isOn: $showTimePicker)
                }//hstack
                .padding()
                if showTimePicker{
                    Picker("", selection: $timeSelection){
                        ForEach(timeType, id: \.self){
                            Text($0)
                        }
                }
                    .pickerStyle(.segmented)
                    if timeSelection == "Point Time"{
                        DatePicker("", selection: $time1, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                    }else{
                        ScrollView{
                            DatePicker("", selection: $time1, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                            
                            Text("To")
                            DatePicker("", selection: $time2, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
        
                        }
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.hidden)
                    }
                }
            
            }//vstack
            
            Spacer()
                .toolbar{
                    ToolbarItem(placement: .topBarLeading){
                        Button{
                            if timeSelection == "Time Period"{
                                periodTime = true
                            }else{
                                periodTime = false
                            }
                            dismiss()
                        }label:{
                            Image(systemName: "arrowshape.turn.up.backward")
                                .foregroundStyle(.black)
                        }
                    }
            }//toolbar
            
        }//navigationStack
        .onAppear {
            time2 = nextFullHour(from: time1)
        }
    }
    func nextFullHour(from date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.hour = (components.hour ?? 0) + 1
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
}
#Preview {
    EditTimeView(time1: .constant(Date()), time2: .constant(Date()), showTimePicker: .constant(true) , periodTime: .constant(false))
}

