import SwiftUI
import ComposableArchitecture

@main
struct MiniBookPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            MiniBookPlayerView(
                store: Store(
                    initialState: MiniBookPlayerFeature.State(),
                    reducer: {
                        MiniBookPlayerFeature()
                    }
                )
            )
        }
    }
}
