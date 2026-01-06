import XCTest
import ComposableArchitecture
@testable import MiniBookPlayer

final class BookRepositoryTests: XCTestCase {

    func testLoadBook() async throws {
        let book = try await withDependencies {
            $0.bookRepository = await .testValue
        } operation: {
            try await DependencyValues._current.bookRepository.loadBook()
        }

        XCTAssertEqual(book.id, "test-book-1")
        XCTAssertEqual(book.title, "The Test Book")
    }
    
    func testSaveAndLoadSnapshot() async throws {
        var storedSnapshot: PlayerSnapshot?

        let snapshot = PlayerSnapshot(
            bookId: "book-1",
            keyPointIndex: 1,
            currentTime: 30,
            playbackRate: 1.5
        )

        let repository = BookRepository(
            loadBook: { fatalError("Not needed") },
            loadSnapshot: { storedSnapshot },
            saveSnapshot: { storedSnapshot = $0 }
        )

        let loaded = try await withDependencies {
            $0.bookRepository = repository
        } operation: {
            try await DependencyValues._current.bookRepository.saveSnapshot(snapshot)
            return try await DependencyValues._current.bookRepository.loadSnapshot()
        }

        XCTAssertEqual(loaded, snapshot)
    }

    func testLoadSnapshot_returnsNil() async throws {
        let snapshot = try await withDependencies {
            $0.bookRepository = await .testValue
        } operation: {
            try await DependencyValues._current.bookRepository.loadSnapshot()
        }

        XCTAssertNil(snapshot)
    }

    func testLoadBook_propagatesError() async {
        enum TestError: Error, Equatable { case failed }

        let repository = BookRepository(
            loadBook: { throw TestError.failed },
            loadSnapshot: { nil },
            saveSnapshot: { _ in }
        )

        do {
            _ = try await withDependencies {
                $0.bookRepository = repository
            } operation: {
                try await DependencyValues._current.bookRepository.loadBook()
            }
            XCTFail("Expected loadBook to throw, but it did not")
        } catch {
            XCTAssertEqual(error as? TestError, .failed)
        }
    }
}
