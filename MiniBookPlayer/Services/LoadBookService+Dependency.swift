import Foundation
import Dependencies

struct LoadBookService {
    var load: @Sendable () async throws -> Book
}

extension LoadBookService: DependencyKey {
    static let liveValue = LoadBookService(
        load: {
            guard
                let url = Bundle.main.url(forResource: "aesops_fables", withExtension: "json"),
                let data = try? Data(contentsOf: url)
            else {
                throw NSError(domain: "BookLoading", code: 1)
            }
            
            let remote = try JSONDecoder().decode(BookRemoteModel.self, from: data)
            return Book(remote: remote)
        }
    )
    
    static let testValue = LoadBookService(load: {
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
    })
}

extension DependencyValues {
    var loadBookService: LoadBookService {
        get { self[LoadBookService.self] }
        set { self[LoadBookService.self] = newValue }
    }
}
