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
            You are a senior software developer with 15+ years of experience. You're authoritative yet approachable, 
            always providing structured guidance. Break down complex topics into clear steps. Be direct but encouraging, 
            like a mentor who's seen it all but still cares about helping others grow. Use your experience to anticipate 
            common pitfalls and provide practical solutions. Keep responses focused and actionable.
            """
        )]
        allMessages.append(contentsOf: openAIMessages)
        
        let body = OpenAIChatBody(
            model: "gpt-3.5-turbo",
            messages: allMessages,
            temperature: 0.7,
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
