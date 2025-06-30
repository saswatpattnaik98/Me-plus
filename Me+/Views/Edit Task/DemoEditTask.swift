
//import SwiftUI
//import SwiftData
//
//struct EditHabitView: View {
//    @Environment(\.modelContext) private var context
//    @Environment(\.dismiss) private var dismiss
//
//    @ObservedObject var viewModel: EditHabitViewModel
//
//    @State private var showingDeleteAlert = false
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Beautiful gradient background
//                EditTaskBG()
//
//                ScrollView(.vertical, showsIndicators: false) {
//                    VStack(spacing: 24) {
//                        // Header with cute icon
//                        headerSection
//
//                        // Main content
//                        VStack(spacing: 10) {
//                            taskInfoSection
//                            reminderSection
//                            subtasksSection
//                        }
//                        .padding(.bottom, 80) // Extra padding for safe area
//                    }
//                    .padding(.horizontal, 0)
//                    .padding(.top, 10)
//                }
//            }
//            .navigationTitle("Edit Task")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    saveButton
//                }
//            }
//        }
//    }
//
//    // MARK: - Header Section
//    private var headerSection: some View {
//        VStack(spacing: 12) {
//            // Cute task icon
//            ZStack {
//                Circle()
//                    .fill(
//                        LinearGradient(
//                            colors: [Color.mint.opacity(0.3), Color.cyan.opacity(0.2)],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(width: 80, height: 80)
//                    .overlay(
//                        Circle()
//                            .stroke(Color.mint.opacity(0.5), lineWidth: 2)
//                    )
//
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.system(size: 32, weight: .semibold))
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.mint, .cyan],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//            }
//            .shadow(color: .mint.opacity(0.3), radius: 10, x: 0, y: 5)
//
//            Text("Let's make this task perfect! ✨")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//        }
//    }
//
//    // MARK: - Task Info Section
//    private var taskInfoSection: some View {
//        sectionContainer(title: "Task Details", icon: "pencil.circle.fill") {
//            VStack(spacing: 16) {
//                customTextField(
//                    title: "Task Name",
//                    text: $viewModel.habitName,
//                    icon: "text.cursor",
//                    placeholder: "Enter your task name"
//                )
//            }
//        }
//    }
//
//    // MARK: - Reminder Section
//    private var reminderSection: some View {
//        sectionContainer(title: "Reminder Settings", icon: "bell.circle.fill") {
//            VStack(spacing: 10) {
//                // Date picker
//                datePickerRow
//                    .foregroundStyle(.black)
//
//                // Reminder type picker
//                reminderTypeRow
//
//                // Time picker (conditional)
//                if viewModel.reminderType != "No reminder" {
//                    timePickerRow
//                }
//
//                // Repeat picker
//                repeatPickerRow
//            }
//        }
//    }
//
//    // MARK: - Subtasks Section
//    private var subtasksSection: some View {
//        sectionContainer(title: "Subtasks", icon: "list.bullet.circle.fill") {
//            VStack(spacing: 12) {
//                // Use ID-based ForEach for better stability
//                ForEach(viewModel.subtasks, id: \.id) { subtask in
//                    subtaskRowById(subtask: subtask)
//                }
//
//                // Add new subtask
//                addSubtaskRow
//            }
//        }
//    }
//
//    // MARK: - ID-based Subtask Row (Recommended Approach)
//    private func subtaskRowById(subtask: Subtask) -> some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: "minus.circle", color: .mint, size: 20)
//
//            TextField("Subtask", text: Binding(
//                get: {
//                    subtask.name
//                },
//                set: { newValue in
//                    // Find and update the subtask safely
//                    if let index = viewModel.subtasks.firstIndex(where: { $0.id == subtask.id }) {
//                        viewModel.subtasks[index].name = newValue
//                    }
//                }
//            ))
//            .textFieldStyle(.plain)
//            .font(.body)
//
//            if viewModel.subtasks.count > 1 {
//                Button(role: .destructive) {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        viewModel.removeSubtask(subtask)
//                    }
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 18))
//                        .foregroundStyle(.red)
//                }
//            }
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    // MARK: - Alternative Index-based Implementation (Fallback)
//    private var subtasksSectionIndexBased: some View {
//        sectionContainer(title: "Subtasks", icon: "list.bullet.circle.fill") {
//            VStack(spacing: 12) {
//                // Safe index-based approach with enumerated
//                ForEach(Array(viewModel.subtasks.enumerated()), id: \.element.id) { index, subtask in
//                    subtaskRowSafe(subtask: subtask, at: index)
//                }
//
//                // Add new subtask
//                addSubtaskRow
//            }
//        }
//    }
//
//    private func subtaskRowSafe(subtask: Subtask, at index: Int) -> some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: "minus.circle", color: .mint, size: 20)
//
//            TextField("Subtask", text: Binding(
//                get: {
//                    // Safe array access with bounds checking
//                    guard index >= 0 && index < viewModel.subtasks.count else {
//                        return subtask.name // Fallback to original subtask name
//                    }
//                    return viewModel.subtasks[index].name
//                },
//                set: { newValue in
//                    // Safe array mutation with bounds checking
//                    guard index >= 0 && index < viewModel.subtasks.count else {
//                        return
//                    }
//                    viewModel.subtasks[index].name = newValue
//                }
//            ))
//            .textFieldStyle(.plain)
//            .font(.body)
//
//            if viewModel.subtasks.count > 1 {
//                Button(role: .destructive) {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        viewModel.removeSubtaskSafely(at: index)
//                    }
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 18))
//                        .foregroundStyle(.red)
//                }
//            }
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    // MARK: - Individual Rows
//    private var datePickerRow: some View {
//        NavigationLink(destination: EditDateAddedView(date: $viewModel.date)) {
//            settingsRow(
//                icon: "calendar",
//                title: "Date",
//                value: viewModel.date.displayDate,
//                hasChevron: true
//            )
//        }
//    }
//
//    private var reminderTypeRow: some View {
//        HStack(spacing: 8) {
//            iconContainer(systemName: "bell", color: .orange)
//
//            Text("Reminder")
//                .font(.subheadline)
//                .fontWeight(.medium)
//
//            Spacer()
//
//            Picker("Reminder Type", selection: $viewModel.reminderType) {
//                ForEach(viewModel.ReminderType, id: \.self) { type in
//                    Text(type).tag(type)
//                }
//            }
//            .pickerStyle(.menu)
//            .tint(.primary)
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    private var timePickerRow: some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: "clock", color: .blue)
//
//            Text("Time")
//                .font(.subheadline)
//                .fontWeight(.medium)
//
//            Spacer()
//
//            DatePicker("", selection: $viewModel.time, displayedComponents: .hourAndMinute)
//                .labelsHidden()
//                .scaleEffect(0.9)
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    // MARK: - NEW: Reminder Time Row
//    private var reminderTimeRow: some View {
//        let isReminderEnabled = viewModel.reminderType != "No reminder"
//
//        return HStack(spacing: 12) {
//            iconContainer(systemName: "clock.fill", color: .mint)
//                .opacity(isReminderEnabled ? 1.0 : 0.5)
//
//            Text("Remind me @")
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .opacity(isReminderEnabled ? 1.0 : 0.5)
//
//            Spacer()
//
//            Picker("", selection: $viewModel.reminderTime) {
//                ForEach(ReminderOffset.allCases) { option in
//                    Text(option.rawValue).tag(option)
//                }
//            }
//            .pickerStyle(.menu)
//            .disabled(!isReminderEnabled)
//            .tint(isReminderEnabled ? .mint : .gray)
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    private var repeatPickerRow: some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: "repeat", color: .purple)
//
//            Text("Repeat")
//                .font(.subheadline)
//                .fontWeight(.medium)
//
//            Spacer()
//
//            Picker("Repeat", selection: $viewModel.selectedRepeat) {
//                ForEach(RepeatOption.allCases, id: \.self) { option in
//                    Text(option.rawValue.capitalized).tag(option)
//                }
//            }
//            .pickerStyle(.menu)
//            .tint(.primary)
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    private func subtaskRow(at index: Int) -> some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: "minus.circle", color: .mint, size: 20)
//
//            TextField("Subtask", text: Binding(
//                get: { viewModel.subtasks[index].name },
//                set: { viewModel.subtasks[index].name = $0 }
//            ))
//            .textFieldStyle(.plain)
//            .font(.body)
//
//            if viewModel.subtasks.count > 1 {
//                Button(role: .destructive) {
//                    viewModel.subtasks.remove(at: index)
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 18))
//                        .foregroundStyle(.red)
//                }
//            }
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    private var addSubtaskRow: some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: "plus.circle", color: .green, size: 20)
//
//            TextField("Add new subtask", text: $viewModel.subtaskName)
//                .textFieldStyle(.plain)
//                .font(.body)
//                .onSubmit {
//                    viewModel.addSubtask()
//                }
//
//            Button(action: {
//                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                    viewModel.addSubtask()
//                }
//            }) {
//                Image(systemName: "plus.circle.fill")
//                    .font(.system(size: 18))
//                    .foregroundStyle(.green)
//            }
//            .disabled(viewModel.subtaskName.isEmpty)
//            .opacity(viewModel.subtaskName.isEmpty ? 0.5 : 1.0)
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
//                .foregroundStyle(.mint.opacity(0.5))
//        )
//    }
//
//    // MARK: - Helper Views
//    private func sectionContainer<Content: View>(
//        title: String,
//        icon: String,
//        @ViewBuilder content: () -> Content
//    ) -> some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Section header
//            HStack(spacing: 8) {
//                Image(systemName: icon)
//                    .font(.title3)
//                    .foregroundStyle(.mint)
//
//                Text(title)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.primary)
//
//                Spacer()
//            }
//
//            // Section content
//            content()
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.ultraThinMaterial)
//                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
//        )
//    }
//
//    private func customTextField(
//        title: String,
//        text: Binding<String>,
//        icon: String,
//        placeholder: String
//    ) -> some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: icon, color: .mint)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//
//                TextField(placeholder, text: text)
//                    .textFieldStyle(.plain)
//                    .font(.body)
//            }
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//
//    private func settingsRow(
//        icon: String,
//        title: String,
//        value: String,
//        hasChevron: Bool = false
//    ) -> some View {
//        HStack(spacing: 12) {
//            iconContainer(systemName: icon, color: .mint)
//
//            Text(title)
//                .font(.subheadline)
//                .foregroundStyle(.white)
//                .fontWeight(.medium)
//
//            Spacer()
//
//            Text(value)
//                .font(.body)
//                .foregroundStyle(.white)
//
//            if hasChevron {
//                Image(systemName: "chevron.right")
//                    .font(.caption)
//                    .foregroundStyle(.white)
//            }
//        }
//        .padding(16)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//        .foregroundStyle(.primary)
//    }
//
//    private func iconContainer(
//        systemName: String,
//        color: Color,
//        size: CGFloat = 24
//    ) -> some View {
//        ZStack {
//            Circle()
//                .fill(color.opacity(0.15))
//                .frame(width: 32, height: 32)
//
//            Image(systemName: systemName)
//                .font(.system(size: size * 0.6, weight: .medium))
//                .foregroundStyle(color)
//        }
//    }
//
//    private var saveButton: some View {
//        Button {
//            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                viewModel.updateActivity(in: context)
//                dismiss()
//                dismiss()
//            }
//        } label: {
//            HStack(spacing: 6) {
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.system(size: 16, weight: .semibold))
//                Text("Save")
//                    .fontWeight(.semibold)
//            }
//            .foregroundStyle(.white)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 8)
//            .background(
//                LinearGradient(
//                    colors: [.mint, .cyan],
//                    startPoint: .leading,
//                    endPoint: .trailing
//                ),
//                in: Capsule()
//            )
//            .shadow(color: .mint.opacity(0.3), radius: 5, x: 0, y: 2)
//        }
//    }
//}
//
//#Preview {
//    EditHabitView(viewModel: EditHabitViewModel(activity: Activity(name: "Preview", date: Date.now, duration: 0)))
//        .environmentObject(AlarmManager.shared)
//        .preferredColorScheme(.dark)
//}
