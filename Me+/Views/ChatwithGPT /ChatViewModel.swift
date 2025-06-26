import SwiftUI
import SwiftData

// MARK: - Enhanced Chat ViewModel with Unique Task Key Detection
extension ChatView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var messages: [Mesaage] = []
        @Published var currentInput: String = ""
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var parsedTasks: [ParsedTask] = []
        @Published var showTasksSaveDialog: Bool = false
        @Published var showAddTasksButton: Bool = false
        
        let openAIService = OpenAlService()
        
        // Unique task key that AI should include when providing actual tasks/routines
        private let TASK_KEY = "ROUTINE_TASKS_READY_2024"
        
        func sendMessage() {
            let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            let messageToSend = trimmed
            currentInput = ""
            isLoading = true
            errorMessage = nil

            let newMessage = Mesaage(id: UUID(), role: .user, content: messageToSend, createdAt: Date())
            messages.append(newMessage)

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

                    if receivedOpenAIMessage.content.contains(TASK_KEY) {
                        parsedTasks = parseTasksFromResponse(receivedOpenAIMessage.content)
                        showAddTasksButton = !parsedTasks.isEmpty
                    } else {
                        showAddTasksButton = false
                        parsedTasks.removeAll()
                    }

                    isLoading = false
                }
            }
        }

        
        // MARK: - Get Task Key (for UI to display instructions)
        func getTaskKey() -> String {
            return TASK_KEY
        }
        
        // MARK: - Check if message contains task key
        func containsTaskKey(_ content: String) -> Bool {
            return content.contains(TASK_KEY)
        }
        
        // MARK: - Clean message content (remove task key for display)
        func cleanMessageContent(_ content: String) -> String {
            return content.replacingOccurrences(of: TASK_KEY, with: "")
                          .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // MARK: - Improved Task Line Detection
        private func isTaskLine(_ line: String) -> Bool {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines or lines that are too short to be meaningful tasks
            guard !trimmedLine.isEmpty && trimmedLine.count >= 5 else { return false }
            
            // Pattern matching for common task formats
            let taskPatterns = [
                #"^\d+\.\s*.{5,}"#,                    // 1. Task name (at least 5 chars)
                #"^[-*•]\s*.{5,}"#,                    // - Task name (at least 5 chars)
                #"^\[\s*\]\s*.{5,}"#,                  // [ ] Task name (at least 5 chars)
                #"^(Day|Week)\s*\d+:\s*.{5,}"#,        // Day 1: Task name
                #"^\d+:\d+\s*(AM|PM|am|pm)?\s*-\s*.{5,}"#, // Time-based tasks
                #"^(Morning|Afternoon|Evening):\s*.{5,}"#,  // Time period tasks
                #"^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday):\s*.{5,}"# // Day-based tasks
            ]
            
            for pattern in taskPatterns {
                if trimmedLine.range(of: pattern, options: .regularExpression) != nil {
                    return true
                }
            }
            
            // Additional check for workout/exercise specific patterns
            let workoutPatterns = [
                #"^\d+\s*x\s*\d+\s*.{5,}"#,           // 3 x 10 Push ups
                #"^\d+\s*(reps?|sets?|minutes?|mins?|seconds?|secs?)\s*.{5,}"#, // 10 reps Push ups
            ]
            
            for pattern in workoutPatterns {
                if trimmedLine.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                    return true
                }
            }
            
            return false
        }
        
        // MARK: - Manual Add Tasks Function
        func showAddTasksManually() {
            // Parse tasks from the last AI message that contains the task key
            if let lastAssistantMessage = messages.last(where: { $0.role == .assistant && containsTaskKey($0.content) }) {
                parsedTasks = parseTasksFromResponse(lastAssistantMessage.content)
                if !parsedTasks.isEmpty {
                    showTasksSaveDialog = true
                } else {
                    errorMessage = "No valid tasks found in the response."
                }
            } else {
                errorMessage = "No task list found. Please ask the AI to create a specific routine or task list."
            }
        }
        
        // MARK: - Reset Add Tasks Button
        func resetAddTasksButton() {
            showAddTasksButton = false
            parsedTasks.removeAll()
        }
        
        // MARK: - Enhanced Task Parsing Logic
        private func parseTasksFromResponse(_ content: String) -> [ParsedTask] {
            var tasks: [ParsedTask] = []
            let lines = content.components(separatedBy: .newlines)
            
            // First, try to identify sections or categories
            var currentSection = ""
            var dayCounter = 0
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines and the task key
                guard !trimmedLine.isEmpty && !trimmedLine.contains(TASK_KEY) else { continue }
                
                // Check for section headers (Day 1, Week 1, Morning Routine, etc.)
                if isSectionHeader(trimmedLine) {
                    currentSection = trimmedLine
                    if trimmedLine.lowercased().contains("day") {
                        dayCounter += 1
                    }
                    continue
                }
                
                // Check if line looks like a task
                if isTaskLine(trimmedLine) {
                    let taskName = cleanTaskName(trimmedLine)
                    
                    // Skip if task name is too short after cleaning
                    guard taskName.count >= 3 else { continue }
                    
                    let duration = extractDuration(trimmedLine)
                    let suggestedDate = extractDate(from: content, taskLine: trimmedLine, section: currentSection, dayNumber: dayCounter)
                    
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
        
        // MARK: - Section Header Detection
        private func isSectionHeader(_ line: String) -> Bool {
            let headerPatterns = [
                #"^(Day|Week)\s*\d+:?\s*$"#,
                #"^(Morning|Afternoon|Evening|Night)\s*(Routine|Workout|Session)?:?\s*$"#,
                #"^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s*(Routine|Workout|Session)?:?\s*$"#,
                #"^(Warm-up|Cool-down|Cardio|Strength|Flexibility):?\s*$"#
            ]
            
            for pattern in headerPatterns {
                if line.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                    return true
                }
            }
            
            return false
        }
        
        // MARK: - Enhanced Task Name Cleaning
        private func cleanTaskName(_ line: String) -> String {
            var cleaned = line
            
            // Remove common prefixes
            let prefixPatterns = [
                #"^\d+\.\s*"#,                        // 1.
                #"^[-*•]\s*"#,                        // - or * or •
                #"^\[\s*\]\s*"#,                      // [ ]
                #"^(Day|Week)\s*\d+:\s*"#,            // Day 1: or Week 1:
                #"^(Task|Step|Activity|Exercise):\s*"#, // Task:
                #"^(Morning|Afternoon|Evening):\s*"#,  // Morning:
                #"^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday):\s*"# // Monday:
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
            
            // Remove workout-specific patterns that might be at the beginning
            cleaned = cleaned.replacingOccurrences(
                of: #"^\d+\s*x\s*\d+\s*"#,
                with: "",
                options: .regularExpression
            )
            
            return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // MARK: - Enhanced Duration Extraction
        private func extractDuration(_ line: String) -> Int {
            // Look for duration patterns
            let patterns = [
                (#"(\d+)\s*min(ute)?s?"#, 1),          // minutes
                (#"(\d+)\s*hour?s?"#, 60),             // hours (convert to minutes)
                (#"(\d+)\s*hr?s?"#, 60),               // hours abbreviated
                (#"(\d+)\s*sec(ond)?s?"#, 1),          // seconds (convert to minutes, minimum 1)
                (#"(\d+)\s*x\s*(\d+)"#, 1)             // reps format like "3 x 10"
            ]
            
            for (pattern, multiplier) in patterns {
                if let match = line.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                    let matchedText = String(line[match])
                    let numbers = matchedText.components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .compactMap { Int($0) }
                    
                    if let firstNumber = numbers.first {
                        if pattern.contains("sec") {
                            return max(1, firstNumber / 60) // Convert seconds to minutes, minimum 1
                        } else if pattern.contains("x") && numbers.count >= 2 {
                            // For exercise patterns like "3 x 10", estimate based on sets
                            return max(5, numbers[0] * 2) // Rough estimate: sets * 2 minutes
                        } else {
                            return firstNumber * multiplier
                        }
                    }
                }
            }
            
            // Default duration based on task type
            let lowercaseLine = line.lowercased()
            if lowercaseLine.contains("run") || lowercaseLine.contains("cardio") || lowercaseLine.contains("jog") {
                return 30 // Default cardio duration
            } else if lowercaseLine.contains("meditat") || lowercaseLine.contains("stretch") {
                return 15 // Default meditation/stretching duration
            } else if lowercaseLine.contains("read") || lowercaseLine.contains("study") {
                return 45 // Default reading/study duration
            }
            
            return 30 // Default duration
        }
        
        // MARK: - Enhanced Date Extraction
        private func extractDate(from content: String, taskLine: String, section: String, dayNumber: Int) -> Date {
            let calendar = Calendar.current
            let today = Date()
            
            // Priority 1: Check task line for specific day references
            let taskLineText = taskLine.lowercased()
            if let specificDate = extractSpecificDayFromText(taskLineText, from: today) {
                return specificDate
            }
            
            // Priority 2: Check section header for day references
            if !section.isEmpty {
                let sectionText = section.lowercased()
                if let specificDate = extractSpecificDayFromText(sectionText, from: today) {
                    return specificDate
                }
                
                // Handle "Day X" patterns in section
                if let dayMatch = section.range(of: #"day\s*(\d+)"#, options: [.regularExpression, .caseInsensitive]) {
                    let dayText = String(section[dayMatch])
                    if let dayNum = Int(dayText.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)) {
                        return calendar.date(byAdding: .day, value: dayNum - 1, to: today) ?? today
                    }
                }
            }
            
            // Priority 3: Use day counter from parsing
            if dayNumber > 0 {
                return calendar.date(byAdding: .day, value: dayNumber - 1, to: today) ?? today
            }
            
            // Priority 4: Check full content for general day references
            let combinedText = content.lowercased()
            if let specificDate = extractSpecificDayFromText(combinedText, from: today) {
                return specificDate
            }
            
            return today // Default to today
        }
        
        // MARK: - Extract Specific Day from Text
        private func extractSpecificDayFromText(_ text: String, from baseDate: Date) -> Date? {
            let calendar = Calendar.current
            
            let dayPatterns = [
                ("tomorrow", 1),
                ("next day", 1),
                ("monday", daysUntilWeekday(2, from: baseDate)),    // Calendar weekday: Sunday=1, Monday=2
                ("tuesday", daysUntilWeekday(3, from: baseDate)),
                ("wednesday", daysUntilWeekday(4, from: baseDate)),
                ("thursday", daysUntilWeekday(5, from: baseDate)),
                ("friday", daysUntilWeekday(6, from: baseDate)),
                ("saturday", daysUntilWeekday(7, from: baseDate)),
                ("sunday", daysUntilWeekday(1, from: baseDate))
            ]
            
            for (dayName, daysToAdd) in dayPatterns {
                if text.contains(dayName) {
                    return calendar.date(byAdding: .day, value: daysToAdd, to: baseDate)
                }
            }
            
            return nil
        }
        
        // MARK: - Calculate Days Until Weekday
        private func daysUntilWeekday(_ targetWeekday: Int, from date: Date) -> Int {
            let calendar = Calendar.current
            let currentWeekday = calendar.component(.weekday, from: date)
            
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
                showAddTasksButton = false
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
