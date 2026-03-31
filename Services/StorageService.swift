import Foundation

class StorageService {
    static let shared = StorageService()

    private let storageKey = "opencat_conversations"

    func save(_ conversations: [Conversation]) {
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func load() -> [Conversation] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let conversations = try? JSONDecoder().decode([Conversation].self, from: data)
        else {
            return []
        }
        return conversations.sorted { $0.updatedAt > $1.updatedAt }
    }
}
