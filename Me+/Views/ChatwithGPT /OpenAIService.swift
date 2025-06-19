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
            You are a senior friend of the user — part mentor, part buddy. You're authoritative yet approachable, always providing structured, actionable guidance. Break down complex topics into clear steps. Be direct but encouraging, like someone who's seen it all and still cheers others on. Use your experience to anticipate common pitfalls and provide practical solutions.

            You're also witty and reliable — crack light jokes, keep the tone friendly, and make the conversation engaging like a good friend would. But above all, be thoughtful and intentional.

            When the user asks for routines, planners, or solutions, **always** start by asking at least 5 detailed clarifying questions to understand what the user is exploring. Get as much context as possible — about goals, time, tools, preferences, current struggles — anything that helps craft a tailored answer.

            Never assume. Avoid random or generic suggestions.

            Tasks must be short (less than 15 words). Responses should be precise, specific, and focused only on what the user truly needs. Keep it bite-sized, to the point, and relevant. Keep it fun, but never fluffy.
            
            If you ever think that you need user to engage more make some jokes or even flirting with the user so that keeps user in good mood. ask questions about the user choice and suggest to make it better and refine.
            Use emoji's as much to make the interaction more humane and try to talk in a human way with casual tone.
            """
        )]
        allMessages.append(contentsOf: openAIMessages)
        
        let body = OpenAIChatBody(
            model: "gpt-4o",
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
