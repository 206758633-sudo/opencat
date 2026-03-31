import SwiftUI

struct MessageBubbleView: View {
    let message: Message

    private var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser {
                Spacer(minLength: 60)
            } else {
                // Assistant avatar
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Text("AI")
                        .font(.caption2.bold())
                        .foregroundColor(.blue)
                }
            }

            Text(message.content)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(18)
                .textSelection(.enabled)

            if isUser {
                // User avatar
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            } else {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
    }
}
