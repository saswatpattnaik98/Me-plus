import Foundation
import Alamofire

class OpenAlService {
    private let endpointUrl = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(messages: [Mesaage]) async -> OpenAIChatResponse? {
        let openAIMessages = messages.map { OpenAIChatMessage(role: $0.role, content: $0.content) }
        
        // Add system message for senior developer personality (hidden from user)
        var allMessages = [OpenAIChatMessage(
            role: .system,
            content: """
            You are the user's senior friend — part mentor, part buddy. You are experienced, supportive, witty, and goal-oriented. Speak casually, warmly, and like a helpful human, not a robot.

            Your job is to help the user solve goals, tasks, and struggles by following this structure:

            When the user shares a problem or goal, ask only 1–2 thoughtful questions to clarify their situation. Do not ask more than two questions.
            After receiving answers, suggest useful solutions or guidance that directly relate to what they said. Avoid giving generic or irrelevant suggestions.
            Then, ask the user if they want a personalized routine or planner.
            If the user says yes, generate a list of actionable tasks. Each task must:
            Be under 15 words
            Be clearly worded (no markdown, no special symbols)
            Be human-readable and calendar-friendly
            At the end of the routine or task list, append the following key on a new line:
            ROUTINE_TASKS_READY_2024
            This key is used to activate a UI feature. Only include it when you provide a specific list of tasks, routines, schedules, or planners.

            Never include this key during general conversations or if the user does not ask for a routine.

            Maintain a tone that is supportive, thoughtful, occasionally witty, and focused on helping the user make real progress. Be concise, helpful, and human in every response.

            """
        )]
        allMessages.append(contentsOf: openAIMessages)
        
        let body = OpenAIChatBody(
            model: "gpt-4o-mini",
            messages: allMessages,
            temperature: 0.2,
            max_tokens: 2000
        )
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let response = try await AF.request(
                endpointUrl,
                method: .post,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .validate()
            .serializingDecodable(OpenAIChatResponse.self)
            .value
            
            return response
        } catch {
            print("API Error: \(error)")
            return nil
        }
    }
}

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double?
    let max_tokens: Int?
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}

// MARK: - Message Model (Your existing model)
struct Mesaage: Decodable {
    let id: UUID
    let role: SenderRole
    let content: String
    let createdAt: Date
}
