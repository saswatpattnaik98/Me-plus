import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: EditHabitViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [
                        Color.mint.opacity(0.3),
                        Color.cyan.opacity(0.2),
                        Color.white.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header with cute icon
                        headerSection
                        
                        // Main content
                        VStack(spacing: 20) {
                            taskInfoSection
                            reminderSection
                            subtasksSection
                        }
                        .padding(.bottom, 100) // Extra padding for safe area
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Cute task icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.mint.opacity(0.3), Color.cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.mint.opacity(0.5), lineWidth: 2)
                    )
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mint, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: .mint.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Let's make this task perfect! ✨")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Task Info Section
    private var taskInfoSection: some View {
        sectionContainer(title: "Task Details", icon: "pencil.circle.fill") {
            VStack(spacing: 16) {
                customTextField(
                    title: "Task Name",
                    text: $viewModel.habitName,
                    icon: "text.cursor",
                    placeholder: "Enter your task name"
                )
            }
        }
    }
    
    // MARK: - Reminder Section
    private var reminderSection: some View {
        sectionContainer(title: "Reminder Settings", icon: "bell.circle.fill") {
            VStack(spacing: 16) {
                // Date picker
                datePickerRow
                
                // Reminder type picker
                reminderTypeRow
                
                // Time picker (conditional)
                if viewModel.reminderType != "No reminder" {
                    timePickerRow
                }
                
                // Repeat picker
                repeatPickerRow
            }
        }
    }
    
    // MARK: - Subtasks Section
    private var subtasksSection: some View {
        sectionContainer(title: "Subtasks", icon: "list.bullet.circle.fill") {
            VStack(spacing: 12) {
                // Existing subtasks
                ForEach(viewModel.subtasks.indices, id: \.self) { index in
                    subtaskRow(at: index)
                }
                
                // Add new subtask
                addSubtaskRow
            }
        }
    }
    
    // MARK: - Individual Rows
    private var datePickerRow: some View {
        NavigationLink(destination: EditDateAddedView(date: $viewModel.date)) {
            settingsRow(
                icon: "calendar",
                title: "Date",
                value: viewModel.date.displayDate,
                hasChevron: true
            )
        }
    }
    
    private var reminderTypeRow: some View {
        HStack(spacing: 12) {
            iconContainer(systemName: "bell", color: .orange)
            
            Text("Reminder Type")
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Reminder Type", selection: $viewModel.reminderType) {
                ForEach(viewModel.ReminderType, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var timePickerRow: some View {
        HStack(spacing: 12) {
            iconContainer(systemName: "clock", color: .blue)
            
            Text("Time")
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            DatePicker("", selection: $viewModel.time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .scaleEffect(0.9)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var repeatPickerRow: some View {
        HStack(spacing: 12) {
            iconContainer(systemName: "repeat", color: .purple)
            
            Text("Repeat")
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("Repeat", selection: $viewModel.selectedRepeat) {
                ForEach(RepeatOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func subtaskRow(at index: Int) -> some View {
        HStack(spacing: 12) {
            iconContainer(systemName: "minus.circle", color: .mint, size: 20)
            
            TextField("Subtask", text: Binding(
                get: { viewModel.subtasks[index].name },
                set: { viewModel.subtasks[index].name = $0 }
            ))
            .textFieldStyle(.plain)
            .font(.body)
            
            if viewModel.subtasks.count > 1 {
                Button(role: .destructive) {
                    viewModel.subtasks.remove(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var addSubtaskRow: some View {
        HStack(spacing: 12) {
            iconContainer(systemName: "plus.circle", color: .green, size: 20)
            
            TextField("Add new subtask", text: $viewModel.subtaskName)
                .textFieldStyle(.plain)
                .font(.body)
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.addSubtask()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.green)
            }
            .disabled(viewModel.subtaskName.isEmpty)
            .opacity(viewModel.subtaskName.isEmpty ? 0.5 : 1.0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundStyle(.mint.opacity(0.5))
        )
    }
    
    // MARK: - Helper Views
    private func sectionContainer<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.mint)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            // Section content
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func customTextField(
        title: String,
        text: Binding<String>,
        icon: String,
        placeholder: String
    ) -> some View {
        HStack(spacing: 12) {
            iconContainer(systemName: icon, color: .mint)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField(placeholder, text: text)
                    .textFieldStyle(.plain)
                    .font(.body)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func settingsRow(
        icon: String,
        title: String,
        value: String,
        hasChevron: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            iconContainer(systemName: icon, color: .mint)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
            
            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .foregroundStyle(.primary)
    }
    
    private func iconContainer(
        systemName: String,
        color: Color,
        size: CGFloat = 24
    ) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
            
            Image(systemName: systemName)
                .font(.system(size: size * 0.6, weight: .medium))
                .foregroundStyle(color)
        }
    }
    
    private var saveButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                viewModel.updateActivity(in: context)
                dismiss()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Save")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [.mint, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: Capsule()
            )
            .shadow(color: .mint.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    EditHabitView(viewModel: EditHabitViewModel(activity: Activity(name: "Preview", date: Date.now, duration: 0)))
        .environmentObject(AlarmManager.shared)
}
