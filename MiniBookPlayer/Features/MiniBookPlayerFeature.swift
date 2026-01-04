import ComposableArchitecture
import Foundation

struct MiniBookPlayerFeature: Reducer {
    @Dependency(\.bookRepository) var bookRepository
    
    private let playerFeature = PlayerFeature()
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.isLoading = true
            return .send(.loadBook)
            
        case .bookLoaded(let book):
            state.isLoading = false
            state.book = book
            state.player = PlayerFeature.State(
                book: book,
                currentKeyPointIndex: 0,
                isPlaying: false,
                currentTime: 0,
                duration: nil,
                playbackRate: 1.0
            )
            return .none
            
        case .appMovedToBackground:
            state.snapshot = state.player.map {
                PlayerSnapshot(
                    bookId: $0.book.id,
                    keyPointIndex: $0.currentKeyPointIndex,
                    currentTime: $0.currentTime,
                    playbackRate: $0.playbackRate
                )
            }
            return .none
            
        case .player(let playerAction):
            guard (state.player != nil) else { return .none }
            return playerFeature
                .reduce(into: &state.player!, action: playerAction)
                .map(MiniBookPlayerFeature.Action.player)
            
        case .loadBook:
            return .run { send in
                do {
                    let book = try await bookRepository.loadBook()
                    await send(.bookLoaded(book))
                } catch let error {
                    await send(.loadingFailed(error.localizedDescription))
                }
            }
        case .loadingFailed(let message):
            state.isLoading = false
            state.error = message
            state.book = nil
            state.player = nil
            return .none
            
        case .appReturnedToForeground:
            return .none
        }
    }
    
    struct State: Equatable {
            var book: Book?
            var player: PlayerFeature.State?

            var isLoading: Bool = false
            var error: String?

            var snapshot: PlayerSnapshot?
        }
    
    enum Action: Equatable {
        case onAppear

        // Loading
        case loadBook
        case bookLoaded(Book)
        case loadingFailed(String)

        // Player
        case player(PlayerFeature.Action)

        // Lifecycle
        case appMovedToBackground
        case appReturnedToForeground
    }
}
