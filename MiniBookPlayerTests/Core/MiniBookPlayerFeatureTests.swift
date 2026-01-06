import XCTest
import ComposableArchitecture
@testable import MiniBookPlayer

@MainActor
final class MiniBookPlayerFeatureTests: XCTestCase {

    // MARK: - Test Data

    private func makeTestBook() -> Book {
        Book(
            id: "test-book-1",
            title: "The Test Book",
            author: "Test Author",
            coverImageURL: URL(string: "https://example.com/cover.jpg"),
            keyPoints: [
                KeyPoint(
                    id: "kp-1",
                    title: "First Key Point",
                    order: 0,
                    audioSource: .local(fileName: "audio1.mp3")
                ),
                KeyPoint(
                    id: "kp-2",
                    title: "Second Key Point",
                    order: 1,
                    audioSource: .local(fileName: "audio2.mp3")
                )
            ]
        )
    }

    // MARK: - onAppear Tests

    func testOnAppear_setsLoadingAndSendsLoadBookAction() async {
        let store = TestStore(initialState: MiniBookPlayerFeature.State()) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.loadBook)
    }

    // MARK: - bookLoaded Tests

    func testBookLoaded_setsBookAndCreatesPlayerState() async {
        let testBook = makeTestBook()

        let store = TestStore(initialState: MiniBookPlayerFeature.State(isLoading: true)) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.bookLoaded(testBook)) {
            $0.isLoading = false
            $0.book = testBook
            $0.player = PlayerFeature.State(
                book: testBook,
                currentKeyPointIndex: 0,
                isPlaying: false,
                currentTime: 0,
                duration: nil,
                playbackRate: 1.0
            )
        }

        await store.receive(.player(.loadCurrentTrack))
        await store.receive(.player(.startListening))
    }

    // MARK: - loadBook Tests

    func testLoadBook_loadsBookSuccessfully() async {
        let testBook = makeTestBook()

        let store = TestStore(initialState: MiniBookPlayerFeature.State()) {
            MiniBookPlayerFeature()
        } withDependencies: {
            $0.bookRepository = BookRepository(
                loadBook: { testBook },
                loadSnapshot: { nil },
                saveSnapshot: { _ in }
            )
        }
        store.exhaustivity = .off

        await store.send(.loadBook)

        await store.receive(\.bookLoaded, timeout: .seconds(1)) {
            $0.book = testBook
            $0.player = PlayerFeature.State(
                book: testBook,
                currentKeyPointIndex: 0,
                isPlaying: false,
                currentTime: 0,
                duration: nil,
                playbackRate: 1.0
            )
        }

        await store.receive(.player(.loadCurrentTrack))
        await store.receive(.player(.startListening))
    }

    func testLoadBook_handlesError() async {
        enum TestError: Error, Equatable {
            case loadFailed
        }

        let store = TestStore(initialState: MiniBookPlayerFeature.State()) {
            MiniBookPlayerFeature()
        } withDependencies: {
            $0.bookRepository = BookRepository(
                loadBook: { throw TestError.loadFailed },
                loadSnapshot: { nil },
                saveSnapshot: { _ in }
            )
        }
        store.exhaustivity = .off

        await store.send(.loadBook)

        await store.receive(\.loadingFailed, timeout: .seconds(1)) {
            $0.error = TestError.loadFailed.localizedDescription
        }
    }

    // MARK: - loadingFailed Tests

    func testLoadingFailed_setsErrorAndClearsState() async {
        let store = TestStore(
            initialState: MiniBookPlayerFeature.State(
                book: makeTestBook(),
                isLoading: true
            )
        ) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.loadingFailed("Network error")) {
            $0.isLoading = false
            $0.error = "Network error"
            $0.book = nil
            $0.player = nil
        }
    }

    // MARK: - appMovedToBackground Tests

    func testAppMovedToBackground_createsSnapshot() async {
        let testBook = makeTestBook()

        let store = TestStore(
            initialState: MiniBookPlayerFeature.State(
                book: testBook,
                player: PlayerFeature.State(
                    book: testBook,
                    currentKeyPointIndex: 1,
                    isPlaying: true,
                    currentTime: 45.5,
                    duration: 120.0,
                    playbackRate: 1.5
                )
            )
        ) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.appMovedToBackground) {
            $0.snapshot = PlayerSnapshot(
                bookId: testBook.id,
                keyPointIndex: 1,
                currentTime: 45.5,
                playbackRate: 1.5
            )
        }
    }

    func testAppMovedToBackground_withoutPlayer_doesNotCreateSnapshot() async {
        let store = TestStore(initialState: MiniBookPlayerFeature.State()) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.appMovedToBackground)
    }

    // MARK: - appReturnedToForeground Tests

    func testAppReturnedToForeground_doesNothing() async {
        let store = TestStore(initialState: MiniBookPlayerFeature.State()) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.appReturnedToForeground)
    }

    // MARK: - Player Action Tests

    func testPlayerAction_doesNothing() async {
        let testBook = makeTestBook()

        let store = TestStore(
            initialState: MiniBookPlayerFeature.State(
                book: testBook,
                player: PlayerFeature.State(
                    book: testBook,
                    currentKeyPointIndex: 0,
                    isPlaying: false,
                    currentTime: 0,
                    duration: nil,
                    playbackRate: 1.0
                )
            )
        ) {
            MiniBookPlayerFeature()
        }
        store.exhaustivity = .off

        await store.send(.player(.playPauseTapped)) {
            $0.player?.isPlaying = true
        }
    }

    // MARK: - Integration Tests

    func testFullFlow_onAppearToBookLoaded() async {
        let testBook = makeTestBook()

        let store = TestStore(initialState: MiniBookPlayerFeature.State()) {
            MiniBookPlayerFeature()
        } withDependencies: {
            $0.bookRepository = BookRepository(
                loadBook: { testBook },
                loadSnapshot: { nil },
                saveSnapshot: { _ in }
            )
        }
        store.exhaustivity = .off

        // User opens the app
        await store.send(.onAppear) {
            $0.isLoading = true
        }

        // loadBook is sent
        await store.receive(.loadBook)

        // Book is loaded
        await store.receive(\.bookLoaded, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.book = testBook
            $0.player = PlayerFeature.State(
                book: testBook,
                currentKeyPointIndex: 0,
                isPlaying: false,
                currentTime: 0,
                duration: nil,
                playbackRate: 1.0
            )
        }

        // Player actions are sent
        await store.receive(.player(.loadCurrentTrack))
        await store.receive(.player(.startListening))
    }
}
