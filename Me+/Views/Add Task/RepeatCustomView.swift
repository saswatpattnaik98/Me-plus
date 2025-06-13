import SwiftUI
import SwiftData

struct RepeatCustomView: View {
    // Booleans to control the UI
    @State private var showRepeatSelector = false
    @State private var showIntervalPicker = false
    @State private var showEndDatePicker = false
    @State private var showExpandInterval = false
    
    @State private var selectedRepeat: String = "Daily"
    @State private var interval: Int = 1
    // Date selected for the task
     let endDate: Date
    @State private var completeDate: Date = Date()
    @Environment(\.dismiss) var dismiss
    
    let repeatType = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Repeats Every \(interval) \(selectedRepeat.lowercased())")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                
                // Repeat Toggle Section
                HStack {
                    Image(systemName: "repeat")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading) {
                        Text("Repeat")
                            .font(.system(size: 18))
                        Text("Set a cycle for your plan")
                            .font(.caption)
                    }
                    Spacer()
                    Toggle("", isOn: $showRepeatSelector)
                        .labelsHidden()
                }.padding()
                
                // Show Picker if toggle ON
                if showRepeatSelector {
                    HStack {
                        Picker("", selection: $selectedRepeat) {
                            ForEach(repeatType, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(height: 100)
                    }
                    
                    // Interval Picker
                    if showIntervalPicker {
                        Picker("Every", selection: $interval) {
                            ForEach(1...50, id: \.self) { number in
                                Text("\(number)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                    
                    Divider()
                }
                HStack{
                    Text("Interval")
                        .font(.headline)
                    Spacer()
                    if selectedRepeat == "Daily"{
                        Text(" Every \(interval) day")
                    }else if selectedRepeat == "Weekly"{
                        Text("Every \(interval) week")
                    }else{
                        Text("Every \(interval) month")
                    }
                    Button{
                        withAnimation{
                            showExpandInterval.toggle()
                        }
                    }label: {
                        Image(systemName: showExpandInterval ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.black)
                    }
                }
                .padding()
                
                if showExpandInterval{
                    HStack{
                        Text("Every")
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        if selectedRepeat == "Daily"{
                            Picker("", selection: $interval) {
                                ForEach(1...99, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width:100)
                            Text("days")
                        }else if selectedRepeat == "Weekly"{
                            Picker("", selection: $interval) {
                                ForEach(1...48, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width:100)
                            Text("week")
                        }else{
                            Picker("", selection: $interval) {
                                ForEach(1...12, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width:100)
                            Text("month")
                        }
                    }
                }
                // End Date Toggle
                Toggle(isOn: $showEndDatePicker) {
                    Text("End Repeat")
                        .font(.headline)
                }
                .padding(.horizontal)
                
                // End Date Picker
                if showEndDatePicker {
                    DatePicker(
                        "Select End Date",
                        selection: $completeDate,
                        in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    RepeatCustomView(endDate: Date())
}

