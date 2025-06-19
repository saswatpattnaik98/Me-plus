import SwiftUI
import SwiftData
// MARK: - Enhanced Chat ViewModel with Smart Planner Detection
extension ChatView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var messages: [Mesaage] = []
        @Published var currentInput: String = ""
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var parsedTasks: [ParsedTask] = []
        @Published var showTasksSaveDialog: Bool = false
        @Published var showAddTasksButton: Bool = false // New property for button visibility
        
         let openAIService = OpenAlService()
        
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
                    
                    // Smart detection for complete planners/routines
                    let isCompletePlanner = detectCompletePlanner(receivedOpenAIMessage.content)
                    
                    if isCompletePlanner {
                        // Parse tasks from AI response
                        parsedTasks = parseTasksFromResponse(receivedOpenAIMessage.content)
                        showAddTasksButton = !parsedTasks.isEmpty
                    } else {
                        showAddTasksButton = false
                    }
                    
                    isLoading = false
                }
            }
        }
        
        // MARK: - Smart Planner Detection Logic
        private func detectCompletePlanner(_ content: String) -> Bool {
            let lowercaseContent = content.lowercased()
            let wordCount = content.split(separator: " ").count
            
            // Must be substantial content (at least 100 words)
            guard wordCount >= 100 else { return false }
            
            // Check for planner/routine indicators
            let plannerIndicators = [
                "here's your", "here is your", "here's a", "here is a",
                "workout plan", "routine for", "schedule for", "planner for",
                "daily routine", "weekly routine", "fitness plan", "exercise plan",
                "study schedule", "learning plan", "meal plan", "training program"
            ]
            
            let hasPlannerIndicator = plannerIndicators.contains { indicator in
                lowercaseContent.contains(indicator)
            }
            
            // Count structured elements (numbered lists, bullet points, etc.)
            let structuredPatterns = [
                #"^\d+\.\s*.+"#,           // 1. Something
                #"^[-*•]\s*.+"#,           // - Something
                #"^day\s*\d+:"#,           // Day 1:
                #"^week\s*\d+:"#,          // Week 1:
                #"^\d+:\d+\s*(am|pm)?"#    // Time formats
            ]
            
            let lines = content.components(separatedBy: .newlines)
            var structuredLines = 0
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                for pattern in structuredPatterns {
                    if trimmedLine.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                        structuredLines += 1
                        break
                    }
                }
            }
            
            // Must have planner indicator AND at least 3 structured lines
            return hasPlannerIndicator && structuredLines >= 3
        }
        
        // MARK: - Updated Task Line Detection (More Precise)
        private func isTaskLine(_ line: String) -> Bool {
            // Pattern matching for tasks
            let taskPatterns = [
                #"^\d+\.\s*.{10,}"#,              // 1. Task name (at least 10 chars)
                #"^[-*•]\s*.{10,}"#,              // - Task name (at least 10 chars)
                #"^\[\s*\]\s*.{10,}"#,            // [ ] Task name (at least 10 chars)
                #"^(Day|Week)\s*\d+:\s*.{10,}"#,  // Day 1: Task name
                #"^\d+:\d+\s*(AM|PM|am|pm)?\s*-\s*.{10,}"# // Time-based tasks
            ]
            
            for pattern in taskPatterns {
                if line.range(of: pattern, options: .regularExpression) != nil {
                    return true
                }
            }
            
            return false
        }
        
        // MARK: - Manual Add Tasks Function
        func showAddTasksManually() {
            // Parse tasks from the last AI message
            if let lastAssistantMessage = messages.last(where: { $0.role == .assistant }) {
                parsedTasks = parseTasksFromResponse(lastAssistantMessage.content)
                if !parsedTasks.isEmpty {
                    showTasksSaveDialog = true
                } else {
                    errorMessage = "No tasks found in the current response."
                }
            }
        }
        
        // MARK: - Reset Add Tasks Button
        func resetAddTasksButton() {
            showAddTasksButton = false
            parsedTasks.removeAll()
        }
        
        // MARK: - Task Parsing Logic (Same as before)
        private func parseTasksFromResponse(_ content: String) -> [ParsedTask] {
            var tasks: [ParsedTask] = []
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines
                guard !trimmedLine.isEmpty else { continue }
                
                // Check if line looks like a task (various patterns)
                if isTaskLine(trimmedLine) {
                    let taskName = cleanTaskName(trimmedLine)
                    let duration = extractDuration(trimmedLine)
                    let suggestedDate = extractDate(from: content, taskLine: trimmedLine)
                    
                    let task = ParsedTask(
                        name: taskName,
                        duration: duration,
                        suggestedDate: suggestedDate,
                        originalLine: trimmedLine
                    )
                    tasks.append(task)
                }
            }
            
            return tasks
        }
        
        private func cleanTaskName(_ line: String) -> String {
            var cleaned = line
            
            // Remove common prefixes
            let prefixPatterns = [
                #"^\d+\.\s*"#,           // 1.
                #"^[-*•]\s*"#,           // - or * or •
                #"^\[\s*\]\s*"#,         // [ ]
                #"^(Day|Week)\s*\d+:\s*"#,  // Day 1: or Week 1:
                #"^(Task|Step|Activity):\s*"#  // Task:
            ]
            
            for pattern in prefixPatterns {
                cleaned = cleaned.replacingOccurrences(
                    of: pattern,
                    with: "",
                    options: .regularExpression
                )
            }
            
            // Remove time information if present
            cleaned = cleaned.replacingOccurrences(
                of: #"\d+:\d+\s*(AM|PM|am|pm)?\s*-?\s*"#,
                with: "",
                options: .regularExpression
            )
            
            return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        private func extractDuration(_ line: String) -> Int {
            // Look for duration patterns (15 min, 30 minutes, 1 hour, etc.)
            let patterns = [
                #"(\d+)\s*min"#,
                #"(\d+)\s*minute"#,
                #"(\d+)\s*hour"#,
                #"(\d+)\s*hr"#
            ]
            
            for pattern in patterns {
                if let match = line.range(of: pattern, options: .regularExpression) {
                    let matchedText = String(line[match])
                    if let number = Int(matchedText.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) {
                        if matchedText.lowercased().contains("hour") || matchedText.lowercased().contains("hr") {
                            return number * 60 // Convert hours to minutes
                        }
                        return number
                    }
                }
            }
            
            return 30 // Default duration
        }
        
        // MARK: - Enhanced Date Extraction
        private func extractDate(from content: String, taskLine: String) -> Date {
            let calendar = Calendar.current
            let today = Date()
            
            // Look for specific day references in both content and task line
            let dayPatterns = [
                ("tomorrow", 1),
                ("next day", 1),
                ("monday", daysUntilWeekday(1)),
                ("tuesday", daysUntilWeekday(2)),
                ("wednesday", daysUntilWeekday(3)),
                ("thursday", daysUntilWeekday(4)),
                ("friday", daysUntilWeekday(5)),
                ("saturday", daysUntilWeekday(6)),
                ("sunday", daysUntilWeekday(7))
            ]
            
            // Check task line first for more specific date
            let taskLineText = taskLine.lowercased()
            for (dayName, daysToAdd) in dayPatterns {
                if taskLineText.contains(dayName) {
                    return calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
                }
            }
            
            // Then check the full content
            let combinedText = content.lowercased()
            for (dayName, daysToAdd) in dayPatterns {
                if combinedText.contains(dayName) {
                    return calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
                }
            }
            
            // Look for date patterns like "Day 1", "Day 2", etc.
            if let dayMatch = taskLine.range(of: #"day\s*(\d+)"#, options: [.regularExpression, .caseInsensitive]) {
                let dayText = String(taskLine[dayMatch])
                if let dayNumber = Int(dayText.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) {
                    return calendar.date(byAdding: .day, value: dayNumber - 1, to: today) ?? today
                }
            }
            
            // Look for week patterns
            if let weekMatch = taskLine.range(of: #"week\s*(\d+)"#, options: [.regularExpression, .caseInsensitive]) {
                let weekText = String(taskLine[weekMatch])
                if let weekNumber = Int(weekText.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) {
                    return calendar.date(byAdding: .day, value: (weekNumber - 1) * 7, to: today) ?? today
                }
            }
            
            return today // Default to today - will be distributed by saveTasksToTodoApp
        }
        
        private func daysUntilWeekday(_ targetWeekday: Int) -> Int {
            let calendar = Calendar.current
            let today = Date()
            let currentWeekday = calendar.component(.weekday, from: today)
            
            let daysUntil = (targetWeekday - currentWeekday + 7) % 7
            return daysUntil == 0 ? 7 : daysUntil // If today, schedule for next week
        }
        
        // MARK: - Save to SwiftData
        func saveTasksToTodoApp(_ selectedTasks: [ParsedTask], modelContext: ModelContext) {
            let calendar = Calendar.current
            let today = Date()
            
            // Sort tasks to maintain consistent ordering
            let sortedTasks = selectedTasks.sorted { $0.name < $1.name }
            
            for (index, task) in sortedTasks.enumerated() {
                var taskDate: Date
                
                // Check if task has a specific date mentioned (not today)
                let isSpecificDate = !calendar.isDate(task.suggestedDate, inSameDayAs: today)
                
                if isSpecificDate {
                    // Use the specific date if mentioned in the task
                    taskDate = task.suggestedDate
                } else {
                    // Distribute tasks starting from today, one per day
                    taskDate = calendar.date(byAdding: .day, value: index, to: today) ?? today
                }
                
                let newActivity = Activity(
                    name: task.name,
                    date: taskDate,
                    duration: task.duration,
                    colorName: Activity.randomColorName(),
                    isCompleted: false
                )
                
                modelContext.insert(newActivity)
            }
            
            do {
                try modelContext.save()
                parsedTasks.removeAll()
                showTasksSaveDialog = false
                showAddTasksButton = false // Hide button after saving
            } catch {
                errorMessage = "Failed to save tasks: \(error.localizedDescription)"
            }
        }
        
        func clearChat() {
            messages.removeAll()
            errorMessage = nil
            parsedTasks.removeAll()
            showTasksSaveDialog = false
            showAddTasksButton = false
        }
        
        func retryLastMessage() {
            guard let lastUserMessage = messages.last(where: { $0.role == .user }) else { return }
            
            if messages.last?.role == .assistant {
                messages.removeLast()
            }
            
            currentInput = lastUserMessage.content
            sendMessage()
        }
    }
}
