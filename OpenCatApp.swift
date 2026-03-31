import SwiftUI

@main
struct OpenCatApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ChatView()
                .environmentObject(appState)
        }
    }
}
