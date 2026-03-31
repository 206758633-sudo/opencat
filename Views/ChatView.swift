import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputText = ""
    @State private var showHistory = false
    @FocusState private var isInputFocused: Bool

    private var conversation: Conversation {
        appState.currentConversation ?? Conversation()
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            messageList
            Divider()
            inputBar
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .alert("发送失败", isPresented: Binding(
            get: { appState.errorMessage != nil },
            set: { if !$0 { appState.errorMessage = nil } }
        )) {
            Button("确定", role: .cancel) { appState.errorMessage = nil }
        } message: {
            Text(appState.errorMessage ?? "")
        }
    }

    // MARK: - Subviews

    private var toolbar: some View {
        HStack {
            Button {
                showHistory = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            Spacer()

            Text(conversation.title)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            Button {
                appState.startNewConversation()
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

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(conversation.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }

                    if appState.isLoading {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Text("AI")
                                    .font(.caption2.bold())
                                    .foregroundColor(.blue)
                            }
                            ProgressView()
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .cornerRadius(18)
                            Spacer(minLength: 60)
                        }
                        .padding(.horizontal, 12)
                        .id("loading")
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: conversation.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: appState.isLoading) { loading in
                if loading {
                    withAnimation { proxy.scrollTo("loading", anchor: .bottom) }
                } else {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onTapGesture {
                isInputFocused = false
            }
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("输入消息...", text: $inputText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .focused($isInputFocused)

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(canSend ? .blue : Color(.systemGray3))
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    // MARK: - Helpers

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !appState.isLoading
    }

    private func send() {
        let text = inputText
        inputText = ""
        appState.sendMessage(text)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = conversation.messages.last {
            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
        }
    }
}
