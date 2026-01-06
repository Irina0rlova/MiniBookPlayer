import ComposableArchitecture
import Foundation

@Reducer
struct MiniBookPlayerFeature {
    @Dependency(\.bookRepository) var bookRepository

    @ObservableState
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
        case restoredFromSnapshot(book: Book, snapshot: PlayerSnapshot)
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
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
                return .merge(
                    .send(.player(.loadCurrentTrack)),
                    .send(.player(.startListening))
                )

            case .appMovedToBackground:
                guard let player = state.player else { return .none }

                state.snapshot = state.player.map {
                    PlayerSnapshot(
                        bookId: $0.book.id,
                        keyPointIndex: $0.currentKeyPointIndex,
                        currentTime: $0.currentTime,
                        playbackRate: $0.playbackRate
                    )
                }
                guard let snapshot = state.snapshot else {
                    return .none
                }
                let isPlaying = player.isPlaying
                
                return .run { send in
                    do {
                        try await bookRepository.saveSnapshot(snapshot)
                        if isPlaying {
                            await send(.player(.playPauseTapped))
                        }
                    } catch {}
                }

            case .player(_):
                return .none

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
                return .run { send in
                    if let snapshot = try await bookRepository.loadSnapshot(),
                       let book = try? await bookRepository.loadBook() {
                        await send(.restoredFromSnapshot(book: book, snapshot: snapshot))
                    } else {
                        await send(.loadBook)
                    }
                }

            case let .restoredFromSnapshot(book, snapshot):
                state.isLoading = false
                state.book = book
                state.player = PlayerFeature.State(
                    book: book,
                    currentKeyPointIndex: snapshot.keyPointIndex,
                    isPlaying: false,
                    currentTime: snapshot.currentTime,
                    duration: nil,
                    playbackRate: snapshot.playbackRate
                )
                return .merge(
                    .send(.player(.loadCurrentTrack)),
                    .send(.player(.seek(to: snapshot.currentTime)))
                )
            }
        }
        .ifLet(\.player, action: \.player) {
            PlayerFeature()
        }
    }
}
