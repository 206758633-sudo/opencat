import Foundation

class ChatService {
    static let shared = ChatService()

    private let apiKey = "sk-rbxrfajipmvmchiuxcjkdekeyjmciswgfrjvvktlwunaotur"
    private let baseURL = "https://api.siliconflow.cn/v1/chat/completions"
    private let model = "deepseek-ai/DeepSeek-V3.2"

    enum ChatError: LocalizedError {
        case serverError(Int)
        case invalidResponse
        case decodingError

        var errorDescription: String? {
            switch self {
            case .serverError(let code): return "服务器错误: \(code)"
            case .invalidResponse: return "无效的响应"
            case .decodingError: return "数据解析失败"
            }
        }
    }

    // Send messages and return assistant reply
    func sendMessage(messages: [Message]) async throws -> String {
        let requestMessages = messages.map { ["role": $0.role, "content": $0.content] }

        let body: [String: Any] = [
            "model": model,
            "messages": requestMessages,
            "stream": false
        ]

        let data = try await performRequest(body: body)
        return try extractContent(from: data)
    }

    // Generate a short title based on first exchange
    func generateTitle(messages: [Message]) async throws -> String {
        let context = messages.prefix(4)
            .map { "\($0.role == "user" ? "用户" : "助手"): \($0.content)" }
            .joined(separator: "\n")

        let prompt = "请根据以下对话内容，生成一个简短的对话主题（不超过10个字，只输出主题文字，不加引号）：\n\(context)"

        let body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]],
            "stream": false,
            "max_tokens": 30
        ]

        let data = try await performRequest(body: body)
        return try extractContent(from: data).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Private Helpers

    private func performRequest(body: [String: Any]) async throws -> Data {
        guard let url = URL(string: baseURL) else { throw ChatError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw ChatError.serverError(httpResponse.statusCode)
        }

        return data
    }

    private func extractContent(from data: Data) throws -> String {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let first = choices.first,
            let message = first["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw ChatError.decodingError
        }
        return content
    }
}
