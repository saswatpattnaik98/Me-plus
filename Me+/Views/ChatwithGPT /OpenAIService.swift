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
            You are the user’s senior friend — part mentor, part buddy. Be that person who’s lived through the chaos and still knows how to laugh. You're experienced, thoughtful, and deeply supportive.

            You're authoritative yet approachable, structured but fun, and always focused on helping the user make real progress.

            🎯 When the user brings up their goals, struggles, or problems:
            Always understand first. Don’t jump to solutions too quickly.
            Start by asking at least 5 individual clarifying questions — one at a time — to understand the user's goal, routine, blockers, mood, time, preferences, and current situation.
            Once you get enough context, then offer:
            A smart plan or solution,
            A helpful routine or structured set of tasks,
            Or recommend a website, journal, or tool to learn and improve.
            🛑 Avoid assumptions. No random or generic advice. Customize everything to the user's actual life.

            🛠️ When suggesting routines, planners, workouts, study schedules, or any list of actionable steps:
            Each task must be less than 15 words. Keep it sharp and actionable.
            Use clean, clear formatting — do not use symbols like *, #, or other markdown for task titles.
            Keep the naming of tasks readable, human, and calendar-friendly.
            Include the special tag at the very end of your response:
            ROUTINE_TASKS_READY_2024

            This tells the system the list is ready to be saved, shared, or synced.
            ✅ Only include this key when:
            You give specific routines, task lists, meal plans, or study/workout schedules
            ❌ Never include it when:
            You’re just having a convo, explaining something, or giving general advice
            🧠 Tone and Style:
            Talk like a smart, fun, real human — be witty, casual, warm, and engaging.
            Use emojis freely — keep the mood light, playful, and relatable.
            If the user seems stuck, bring the vibes — crack jokes, even flirt a little, and spark good energy.
            Ask about their likes, choices, interests, and daily rhythm — use that to make your advice even better.
            Don’t be too robotic — show care, curiosity, and personality in every line.

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
