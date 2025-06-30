// MARK: - Enhanced Chat View with Unique Task Key Detection
import SwiftUI

struct ChatView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.modelContext) private var modelContext
    // Unique task key that AI should include when providing actual tasks/routines
    private let TASK_KEY = "ROUTINE_TASKS_READY_2024"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                messagesView
                
                inputView
            }
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
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack{
                            Image("appIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20,height: 20)
                            
                            Text("Ridan")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        Text("Your cognitive alignment AI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                
                Button(action: viewModel.clearChat) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .disabled(viewModel.messages.isEmpty)
                .opacity(viewModel.messages.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Retry"){
                        viewModel.retryLastMessage()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
            }
            
            // Instructions for AI (hidden from user)
            Text("**Instructions for AI Assistant:**\n\nWhen you provide actual task lists, routines, or schedules that users can save to their calendar (not just explanations or tips), please include this exact key at the end of your response: `\(viewModel.getTaskKey())`\n\nThis helps the app identify when tasks are ready to be saved to the user's schedule. Only include this key when you're providing structured, actionable tasks or routines.")
                       .font(.caption2)
                       .foregroundColor(.clear)
                       .frame(height: 0)
                       .opacity(0)
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if viewModel.messages.filter({ $0.role != .system }).isEmpty {
                        emptyStateView
                    }
                    
                    ForEach(viewModel.messages.filter({ $0.role != .system }), id: \.id) { message in
                        VStack(alignment: .leading, spacing: 12) {
                            // Use ViewModel methods for task key detection and content cleaning
                            MessageBubble(
                                message: message,
                                taskKey: viewModel.getTaskKey(),
                                cleanContent: viewModel.cleanMessageContent(message.content)
                            )
                            .id(message.id)
                            
                            // Only show Add Tasks button when the unique key is found
                            if message.role == .assistant &&
                               message.id == viewModel.messages.last?.id &&
                               viewModel.containsTaskKey(message.content) &&
                               !viewModel.parsedTasks.isEmpty {
                                saveToTasksButton
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        typingIndicator
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .onReceive(viewModel.$messages) { _ in
                withAnimation(.easeOut(duration: 0.5)) {
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Task Key Detection
    private func containsTaskKey(_ content: String) -> Bool {
        return content.contains(TASK_KEY)
    }
    
    // MARK: - Add Tasks Button
    private var saveToTasksButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                viewModel.showTasksSaveDialog = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add to Schedule")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.parsedTasks.count) tasks ready")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue,
                            Color.purple.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.parsedTasks.count)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Spacer()
            VStack(spacing: 12) {
                Text("What's your goal,Hariom?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("I can break them into daily achievable actions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                suggestionChip(text: "Study Machine Learning", icon: "sunrise.fill")
                suggestionChip(text: "Start a youtube channel", icon: "figure.run")
                suggestionChip(text: "Clear IIT-JEE in 6 months", icon: "book.fill")
            }
        }
        .padding(.top, 40)
    }
    
    private func suggestionChip(text: String, icon: String) -> some View {
        Button(action: {
            viewModel.currentInput = text
            viewModel.sendMessage()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(text)
                    .font(.subheadline)
            }
            .foregroundColor(.indigo)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .clipShape(Capsule())
        }
    }
    
    // MARK: - Typing Indicator
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .scaleEffect(viewModel.isLoading ? 1.2 : 0.8)
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
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Input View
    private var inputView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("Ask for routines, schedules, or planning help...", text: $viewModel.currentInput, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .lineLimit(1...4)
                        .onSubmit {
                            viewModel.sendMessage()
                        }
                    
                    if !viewModel.currentInput.isEmpty {
                        Button(action: {
                            viewModel.currentInput = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.indigo)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(canSend ? Color.blue.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
                )
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.sendMessage()
                        
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(canSend ? Color.indigo.opacity(0.2) : Color(.white))
                            .frame(width: 40, height: 40)
                            .shadow(color: canSend ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.indigo)
                    }
                }
                .disabled(!canSend)
                .scaleEffect(canSend ? 1.0 : 0.8)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }  
    private var canSend: Bool {
        !viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isLoading
    }
}


#Preview {
    ChatView()
}
