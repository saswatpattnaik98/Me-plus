import Foundation
import SwiftUI
import SwiftData

@Model
class Subtask: Identifiable, Hashable {
    var id: UUID
    var name: String
    var isCompleted: Bool

    // Initializer
    init(name: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.name = name
        self.isCompleted = isCompleted
    }
}

