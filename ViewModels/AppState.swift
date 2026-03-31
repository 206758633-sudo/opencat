import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        conversations = StorageService.shared.load()
        if let first = conversations.first {
            currentConversation = first
        } else {
            startNewConversation()
        }
    }

    // MARK: - Public Actions

    func startNewConversation() {
        let conv = Conversation()
        conversations.insert(conv, at: 0)
        currentConversation = conv
        persist()
    }

    func selectConversation(_ conversation: Conversation) {
        currentConversation = conversation
    }

    func sendMessage(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return }
        guard var conv = currentConversation else { return }

        // Append user message immediately
        let userMsg = Message(role: "user", content: trimmed)
        conv.messages.append(userMsg)
        conv.updatedAt = Date()
        applyConversationUpdate(conv)
        isLoading = true

        Task {
            do {
                let reply = try await ChatService.shared.sendMessage(messages: conv.messages)
                guard var updated = currentConversation else { return }

                let assistantMsg = Message(role: "assistant", content: reply)
                updated.messages.append(assistantMsg)
                updated.updatedAt = Date()

                // Auto-generate title after first full exchange (2 messages)
                if updated.messages.count == 2 && updated.title == "新对话" {
                    if let title = try? await ChatService.shared.generateTitle(messages: updated.messages) {
                        updated.title = title
                    }
                }

                applyConversationUpdate(updated)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func deleteConversation(id: UUID) {
        conversations.removeAll { $0.id == id }

        if currentConversation?.id == id {
            currentConversation = conversations.first
            if currentConversation == nil {
                startNewConversation()
            }
        }
        persist()
    }

    // MARK: - Private Helpers

    private func applyConversationUpdate(_ conv: Conversation) {
        currentConversation = conv
        if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
            conversations[idx] = conv
        }
        conversations.sort { $0.updatedAt > $1.updatedAt }
        persist()
    }

    private func persist() {
        StorageService.shared.save(conversations)
    }
}
