import SwiftUI
import SwiftData
import UserNotifications

struct AddNewHabit: View {
    
    @ObservedObject var addHabitViewModel: AddhabitViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query private var activities: [Activity]
    @EnvironmentObject var alarmManager: AlarmManager
    let selectionfeedabackgenerator = UISelectionFeedbackGenerator()
    
    var isValid: Bool {
        !addHabitViewModel.habitName.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    colors: [
                        addHabitViewModel.selectedColor.opacity(0.3),
                        addHabitViewModel.selectedColor.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section with Icon and Title
                        headerSection
                        
                        // Color Palette
                        ColorPaletteView(selectedColor: $addHabitViewModel.selectedColor)
                            .padding(.horizontal, 20)
                        
                        // Form Inputs
                        formInputs
                        
                        // Subtasks Section
                        subtasksSection
                        
                        Spacer(minLength: 100) // Space for the floating button
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .onAppear {
                AddhabitViewModel.notificationManager.requestPermission()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    createButton
                }
            }
            .overlay(alignment: .bottom) {
                // Floating Create Button (Alternative)
                if false { // Set to true if you prefer floating button
                    floatingCreateButton
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon with enhanced styling
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: addHabitViewModel.selectedColor.opacity(0.3), radius: 10, x: 0, y: 5)
                
                if let uiImage = UIImage(named: addHabitViewModel.habitName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .scaledToFit()
                } else {
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(addHabitViewModel.selectedColor)
                }
            }
            
            // Enhanced TextField
            VStack(spacing: 8) {
                TextField("Enter habit name", text: $addHabitViewModel.habitName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .fill(addHabitViewModel.selectedColor.opacity(0.5))
                    .frame(height: 2)
                    .frame(maxWidth: 200)
                    .opacity(addHabitViewModel.habitName.isEmpty ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: addHabitViewModel.habitName.isEmpty)
            }
        }
    }
    
    // MARK: - Enhanced Form Inputs
    private var formInputs: some View {
        VStack(spacing: 0) {
            // Date Row
            NavigationLink(destination: EditDateAddedView(date: $addHabitViewModel.date)) {
                formRow(
                    icon: "calendar",
                    title: "Date",
                    value: addHabitViewModel.date.displayDate,
                    showChevron: true
                )
            }
            .foregroundStyle(.primary)
            
            Divider()
                .padding(.leading, 50)
            
            // Time Row
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    addHabitViewModel.showEditTime.toggle()
                }
            } label: {
                formRow(
                    icon: "clock",
                    title: "Time",
                    value: timeDisplayText,
                    showChevron: true
                )
            }
            .foregroundStyle(.primary)
            
            Divider()
                .padding(.leading, 50)
            
            // Repeat Row
            Button {
                addHabitViewModel.showrepeatPicker.toggle()
            } label: {
                formRow(
                    icon: "repeat.circle",
                    title: "Repeat",
                    value: "\(addHabitViewModel.selectedRepeat)",
                    showChevron: true
                )
            }
            .foregroundStyle(.primary)
            
            Divider()
                .padding(.leading, 50)
            
            // Reminder Type Row
            HStack(spacing: 16) {
                iconContainer("bell")
                
                Text("Reminder")
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Picker("", selection: $addHabitViewModel.reminderType) {
                    ForEach(addHabitViewModel.ReminderType, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(addHabitViewModel.selectedColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .padding(.leading, 50)
            
            // Reminder Time Row
            HStack(spacing: 16) {
                iconContainer("clock.fill")
                    .opacity(addHabitViewModel.showTimePicker ? 1.0 : 0.5)
                
                Text("Remind me @")
                    .font(.body)
                    .fontWeight(.medium)
                    .opacity(addHabitViewModel.showTimePicker ? 1.0 : 0.5)
                
                Spacer()
                
                Picker("", selection: $addHabitViewModel.reminderTime) {
                    ForEach(ReminderOffset.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!addHabitViewModel.showTimePicker)
                .accentColor(addHabitViewModel.selectedColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .sheet(isPresented: $addHabitViewModel.showEditTime) {
            EditTimeView(
                time1: $addHabitViewModel.time,
                time2: $addHabitViewModel.endTime,
                showTimePicker: $addHabitViewModel.showTimePicker,
                periodTime: $addHabitViewModel.periodTime
            )
        }
        .sheet(isPresented: $addHabitViewModel.showrepeatPicker) {
            RepeatBottomSelect(
                selectedRepeat: $addHabitViewModel.selectedRepeat,
                endDate: $addHabitViewModel.date
            )
            .presentationDetents([.fraction(0.4), .medium])
            .presentationDragIndicator(.hidden)
        }
    }
    
    // MARK: - Enhanced Subtasks Section
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Subtasks")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Optional")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                // Existing Subtasks
                ForEach(addHabitViewModel.subtasks, id: \.id) { subtask in
                    HStack {
                        Circle()
                            .fill(addHabitViewModel.selectedColor.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Text(subtask.name)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                    )
                }
                
                // Add Subtask Field
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(addHabitViewModel.selectedColor)
                        .font(.title3)
                    
                    TextField("Add a subtask", text: $addHabitViewModel.subtaskName)
                        .onSubmit {
                            addHabitViewModel.addSubtask()
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(addHabitViewModel.selectedColor.opacity(0.3), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                        )
                )
            }
        }
    }
    
    // MARK: - Helper Views
    private func formRow(icon: String, title: String, value: String, showChevron: Bool = false) -> some View {
        HStack(spacing: 16) {
            iconContainer(icon)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func iconContainer(_ iconName: String) -> some View {
        ZStack {
            Circle()
                .fill(addHabitViewModel.selectedColor.opacity(0.15))
                .frame(width: 32, height: 32)
            
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(addHabitViewModel.selectedColor)
        }
    }
    
    private var timeDisplayText: String {
        if addHabitViewModel.showTimePicker {
            if addHabitViewModel.periodTime {
                return "\(addHabitViewModel.time.formatted(date: .omitted, time: .shortened)) - \(addHabitViewModel.endTime.formatted(date: .omitted, time: .shortened))"
            } else {
                return "\(addHabitViewModel.time.formatted(date: .omitted, time: .shortened))"
            }
        } else {
            return "Anytime"
        }
    }
    
    // MARK: - Create Button
    private var createButton: some View {
        Button {
            createHabit()
        } label: {
            Text("Create")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isValid ? .white : .secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isValid ? addHabitViewModel.selectedColor : Color.gray.opacity(0.3))
                )
        }
        .disabled(!isValid)
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
    
    private var floatingCreateButton: some View {
        Button {
            createHabit()
        } label: {
            HStack {
                Image(systemName: "plus")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Create Habit")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                addHabitViewModel.selectedColor,
                                addHabitViewModel.selectedColor.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: addHabitViewModel.selectedColor.opacity(0.4), radius: 10, x: 0, y: 5)
            )
        }
        .disabled(!isValid)
        .scaleEffect(isValid ? 1.0 : 0.95)
        .opacity(isValid ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
    
    // MARK: - Create Habit Logic
    private func createHabit() {
        let baseID = UUID()
        let newActivity = Activity(
            id: UUID(),
            baseID: baseID,
            name: addHabitViewModel.habitName,
            date: addHabitViewModel.date,
            duration: addHabitViewModel.tempduration,
            isCompleted: false,
            subtasks: addHabitViewModel.subtasks
        )
        
        modelContext.insert(newActivity)
        
        if addHabitViewModel.selectedRepeat != .None {
            addHabitViewModel.createRepeatedActivities(baseActivity: newActivity, baseID: baseID, context: modelContext)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save activity: \(error)")
        }

        // Schedule alarm or notification
        if addHabitViewModel.showTimePicker {
            if let combinedDate = addHabitViewModel.combineDateAndTime(date: addHabitViewModel.date, time: addHabitViewModel.time) {
                if addHabitViewModel.reminderType == "Alarm" {
                    addHabitViewModel.scheduleAlarm(for: newActivity.id, baseDate: combinedDate)
                } else if addHabitViewModel.reminderType == "Notification" {
                    addHabitViewModel.scheduleNotification(for: combinedDate, activityId: newActivity.id)
                }
            }
        }
        
        selectionfeedabackgenerator.selectionChanged()
        dismiss()
    }
}

extension Date {
    var displayDate: String {
        self.formatted(.dateTime.day().month(.wide).year())
    }
}

#Preview {
    AddNewHabit(addHabitViewModel: AddhabitViewModel())
        .environmentObject(AlarmManager.shared)
}
