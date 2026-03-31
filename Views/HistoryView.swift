import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()

            if appState.conversations.isEmpty {
                emptyState
            } else {
                conversationList
            }
        }
    }

    // MARK: - Subviews

    private var toolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .foregroundColor(.blue)
            }

            Spacer()

            Text("历史对话")
                .font(.headline)

            Spacer()

            Button {
                appState.startNewConversation()
                dismiss()
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private var emptyState: some View {
        Spacer()
            .overlay(
                Text("暂无历史对话")
                    .foregroundColor(.secondary)
                    .font(.body)
            )
    }

    private var conversationList: some View {
        List {
            ForEach(appState.conversations) { conv in
                ConversationRowView(conversation: conv)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.selectConversation(conv)
                        dismiss()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            appState.deleteConversation(id: conv.id)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Conversation Row

struct ConversationRowView: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(conversation.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(formattedDate(conversation.updatedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(conversation.lastMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(date) {
            return "昨天"
        } else {
            formatter.dateFormat = "MM/dd"
        }
        return formatter.string(from: date)
    }
}
