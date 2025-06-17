// MARK: - Enhanced ViewModel (Updated to match your structure)
import SwiftUI
extension ChatView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var messages: [Mesaage] = []
        @Published var currentInput: String = ""
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        private let openAIService = OpenAlService()
        
        func sendMessage() {
            guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            
            let newMessage = Mesaage(id: UUID(), role: .user, content: currentInput, createdAt: Date())
            messages.append(newMessage)
            
            let messageToSend = currentInput
            currentInput = ""
            isLoading = true
            errorMessage = nil
            
            Task {
                let response = await openAIService.sendMessage(messages: messages)
                
                guard let receivedOpenAIMessage = response?.choices.first?.message else {
                    await MainActor.run {
                        errorMessage = "Failed to get response. Please try again."
                        isLoading = false
                    }
                    return
                }
                
                let receivedMessage = Mesaage(
                    id: UUID(),
                    role: receivedOpenAIMessage.role,
                    content: receivedOpenAIMessage.content,
                    createdAt: Date()
                )
                
                await MainActor.run {
                    messages.append(receivedMessage)
                    isLoading = false
                }
            }
        }
        
        func clearChat() {
            messages.removeAll()
            errorMessage = nil
        }
        
        func retryLastMessage() {
            guard let lastUserMessage = messages.last(where: { $0.role == .user }) else { return }
            
            // Remove the last assistant message if it exists and retry
            if messages.last?.role == .assistant {
                messages.removeLast()
            }
            
            currentInput = lastUserMessage.content
            sendMessage()
        }
    }
}
