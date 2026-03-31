import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let role: String   // "user" or "assistant"
    var content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}
