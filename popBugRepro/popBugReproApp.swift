import SwiftUI
import ComposableArchitecture

@main
struct popBugReproApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState(),
                                     reducer: appReducer,
                                     environment: ()))
        }
    }
}
