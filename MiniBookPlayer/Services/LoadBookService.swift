import Foundation

class LoadBookService {
    private func loadBookFromBundle() throws -> Book {
        guard
            let url = Bundle.main.url(forResource: "aesops_fables", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            throw NSError(domain: "BookLoading", code: 1)
        }

        let remote = try JSONDecoder().decode(BookRemoteModel.self, from: data)
        return Book(remote: remote)
    }
}
