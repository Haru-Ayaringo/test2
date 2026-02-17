import SwiftUI

@main
struct KyuseiRootApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
