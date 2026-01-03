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
    
    static let testValue: LoadBookService = .init(load: { fatalError() })
}

extension DependencyValues {
    var loadBookService: LoadBookService {
        get { self[LoadBookService.self] }
        set { self[LoadBookService.self] = newValue }
    }
}
