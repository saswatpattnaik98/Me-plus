// MARK: - Enhanced Chat View
import SwiftUI

struct ChatView: View {
    @StateObject  var viewModel = ViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                messagesView
                HStack{
                    Spacer()
                    headerAddTasksButton
                }.padding()
                inputView
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showTasksSaveDialog) {
                TaskSaveSheet(
                    tasks: viewModel.parsedTasks,
                    onSave: { selectedTasks in
                        viewModel.saveTasksToTodoApp(selectedTasks, modelContext: modelContext)
                    },
                    onCancel: {
                        viewModel.showTasksSaveDialog = false
                    }
                )
            }
        }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Text("AI Assistant")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: viewModel.clearChat) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .disabled(viewModel.messages.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Retry") {
                        viewModel.retryLastMessage()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.filter({ $0.role != .system }).isEmpty {
                        emptyStateView
                    }
                    
                    ForEach(viewModel.messages.filter({ $0.role != .system }),id: \.id) { message in
                        VStack(alignment: .leading, spacing: 8) {
                            MessageBubble(message: message)
                                .id(message.id)
                            
                            // Show "Save to Tasks" button for assistant messages with parsed tasks
                            if message.role == .assistant &&
                               message.id == viewModel.messages.last?.id &&
                               !viewModel.parsedTasks.isEmpty {
                                saveToTasksButton
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        typingIndicator
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onReceive(viewModel.$messages) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Updated Chat View with Smart Add Tasks Button
     var saveToTasksButton: some View {
        HStack {
            Spacer()
            
            // Show button only when we have a complete planner
            if viewModel.showAddTasksButton {
                Button(action: {
                    viewModel.showTasksSaveDialog = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add \(viewModel.parsedTasks.count) Tasks to Schedule")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                .scaleEffect(1.02)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showAddTasksButton)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("How can I help you today?")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("I can help you create workout plans, daily routines, study schedules, and more!")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 60)
    }
    
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(viewModel.isLoading ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: viewModel.isLoading
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var inputView: some View {
        HStack(spacing: 12) {
            TextField("Ask for routines, schedules, or tasks...", text: $viewModel.currentInput, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .lineLimit(1...4)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.sendMessage()
                }
            }) {
                Image(systemName: viewModel.isLoading ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canSend ? .blue : .secondary)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
            }
            .disabled(!canSend && !viewModel.isLoading)
            .scaleEffect(canSend || viewModel.isLoading ? 1.0 : 0.8)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemGroupedBackground))
    }
    // MARK: - Alternative: Header Button for Manual Add
     var headerAddTasksButton: some View {
        Button(action: {
            viewModel.showAddTasksManually()
        }) {
            Image(systemName: "plus.square.on.square")
                .foregroundColor(.blue)
                .font(.title2)
        }
        .disabled(viewModel.messages.isEmpty)
        .opacity(viewModel.messages.isEmpty ? 0.5 : 1.0)
    }
    
    private var canSend: Bool {
        !viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isLoading
    }
}

// MARK: - Task Save Sheet
struct TaskSaveSheet: View {
    let tasks: [ParsedTask]
    let onSave: ([ParsedTask]) -> Void
    let onCancel: () -> Void
    
    @State private var selectedTasks: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Save Tasks to Your Todo List")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Select the tasks you want to add:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                List {
                    ForEach(tasks) { task in
                        TaskSelectionRow(
                            task: task,
                            isSelected: selectedTasks.contains(task.id)
                        ) { isSelected in
                            if isSelected {
                                selectedTasks.insert(task.id)
                            } else {
                                selectedTasks.remove(task.id)
                            }
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button("Save \(selectedTasks.count) Tasks") {
                        let tasksToSave = tasks.filter { selectedTasks.contains($0.id) }
                        onSave(tasksToSave)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedTasks.isEmpty ? Color(.systemGray5) : Color.blue)
                    .foregroundColor(selectedTasks.isEmpty ? .secondary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(selectedTasks.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            // Select all tasks by default
            selectedTasks = Set(tasks.map { $0.id })
        }
    }
}

// MARK: - Task Selection Row
struct TaskSelectionRow: View {
    let task: ParsedTask
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                onToggle(!isSelected)
            }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(task.duration) min")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text(formatDate(task.suggestedDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle(!isSelected)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Message Bubble (same as before)
struct MessageBubble: View {
    let message: Mesaage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .assistant {
                assistantBubble
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                userBubble
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .clipShape(BubbleShape(isFromCurrentUser: false))
            
            Text(formatTime(message.createdAt))
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
        }
    }
    
    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(BubbleShape(isFromCurrentUser: true))
            
            Text(formatTime(message.createdAt))
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.trailing, 4)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Custom Bubble Shape
struct BubbleShape: Shape {
    let isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromCurrentUser
                ? [.topLeft, .topRight, .bottomLeft]
                : [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}


#Preview {
    ChatView()
}
