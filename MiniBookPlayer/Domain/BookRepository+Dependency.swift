import Foundation
import ComposableArchitecture

struct BookRepository {
    var loadBook: () async throws -> Book
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
                id: "test-book",
                title: "Test Book",
                author: "Test Author",
                coverImageURL: nil,
                keyPoints: []
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
