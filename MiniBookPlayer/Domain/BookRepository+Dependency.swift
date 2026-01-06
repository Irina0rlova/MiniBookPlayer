import Foundation
import ComposableArchitecture

struct BookRepository {
    var loadBook: @Sendable () async throws -> Book
    var loadSnapshot: () throws -> PlayerSnapshot?
    var saveSnapshot: (PlayerSnapshot) throws -> Void
}

extension BookRepository: DependencyKey {
    static let liveValue = {
        let loadService = LoadBookService.liveValue
        let snapshotStorage = PlayerSnapshotStorage.liveValue
        
        return BookRepository(
            loadBook: {
                try await loadService.load()
            },
            loadSnapshot: {
                try snapshotStorage.load()
            },
            saveSnapshot: { snapshot in
                try snapshotStorage.save(snapshot)
            }
        )
    }()
    
    static let testValue = BookRepository(
        loadBook: {
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
        },
        loadSnapshot: {
            nil
        },
        saveSnapshot: { _ in }
    )
}

extension DependencyValues {
    var bookRepository: BookRepository {
        get { self[BookRepository.self] }
        set { self[BookRepository.self] = newValue }
    }
}
